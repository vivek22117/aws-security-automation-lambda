
lambda_func_name    = "EC2DeregisterAMILambda"
lambda_handler      = "lambda-function.lambda_handler"
lambda_runtime      = "python3.8"
lambda_timeout      = 90
lambda_memory       = 256
schedule_expression = "rate(15 minutes)"

lambda_role   = "EC2DeregisterAMILambdaAccessRole"
lambda_policy = "EC2DeregisterAMILambdaPermissionPolicy"
