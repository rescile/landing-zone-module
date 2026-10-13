variable "aws_region" {
  description = "AWS region for the Salesforce PrivateLink consumer endpoint."
  type        = string
  default     = "eu-central-2"
}

variable "name_prefix" {
  description = "Prefix used to name resources in this baseline."
  type        = string
  default     = "salesforce"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated Salesforce connectivity VPC. Ensure it does not overlap with connected networks."
  type        = string
  default     = "10.10.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the two private endpoint subnets; one subnet per selected AZ."
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.20.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly two private subnet CIDRs for this two-AZ baseline."
  }
}

variable "allowed_client_cidrs" {
  description = "CIDRs of workloads allowed to connect to the Salesforce interface endpoint over TCP/443. Replace with the minimum required source ranges."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "salesforce_endpoint_service_name" {
  description = "Exact Salesforce-provided VPC endpoint service name. Confirm this value with Salesforce before deployment."
  type        = string
  default     = "com.amazonaws.vpce.eu-central-2.vpce-svc-04dc38e972b1448b8"
}

variable "endpoint_private_dns_enabled" {
  description = "Enable only if the Salesforce endpoint service supports private DNS and the required DNS verification/configuration is complete."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Tags applied to resources managed by this baseline."
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Purpose     = "SalesforcePrivateLink"
    Environment = "template"
  }
}
