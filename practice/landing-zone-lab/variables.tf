variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "lab"
}

variable "alert_email" {
  description = "Email address that receives security alerts (CloudTrail alarms, GuardDuty/Security Hub findings)"
  type        = string
}

variable "trusted_ip_cidr" {
  description = "Your own IP in CIDR form (e.g. 203.0.113.10/32) - the only address allowed to reach the 'management' security group. Find yours at https://checkip.amazonaws.com"
  type        = string
}

variable "enable_nat_gateway" {
  description = "NAT Gateway costs ~$0.045/hr plus data processing - it is NOT free tier. Leave false to keep this lab free; private subnets will simply have no outbound internet route (fine for this lab, since nothing needs to phone home)."
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.0.0.0/16"
}
