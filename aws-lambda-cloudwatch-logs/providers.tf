provider "aws" {
  region  = var.aws_region
  profile = var.profile

  version = "2.17.0"
}

provider "archive" {
  version = "1.2.2"
}

#############################################################
# Terraform configuration block is used to define backend   #
# Interpolation sytanx is not allowed in Backend            #
#############################################################
terraform {
  required_version = ">= 0.12" // Terraform version

  backend "s3" {
    profile        = "admin"
    bucket         = "teamconcept-tfstate-dev-us-east-1"
    dynamodb_table = "teamconcept-tfstate-dev-us-east-1"
    key            = "state/dev/lambda/cloudwatch-logs/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
  }
}