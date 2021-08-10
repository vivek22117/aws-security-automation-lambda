##########################################################
# Adding the lambda archive to the defined bucket        #
##########################################################
resource "aws_s3_bucket_object" "ami_deregister_package" {
  depends_on = [data.archive_file.ami_deregister]

  bucket = data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_name
  key    = var.s3_lambda_bucket_key
  source = "${path.module}/lambda-function/ami-deregister-lambda.zip"
  etag   = filemd5("${path.module}/lambda-function/ami-deregister-lambda.zip")
}

data "archive_file" "ami_deregister" {
  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/ami-deregister-lambda.zip"
}


resource "aws_lambda_function" "ami_deregister" {
  description = "Lambda function to deregister old AMIs"

  function_name = var.lambda_func_name
  handler       = var.lambda_handler

  s3_bucket = aws_s3_bucket_object.ami_deregister_package.bucket
  s3_key    = aws_s3_bucket_object.ami_deregister_package.key

  source_code_hash = data.archive_file.ami_deregister.output_base64sha256
  role             = aws_iam_role.ami_deregister_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = var.lambda_runtime

  tags = merge(local.common_tags, map("Name", "${var.environment}-ami-deregister"))

}


resource "aws_lambda_permission" "cloudwatch_trigger" {

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ami_deregister.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cw_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "cw_event_rule" {
  name                = "${aws_lambda_function.ami_deregister.function_name}-event-rule"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = var.schedule_expression

  is_enabled = true
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.cw_event_rule.name
  arn  = aws_lambda_function.ami_deregister.arn
}
