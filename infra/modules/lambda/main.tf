data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/handler.py"
  output_path = "${path.module}/src/handler.zip"
}

resource "aws_lambda_function" "main" {
  function_name    = "${var.app_name}-fn"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "handler.handler"
  runtime          = "python3.12"
  role             = var.role_arn
  memory_size      = var.memory_size
  timeout          = var.timeout
  tags             = var.tags

  environment {
    variables = merge(
      { APP_NAME = var.app_name },
      var.environment_variables
    )
  }
}
