##########################################################
# Adding the lambda archive to the defined bucket        #
##########################################################
resource "aws_s3_bucket_object" "ec2_start_stop_package" {
  depends_on = [data.archive_file.ec2-start-stop]

  bucket = data.terraform_remote_state.s3_buckets.outputs.artifactory_s3_name
  key    = var.s3_lambda_bucket_key
  source = "${path.module}/lambda-function/ec2-start-stop.zip"
  etag   = filemd5("${path.module}/lambda-function/ec2-start-stop.zip")
}


data "archive_file" "ec2-start-stop" {

  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/ec2-start-stop.zip"
}


resource "aws_lambda_function" "ec2_start_stop" {
  description = "Lambda function to start and stop EC2"
  function_name = var.lambda_func_name
  handler       = var.lambda_handler

  s3_bucket = aws_s3_bucket_object.ec2_start_stop_package.bucket
  s3_key    = aws_s3_bucket_object.ec2_start_stop_package.key
  source_code_hash = data.archive_file.ec2-start-stop.output_base64sha256
  role             = aws_iam_role.ec2_start_stop_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = var.lambda_runtime

  tags = merge(local.common_tags, map("Name", "${var.environment}-ec2-start-stop"))

}


resource "aws_lambda_permission" "cloudwatch_trigger" {

  statement_id  = "AllowExecutionFromCloudWatchEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_stop_cw_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "start_stop_cw_event_rule" {
  name                = "${aws_lambda_function.ec2_start_stop.function_name}-event-rule"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = var.schedule_expression

  is_enabled = true
}

resource "aws_cloudwatch_event_target" "cw_event_target" {
  rule = aws_cloudwatch_event_rule.start_stop_cw_event_rule.name
  arn  = aws_lambda_function.ec2_start_stop.arn
}
