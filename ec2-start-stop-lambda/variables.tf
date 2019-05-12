//Global Variables
variable "profile" {
  type        = "string"
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = "string"
  description = "AWS Profile name for credentials"
}

variable "schedule_expression" {
  type = "string"
  description = "Expression for lambda scheduler"
}

//Default Variables
variable "default_region" {
  type    = "string"
  default = "us-east-1"
}

variable "dyanamoDB_prefix" {
  type    = "string"
  default = "teamconcept-tfstate"
}

variable "s3_bucket_prefix" {
  type    = "string"
  default = "teamconcept-tfstate"
}

//Local variables
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "TeamConcept"
    environment = "${var.environment}"
  }
}

