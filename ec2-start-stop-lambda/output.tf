# the created lambda function
output "aws_lambda_function_arn" {
  value = "${aws_lambda_function.ec2_start_stop.arn}"
}