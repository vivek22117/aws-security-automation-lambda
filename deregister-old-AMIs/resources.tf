data "archive_file" "ami_deregister" {
  //source_content          = "${data.template_file.lambda_source.rendered}"

  type        = "zip"
  source_file = "lambda-function/lambda-function.py"
  output_path = "lambda-function/ami-deregister-lambda.zip"
}


resource "aws_lambda_function" "ami_deregister" {
  description = "Lambda function to deregister old AMIs"

  function_name = var.lambda_func_name
  handler       = var.lambda_handler

  filename         = data.archive_file.ami_deregister.output_path
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