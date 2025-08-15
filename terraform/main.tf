data "aws_caller_identity" "current" {}

locals {
  bucket_name = lower(format("%s-%s-%s", var.bucket_name_prefix, var.environment, data.aws_caller_identity.current.account_id))

  common_tags = merge({
    Project     = "github-oidc-demo"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.tags)
}

resource "aws_s3_bucket" "demo" {
  bucket = local.bucket_name
  tags   = local.common_tags
}
