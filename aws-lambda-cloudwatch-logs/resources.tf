##########################################################
# Adding the lambda archive to S3 and AWS Lambda config  #
##########################################################
resource "aws_s3_bucket_object" "lambda_package_zip" {
  bucket = var.deploy_jar_key
  key = var.deploy_jar_key
  source = "${path.module}/../../kinesis-stream-processing/target/rsvp-record-processing-1.0.0-lambda.zip"
  etag = filemd5("${path.module}/../../kinesis-stream-processing/target/rsvp-record-processing-1.0.0-lambda.zip")
}


resource "aws_lambda_function" "emr_event_lambda_processor" {
  depends_on = [
    "aws_iam_role.lambda_cloudwatch_role",
    "aws_iam_policy.lambda_cloudwatch_policy"]

  description = "Lambda function to process EMR Cluster events"
  function_name = var.lambda_func_name
  handler = var.lambda_handler
  s3_bucket = aws_s3_bucket_object.lambda_package_zip.bucket
  s3_key = aws_s3_bucket_object.lambda_package_zip.key
  role = aws_iam_role.lambda_cloudwatch_role.arn
  memory_size = var.lambda_memory
  timeout = var.lambda_timeout
  runtime = "java8"

  environment {
    variables = {
      isRunningInLambda = "true",
      environment = var.environment
    }
  }

  tags = merge(local.common_tags, map("Name", "${var.environment}-spark-event-processor"))
}

####################################################################################
# Setup cloudwatch logs group to receive EMR cluster event status for monitoring   #
####################################################################################
resource "aws_cloudwatch_log_group" "emr_cluster_logGroup" {
  name = "sparky-transform-event"

  retention_in_days = var.log_retention
  tags = local.common_tags
}

##############################BASED ON CLOUDWATCH EVENT RULE###############################
resource "aws_cloudwatch_event_rule" "sparky_emr_events" {
  name = "emr-events"
  description = "EMR cluster cloudwatch event pattern"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "emr_event_target" {
  rule = aws_cloudwatch_event_rule.sparky_emr_events.name
  arn = aws_lambda_function.emr_event_lambda_processor.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_emr_events" {
  statement_id = "AllowExecutionFromCloudWatchEMREvents"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.emr_event_lambda_processor.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.sparky_emr_events.arn
}

##############################BASED ON CLOUDWATCH FILTERED LOGS#############################
resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = "sparky_emr_cluster_events"
  log_group_name  = aws_cloudwatch_log_group.emr_cluster_logGroup.name
  filter_pattern  = "logtype test"
  destination_arn = aws_lambda_function.emr_event_lambda_processor.arn
}

resource "aws_lambda_permission" "allow-cloudwatch_logs_events" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.emr_event_lambda_processor.arn
  principal     = "logs.${var.aws_region}.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.emr_cluster_logGroup.arn
}