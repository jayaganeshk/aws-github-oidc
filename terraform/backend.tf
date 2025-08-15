/*
Backend configuration is supplied at init time by CI or local commands.
We use the existing S3 bucket tf-backend-183103430916 and a per-env key:
  -bucket=tf-backend-183103430916
  -key=state/<env>/terraform.tfstate
  -region=<aws-region>
*/

terraform {
  backend "s3" {}
}
