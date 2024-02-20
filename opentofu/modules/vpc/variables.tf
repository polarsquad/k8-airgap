
variable "cidr" {
  description = "cidr"
  default     = "10.100.0.0/16"
  type        = string
}

variable "vpc_name" {
  description = "vpc_name"
  default     = "vpc"
  type        = string
}

variable "environment" {
  description = "environment"
  default     = "dev"
  type        = string
}

variable "profile" {
  description = "profile"
  default     = "polarsquad"
  type        = string
}

variable "aws_region" {
  description = "aws_region"
  default     = "eu-west-1"
  type        = string
  
}