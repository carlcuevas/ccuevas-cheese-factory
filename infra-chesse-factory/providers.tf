provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "ccuevas-cheese-state-001"
    key            = "global/cheese/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-cheese"
    encrypt        = true
  }
}


