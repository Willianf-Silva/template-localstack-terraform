module "s3" {
  source   = "./modules/s3"
  app_name = var.app_name
}

module "sqs" {
  source   = "./modules/sqs"
  app_name = var.app_name
}

module "sns" {
  source        = "./modules/sns"
  app_name      = var.app_name
  sqs_queue_arn = module.sqs.queue_arn
}

module "dynamodb" {
  source   = "./modules/dynamodb"
  app_name = var.app_name
}

module "secretsmanager" {
  source      = "./modules/secretsmanager"
  app_name    = var.app_name
  environment = var.environment
}

module "kms" {
  source   = "./modules/kms"
  app_name = var.app_name
}

module "iam" {
  source   = "./modules/iam"
  app_name = var.app_name
}

module "lambda" {
  source   = "./modules/lambda"
  app_name = var.app_name
  role_arn = module.iam.lambda_role_arn
}

module "cloudwatch" {
  source               = "./modules/cloudwatch"
  app_name             = var.app_name
  lambda_function_name = module.lambda.function_name
}

module "eventbridge" {
  source               = "./modules/eventbridge"
  app_name             = var.app_name
  lambda_arn           = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
}

module "ssm" {
  source      = "./modules/ssm"
  app_name    = var.app_name
  environment = var.environment
}

module "kinesis" {
  source   = "./modules/kinesis"
  app_name = var.app_name
}

module "stepfunctions" {
  source   = "./modules/stepfunctions"
  app_name = var.app_name
}

module "apigateway" {
  source               = "./modules/apigateway"
  app_name             = var.app_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}