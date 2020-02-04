data "archive_file" "ami_deregister" {
  //source_content          = "${data.template_file.lambda_source.rendered}"

  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/ami-deregister-lambda.zip"
}


resource "aws_lambda_function" "ami_deregister" {
  description   = "Lambda function to deregister old AMIs"
  function_name = "ami-deregister-lambda"
  handler       = "lambda-function.lambda_handler"

  filename         = data.archive_file.ami_deregister.output_path
  source_code_hash = data.archive_file.ami_deregister.output_base64sha256
  role             = aws_iam_role.ami_deregister_role.arn

  memory_size = 128
  timeout     = 90
  runtime     = "python3.7"

  tags = merge(local.common_tags, map("Name", "${var.environment}-ami-deregister"))

}


resource "aws_lambda_permission" "cloudwatch_trigger" {
  //function_name = "${join("", concat(aws_lambda_function.ec2_start_stop.*.arn, aws_lambda_function.lambda_classic.*.arn))}"

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ami_deregister.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda.arn
}

resource "aws_cloudwatch_event_rule" "lambda" {
  name                = "${aws_lambda_function.ami_deregister.function_name}-event-rule"
  description         = "Schedule trigger for lambda execution"
  schedule_expression = var.schedule_expression

  is_enabled = true
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.lambda.name
  arn  = aws_lambda_function.ami_deregister.arn
}