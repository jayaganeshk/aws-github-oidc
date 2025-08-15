variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "environmentSuffix" {
  description = "Suffix for the environment"
  type        = string
}
