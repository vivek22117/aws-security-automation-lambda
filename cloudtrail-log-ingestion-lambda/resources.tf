data "archive_file" "cloudtrail_monitoring_lambda_archive" {
  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/cloudtrail-monitoring-lambda.zip"
}


resource "aws_lambda_function" "cloudtrail_monitoring_lambda" {
  description = "Lambda function to process cloudtrail events"

  function_name = var.lambda_func_name
  handler       = var.lambda_handler

  filename         = data.archive_file.cloudtrail_monitoring_lambda_archive.output_path
  source_code_hash = data.archive_file.cloudtrail_monitoring_lambda_archive.output_base64sha256
  role             = aws_iam_role.cloudtrail_monitoring_lambda_role.arn

  memory_size = var.lambda_memory
  timeout     = var.lambda_timeout
  runtime     = var.lambda_runtime

  tags = merge(local.common_tags, map("Name", "${var.environment}-cloudtrail-monitoring"))

}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = local.s3_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.cloudtrail_monitoring_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix = "AWSLogs/"
  }
}

resource "aws_lambda_permission" "cloudwatch_trigger" {
  statement_id  = "AllowExecutionFromS3Bucket2"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudtrail_monitoring_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = local.s3_arn
}

