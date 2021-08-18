##########################################################
# Adding the lambda archive to the defined bucket        #
##########################################################
resource "aws_s3_bucket_object" "cloudtrail_start_stop_package" {
  depends_on = [data.archive_file.cloudtrail-start-stop]

  bucket = data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_name
  key    = var.s3_lambda_bucket_key
  source = "${path.module}/lambda-function/cloudtrail-start-stop.zip"
  etag   = filemd5("${path.module}/lambda-function/cloudtrail-start-stop.zip")
}


data "archive_file" "cloudtrail-start-stop" {

  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/cloudtrail-start-stop.zip"
}


resource "aws_lambda_function" "cloudtrail_start_stop" {
  description = "Lambda function to make sure CloudTrail did not stop"
  function_name = var.lambda_func_name
  handler       = var.lambda_handler

  s3_bucket = aws_s3_bucket_object.cloudtrail_start_stop_package.bucket
  s3_key    = aws_s3_bucket_object.cloudtrail_start_stop_package.key
  source_code_hash = data.archive_file.cloudtrail-start-stop.output_base64sha256
  role             = aws_iam_role.ec2_start_stop_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = var.lambda_runtime

  tags = merge(local.common_tags, map("Name", "${var.environment}-cloudtrail-start-stop"))

}


resource "aws_lambda_permission" "cloudwatch_trigger" {

  statement_id  = "AllowExecutionFromCloudWatchEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudtrail_start_stop.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudtrail_start_stop_cw_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "cloudtrail_start_stop_cw_event_rule" {
  name                = "${aws_lambda_function.cloudtrail_start_stop.function_name}-event-rule"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = var.schedule_expression

  is_enabled = true
}

resource "aws_cloudwatch_event_target" "cw_event_target" {
  rule = aws_cloudwatch_event_rule.cloudtrail_start_stop_cw_event_rule.name
  arn  = aws_lambda_function.cloudtrail_start_stop.arn
}
