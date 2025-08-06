provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "prod-terraform-state-${var.aws_region}"
    key            = "statefile/terraform-state-prod.tfstate"
    region         = var.aws_region
    dynamodb_table = "terraform-state-prod"
  }
}