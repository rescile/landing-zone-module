data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = length(var.availability_zones) == 2 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  connectivity_subnets = {
    for idx, cidr in var.connectivity_subnet_cidrs : tostring(idx) => {
      cidr = cidr
      az   = local.selected_azs[idx]
    }
  }

  salesforce_subnets = {
    for idx, cidr in var.salesforce_endpoint_subnet_cidrs : tostring(idx) => {
      cidr = cidr
      az   = local.selected_azs[idx]
    }
  }

  remote_routes = var.remote_network_cidrs

  dns_targets = merge(
    { for ip in var.onprem_dns_server_ips : "onprem-${replace(ip, ".", "-")}" => ip },
    { for ip in var.azure_dns_server_ips : "azure-${replace(ip, ".", "-")}" => ip }
  )

  resolver_association_vpcs = setunion(
    toset([aws_vpc.connectivity.id]),
    var.resolver_rule_association_vpc_ids
  )
}

# ---------------------------------------------------------------------------
# Transit Gateway and static VPN to Azure
# ---------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "main" {
  description                     = "${var.name_prefix} transit gateway"
  amazon_side_asn                 = 64520
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "disable"

  tags = { Name = "${var.name_prefix}-tgw" }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags               = { Name = "${var.name_prefix}-tgw-rt-phase1" }
}

resource "aws_customer_gateway" "azure" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.azure_vpn_public_ip
  type       = "ipsec.1"

  tags = { Name = "${var.name_prefix}-azure-cgw" }
}

resource "aws_vpn_connection" "azure" {
  customer_gateway_id = aws_customer_gateway.azure.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = { Name = "${var.name_prefix}-azure-vpn" }
}

