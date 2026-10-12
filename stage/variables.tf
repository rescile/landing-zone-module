variable "aws_region" {
  description = "AWS region for this network foundation."
  type        = string
  default     = "eu-central-2"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "name_prefix" {
  type    = string
  default = "sf-hyperforce"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "connectivity_vpc_cidr" {
  description = "Non-overlapping CIDR for VPN transit and Resolver endpoints."
  type        = string
  default     = "10.240.0.0/20"
}

variable "connectivity_subnet_cidrs" {
  description = "Exactly two private subnet CIDRs, one in each AZ."
  type        = list(string)
  default     = ["10.240.0.0/24", "10.240.1.0/24"]

  validation {
    condition     = length(var.connectivity_subnet_cidrs) == 2
    error_message = "Exactly two Connectivity VPC subnet CIDRs are required."
  }
}

variable "salesforce_vpc_cidr" {
  description = "Dedicated, non-overlapping Salesforce VPC CIDR."
  type        = string
  default     = "10.241.0.0/20"
}

variable "salesforce_endpoint_subnet_cidrs" {
  description = "Two private subnet CIDRs for Private Connect endpoint and NLB resources."
  type        = list(string)
  default     = ["10.241.0.0/24", "10.241.1.0/24"]

  validation {
    condition     = length(var.salesforce_endpoint_subnet_cidrs) == 2
    error_message = "Exactly two Salesforce VPC subnet CIDRs are required."
  }
}

variable "availability_zones" {
  description = "Optional two AZ names. Leave empty to select the first two available AZs."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) == 2
    error_message = "Provide either no AZs or exactly two AZ names."
  }
}

variable "azure_vpn_public_ip" {
  description = "Public IP address of the Azure VPN Gateway."
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "Required Customer Gateway ASN attribute; not used for BGP route exchange in static mode."
  type        = number
  default     = 65515
}

variable "remote_network_cidrs" {
  description = "Approved Azure/on-prem prefixes reachable through the static VPN."
  type        = set(string)
  default     = ["10.20.0.0/16", "10.30.0.0/16"]
}

variable "dns_client_cidrs" {
  description = "CIDRs permitted to query the Route 53 inbound Resolver endpoint over UDP/TCP 53."
  type        = set(string)
  default     = ["10.20.0.0/16", "10.30.0.0/16"]
}

variable "onprem_dns_suffix" {
  type    = string
  default = "corp.example"
}

variable "onprem_dns_server_ips" {
  type    = set(string)
  default = ["10.20.0.10", "10.20.0.11"]
}

variable "azure_dns_suffix" {
  type    = string
  default = "azure.example"
}

variable "azure_dns_server_ips" {
  type    = set(string)
  default = ["10.30.0.10", "10.30.0.11"]
}

variable "resolver_rule_association_vpc_ids" {
  description = "Optional additional VPC IDs in this account that should use outbound DNS forwarding rules."
  type        = set(string)
  default     = []
}

variable "salesforce_inbound_service_name" {
  description = "Exact AWS PrivateLink service name copied from Salesforce Private Connect Setup for inbound connection (AWS to Salesforce)."
  type        = string
}

variable "salesforce_my_domain" {
  description = "Exact Salesforce My Domain FQDN, e.g. mycompany.my.salesforce.com. Do not include a URL scheme or path."
  type        = string
}

variable "salesforce_outbound_allowed_principal_arn" {
  description = "Salesforce-provided AWS IAM principal ARN for outbound Private Connect in this region."
  type        = string
}

variable "outbound_target_ips" {
  description = "Private IP targets for the AWS service Salesforce will call. Targets must be reachable from the Salesforce VPC."
  type        = set(string)
}

variable "outbound_listener_port" {
  description = "TCP listener port exposed to Salesforce through Private Connect."
  type        = number
  default     = 443
}

variable "outbound_target_port" {
  description = "TCP port on the target application."
  type        = number
  default     = 443
}

variable "outbound_service_ingress_cidrs" {
  description = "Approved source CIDRs for traffic reaching the NLB. Populate only with values confirmed for your Salesforce Private Connect setup; empty means no ingress is allowed."
  type        = set(string)
  default     = []
}

variable "alarm_actions" {
  description = "Optional CloudWatch alarm action ARNs, e.g. SNS topic ARNs."
  type        = list(string)
  default     = []
}
