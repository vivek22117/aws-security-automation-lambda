######################################################################
# Global variables for Terraform Configuration                       #
######################################################################
variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "profile" {
  type        = string
  description = "AWS credential profile to use"
}

variable "log_retention" {
  type        = number
  description = "Number of days to keep logs"
}

variable "lambda_func_name" {
  type        = string
  description = "Name of the lambda function"
}

variable "lambda_handler" {
  type        = string
  description = "AWS lambda fucntion handler defination"
}

variable "deploy_jar_bucket" {
  type        = string
  description = "S3 bucket holding deployable jar on AWS lambda"
}

variable "deploy_jar_key" {
  type        = string
  description = "S3 bucket key holding deployable jar"
}

variable "lambda_memory" {
  type        = string
  description = "Memory allocated to AWS lambda processing"
}

variable "lambda_timeout" {
  type        = string
  description = "AWS lambda timeout in seconds"
}

######################################################
# Local variables defined                            #
######################################################
variable "team" {
  type        = "string"
  description = "Owner team for this applcation infrastructure"
}

variable "owner" {
  type        = "string"
  description = "Owner of the product"
}

variable "environment" {
  type        = "string"
  description = "Environmet to be used"
}

#####=============Local variables===============#####
locals {
  common_tags = {
    owner       = var.owner
    team        = var.team
    environment = var.environment
  }
}