##########################################################
# Adding the lambda archive to S3 and AWS Lambda config  #
##########################################################
resource "aws_s3_bucket_object" "lambda_package_zip" {
  bucket = var.deploy_jar_key
  key    = var.deploy_jar_key
  source = "${path.module}/../../kinesis-stream-processing/target/rsvp-record-processing-1.0.0-lambda.zip"
  etag   = filemd5("${path.module}/../../kinesis-stream-processing/target/rsvp-record-processing-1.0.0-lambda.zip")
}


resource "aws_lambda_function" "rsvp_lambda_processor" {
  depends_on = ["aws_iam_role.lambda_cloudwatch_role", "aws_iam_policy.lambda_cloudwatch_policy"]

  description   = "Lambda function to process EMR Cluster events"
  function_name = var.lambda_func_name
  handler       = var.lambda_handler
  s3_bucket     = aws_s3_bucket_object.lambda_package_zip.bucket
  s3_key        = aws_s3_bucket_object.lambda_package_zip.key
  role          = aws_iam_role.lambda_cloudwatch_role.arn
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  runtime       = "java8"

  environment {
    variables = {
      isRunningInLambda = "true",
      environment       = var.environment
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
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_logGroup" {
  name = "lambda-cloudwatch-integrated"

  retention_in_days = var.log_retention
  tags              = local.common_tags
}
