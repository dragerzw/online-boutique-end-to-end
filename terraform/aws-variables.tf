
variable "memorystore" {
  type        = bool
  default     = false
  description = "Enable ElastiCache Redis for cart service"
}
# AWS variables for Online Boutique

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-west-2"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "online-boutique"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}
