output "transit_gateway_id" {
  value       = aws_ec2_transit_gateway.main.id
  description = "Transit Gateway ID."
}

output "transit_gateway_route_table_id" {
  value       = aws_ec2_transit_gateway_route_table.main.id
  description = "TGW route table ID."
}

output "connectivity_vpc_id" {
  value       = aws_vpc.connectivity.id
  description = "Connectivity VPC ID."
}

output "salesforce_vpc_id" {
  value       = aws_vpc.salesforce.id
  description = "Dedicated Salesforce VPC ID."
}

output "salesforce_inbound_vpc_endpoint_id" {
  value       = aws_vpc_endpoint.salesforce_inbound.id
  description = "AWS interface endpoint used for AWS-to-Salesforce Private Connect."
}

output "salesforce_inbound_endpoint_ips" {
  value       = [for eni in data.aws_network_interface.salesforce_inbound_endpoint : eni.private_ip]
  description = "Private IPs to which the Salesforce My Domain private DNS record resolves."
}

output "salesforce_outbound_endpoint_service_name" {
  value       = aws_vpc_endpoint_service.salesforce_outbound.service_name
  description = "Give this service name to the Salesforce admin to configure Salesforce-to-AWS Private Connect."
}

output "salesforce_outbound_endpoint_service_id" {
  value       = aws_vpc_endpoint_service.salesforce_outbound.id
  description = "AWS endpoint service ID for Salesforce-to-AWS Private Connect."
}

output "salesforce_outbound_nlb_dns_name" {
  value       = aws_lb.salesforce_outbound.dns_name
  description = "Internal NLB DNS name for the AWS service exposed to Salesforce."
}

output "vpn_connection_id" {
  value       = aws_vpn_connection.azure.id
  description = "AWS Site-to-Site VPN connection ID."
}

output "vpn_tunnel_public_ips" {
  value = {
    tunnel1 = aws_vpn_connection.azure.tunnel1_address
    tunnel2 = aws_vpn_connection.azure.tunnel2_address
  }
  description = "AWS VPN tunnel endpoint IPs to configure on Azure."
}

output "resolver_inbound_ips" {
  value       = [for address in aws_route53_resolver_endpoint.inbound.ip_address : address.ip]
  description = "Route 53 inbound Resolver IPs for conditional forwarding from on-prem/Azure."
}

output "resolver_outbound_ips" {
  value       = [for address in aws_route53_resolver_endpoint.outbound.ip_address : address.ip]
  description = "Route 53 outbound Resolver endpoint IPs."
}
