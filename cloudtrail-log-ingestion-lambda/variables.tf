#####======================Global Variables=================================######
variable "environment" {
  type        = string
  description = "Environment to be configured 'dev', 'qa', 'prod'"
}

#####===============================Lambda Config Variables====================#####
variable "schedule_expression" {
  type        = string
  description = "Expression for lambda scheduler"
}

variable "lambda_func_name" {
  type        = string
  description = "EC2 Start Stop lambda function name"
}

variable "lambda_handler" {
  type        = string
  description = "EC2 Start Stop lambda handler name"
}

variable "lambda_memory" {
  type        = number
  description = "EC2 Start Stop lambda memory size"
}

variable "lambda_timeout" {
  type        = number
  description = "EC2 Start Stop lambda time out"
}

variable "lambda_runtime" {
  type        = string
  description = "EC2 Start Stop lambda runtime"
}

variable "lambda_role" {
  type        = string
  description = "Name of the lambda access IAM role"
}

variable "lambda_policy" {
  type        = string
  description = "Name of the lambda access IAM policy"
}


#####============================Default Variables==========================#####
variable "default_region" {
  type    = string
}

#####========================Local variables=======================#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "DD-Team"
    component   = "Security"
    environment = var.environment
  }
}