resource "aws_ec2_transit_gateway_route_table_association" "vpn" {
  transit_gateway_attachment_id  = aws_vpn_connection.azure.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route" "remote" {
  for_each = local.remote_routes

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_vpn_connection.azure.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# ---------------------------------------------------------------------------
# Connectivity VPC: VPN transit routes and Route 53 Resolver
# ---------------------------------------------------------------------------

resource "aws_vpc" "connectivity" {
  cidr_block           = var.connectivity_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-connectivity-vpc" }
}

resource "aws_subnet" "connectivity" {
  for_each = local.connectivity_subnets

  vpc_id                  = aws_vpc.connectivity.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = { Name = "${var.name_prefix}-connectivity-private-${each.key}" }
}

resource "aws_route_table" "connectivity" {
  for_each = local.connectivity_subnets

  vpc_id = aws_vpc.connectivity.id
  tags   = { Name = "${var.name_prefix}-connectivity-rt-${each.key}" }
}

resource "aws_route_table_association" "connectivity" {
  for_each = local.connectivity_subnets

  subnet_id      = aws_subnet.connectivity[each.key].id
  route_table_id = aws_route_table.connectivity[each.key].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "connectivity" {
  subnet_ids         = [for subnet in aws_subnet.connectivity : subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.connectivity.id

  dns_support                                     = "enable"
  ipv6_support                                    = "disable"
  appliance_mode_support                          = "disable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "${var.name_prefix}-connectivity-attachment" }
}

resource "aws_ec2_transit_gateway_route_table_association" "connectivity" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.connectivity.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route" "connectivity_vpc" {
  destination_cidr_block         = var.connectivity_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.connectivity.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_route" "connectivity_remote" {
  for_each = {
    for pair in setproduct(keys(local.connectivity_subnets), tolist(local.remote_routes)) :
    "${pair[0]}|${pair[1]}" => { subnet_key = pair[0], cidr = pair[1] }
  }

  route_table_id         = aws_route_table.connectivity[each.value.subnet_key].id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "connectivity_to_salesforce" {
  for_each = local.connectivity_subnets

  route_table_id         = aws_route_table.connectivity[each.key].id
  destination_cidr_block = var.salesforce_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_security_group" "resolver" {
  name        = "${var.name_prefix}-resolver"
  description = "DNS traffic for Route 53 Resolver endpoints"
  vpc_id      = aws_vpc.connectivity.id

  tags = { Name = "${var.name_prefix}-resolver-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "resolver_udp" {
  for_each = var.dns_client_cidrs

  security_group_id = aws_security_group.resolver.id
  cidr_ipv4         = each.value
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  description       = "DNS UDP from approved clients ${each.value}"
}

resource "aws_vpc_security_group_ingress_rule" "resolver_tcp" {
  for_each = var.dns_client_cidrs

  security_group_id = aws_security_group.resolver.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  description       = "DNS TCP from approved clients ${each.value}"
}

resource "aws_vpc_security_group_egress_rule" "resolver_udp" {
  for_each = local.dns_targets

  security_group_id = aws_security_group.resolver.id
  cidr_ipv4         = "${each.value}/32"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  description       = "DNS UDP to approved target ${each.value}"
}

resource "aws_vpc_security_group_egress_rule" "resolver_tcp" {
  for_each = local.dns_targets

  security_group_id = aws_security_group.resolver.id
  cidr_ipv4         = "${each.value}/32"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  description       = "DNS TCP to approved target ${each.value}"
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name                   = "${var.name_prefix}-inbound"
  direction              = "INBOUND"
  resolver_endpoint_type = "IPV4"
  protocols              = ["Do53"]
  security_group_ids     = [aws_security_group.resolver.id]

  dynamic "ip_address" {
    for_each = aws_subnet.connectivity
    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = { Name = "${var.name_prefix}-resolver-inbound" }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name                   = "${var.name_prefix}-outbound"
  direction              = "OUTBOUND"
  resolver_endpoint_type = "IPV4"
  protocols              = ["Do53"]
  security_group_ids     = [aws_security_group.resolver.id]

  dynamic "ip_address" {
    for_each = aws_subnet.connectivity
    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = { Name = "${var.name_prefix}-resolver-outbound" }
}

resource "aws_route53_resolver_rule" "onprem" {
  domain_name          = var.onprem_dns_suffix
  name                 = "${var.name_prefix}-onprem"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = var.onprem_dns_server_ips
    content {
      ip   = target_ip.value
      port = 53
    }
  }

  tags = { Name = "${var.name_prefix}-dns-onprem" }
}

resource "aws_route53_resolver_rule" "azure" {
  domain_name          = var.azure_dns_suffix
  name                 = "${var.name_prefix}-azure"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = var.azure_dns_server_ips
    content {
      ip   = target_ip.value
      port = 53
    }
  }

  tags = { Name = "${var.name_prefix}-dns-azure" }
}

resource "aws_route53_resolver_rule_association" "onprem" {
  for_each = local.resolver_association_vpcs

  resolver_rule_id = aws_route53_resolver_rule.onprem.id
  vpc_id           = each.value
}

resource "aws_route53_resolver_rule_association" "azure" {
  for_each = local.resolver_association_vpcs

  resolver_rule_id = aws_route53_resolver_rule.azure.id
  vpc_id           = each.value
}

# ---------------------------------------------------------------------------
# Dedicated Salesforce VPC
# ---------------------------------------------------------------------------

resource "aws_vpc" "salesforce" {
  cidr_block           = var.salesforce_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-salesforce-vpc" }
}

resource "aws_subnet" "salesforce" {
  for_each = local.salesforce_subnets

  vpc_id                  = aws_vpc.salesforce.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = { Name = "${var.name_prefix}-salesforce-private-${each.key}" }
}

resource "aws_route_table" "salesforce" {
  for_each = local.salesforce_subnets

  vpc_id = aws_vpc.salesforce.id
  tags   = { Name = "${var.name_prefix}-salesforce-rt-${each.key}" }
}

resource "aws_route_table_association" "salesforce" {
  for_each = local.salesforce_subnets

  subnet_id      = aws_subnet.salesforce[each.key].id
  route_table_id = aws_route_table.salesforce[each.key].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "salesforce" {
  subnet_ids         = [for subnet in aws_subnet.salesforce : subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.salesforce.id

  dns_support                                     = "enable"
  ipv6_support                                    = "disable"
  appliance_mode_support                          = "disable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "${var.name_prefix}-salesforce-attachment" }
}

resource "aws_ec2_transit_gateway_route_table_association" "salesforce" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.salesforce.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route" "salesforce_vpc" {
  destination_cidr_block         = var.salesforce_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.salesforce.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_route" "salesforce_remote" {
  for_each = {
    for pair in setproduct(keys(local.salesforce_subnets), tolist(local.remote_routes)) :
    "${pair[0]}|${pair[1]}" => { subnet_key = pair[0], cidr = pair[1] }
  }

  route_table_id         = aws_route_table.salesforce[each.value.subnet_key].id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "salesforce_to_connectivity" {
  for_each = local.salesforce_subnets

  route_table_id         = aws_route_table.salesforce[each.key].id
  destination_cidr_block = var.connectivity_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

# ---------------------------------------------------------------------------
# Salesforce Private Connect, direction AWS -> Salesforce (inbound to Salesforce)
# ---------------------------------------------------------------------------

resource "aws_security_group" "salesforce_inbound_endpoint" {
  name        = "${var.name_prefix}-salesforce-inbound-endpoint"
  description = "HTTPS access to Salesforce Private Connect interface endpoint"
  vpc_id      = aws_vpc.salesforce.id

  tags = { Name = "${var.name_prefix}-salesforce-inbound-endpoint-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "salesforce_endpoint_https" {
  for_each = toset(concat(tolist(var.remote_network_cidrs), [var.connectivity_vpc_cidr]))

  security_group_id = aws_security_group.salesforce_inbound_endpoint.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS from approved internal network ${each.value}"
}

resource "aws_vpc_endpoint" "salesforce_inbound" {
  vpc_id              = aws_vpc.salesforce.id
  service_name        = var.salesforce_inbound_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.salesforce : subnet.id]
  security_group_ids  = [aws_security_group.salesforce_inbound_endpoint.id]
  private_dns_enabled = false

  tags = { Name = "${var.name_prefix}-salesforce-private-connect-inbound" }
}

data "aws_network_interface" "salesforce_inbound_endpoint" {
  for_each = toset(aws_vpc_endpoint.salesforce_inbound.network_interface_ids)
  id       = each.value
}

resource "aws_route53_zone" "salesforce_my_domain" {
  name = var.salesforce_my_domain

  vpc {
    vpc_id = aws_vpc.salesforce.id
  }

  tags = { Name = "${var.name_prefix}-salesforce-my-domain" }
}

resource "aws_route53_zone_association" "salesforce_domain_connectivity_vpc" {
  zone_id = aws_route53_zone.salesforce_my_domain.zone_id
  vpc_id  = aws_vpc.connectivity.id
}

resource "aws_route53_record" "salesforce_my_domain" {
  zone_id = aws_route53_zone.salesforce_my_domain.zone_id
  name    = var.salesforce_my_domain
  type    = "A"
  ttl     = 60
  records = [for eni in data.aws_network_interface.salesforce_inbound_endpoint : eni.private_ip]
}

# ---------------------------------------------------------------------------
# Salesforce Private Connect, direction Salesforce -> AWS (outbound from Salesforce)
# ---------------------------------------------------------------------------

resource "aws_security_group" "outbound_nlb" {
  name        = "${var.name_prefix}-salesforce-outbound-nlb"
  description = "Ingress for Salesforce Private Connect outbound calls"
  vpc_id      = aws_vpc.salesforce.id

  tags = { Name = "${var.name_prefix}-salesforce-outbound-nlb-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "outbound_nlb" {
  for_each = var.outbound_service_ingress_cidrs

  security_group_id = aws_security_group.outbound_nlb.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = var.outbound_listener_port
  to_port           = var.outbound_listener_port
  description       = "Approved Salesforce Private Connect source ${each.value}"
}

resource "aws_vpc_security_group_egress_rule" "outbound_nlb_targets" {
  for_each = var.outbound_target_ips

  security_group_id = aws_security_group.outbound_nlb.id
  cidr_ipv4         = "${each.value}/32"
  ip_protocol       = "tcp"
  from_port         = var.outbound_target_port
  to_port           = var.outbound_target_port
  description       = "Traffic to approved application target ${each.value}"
}

resource "aws_lb" "salesforce_outbound" {
  name               = substr("${var.name_prefix}-sf-out", 0, 32)
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.salesforce : subnet.id]
  security_groups    = [aws_security_group.outbound_nlb.id]
  enable_cross_zone_load_balancing = true

  tags = { Name = "${var.name_prefix}-salesforce-outbound-nlb" }
}

resource "aws_lb_target_group" "salesforce_outbound" {
  name        = substr("${var.name_prefix}-sf-out-tg", 0, 32)
  port        = var.outbound_target_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.salesforce.id

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = { Name = "${var.name_prefix}-salesforce-outbound-tg" }
}

resource "aws_lb_target_group_attachment" "salesforce_outbound" {
  for_each = var.outbound_target_ips

  target_group_arn = aws_lb_target_group.salesforce_outbound.arn
  target_id        = each.value
  port             = var.outbound_target_port
}

resource "aws_lb_listener" "salesforce_outbound" {
  load_balancer_arn = aws_lb.salesforce_outbound.arn
  port              = var.outbound_listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.salesforce_outbound.arn
  }
}

resource "aws_vpc_endpoint_service" "salesforce_outbound" {
  acceptance_required        = true
  network_load_balancer_arns = [aws_lb.salesforce_outbound.arn]
  allowed_principals         = [var.salesforce_outbound_allowed_principal_arn]

  tags = { Name = "${var.name_prefix}-salesforce-outbound-endpoint-service" }
}

# ---------------------------------------------------------------------------
# VPN tunnel monitoring
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_1_down" {
  alarm_name          = "${var.name_prefix}-vpn-tunnel-1-down"
  alarm_description   = "AWS VPN tunnel 1 is down."
  namespace           = "AWS/VPN"
  metric_name         = "TunnelState"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    TunnelIpAddress = aws_vpn_connection.azure.tunnel1_address
  }
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_2_down" {
  alarm_name          = "${var.name_prefix}-vpn-tunnel-2-down"
  alarm_description   = "AWS VPN tunnel 2 is down."
  namespace           = "AWS/VPN"
  metric_name         = "TunnelState"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    TunnelIpAddress = aws_vpn_connection.azure.tunnel2_address
  }
}
