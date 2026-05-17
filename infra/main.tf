locals {
  common_tags = merge(
    {
      app_name    = var.app_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags
  )
}

module "s3" {
  count    = var.enable_s3 ? 1 : 0
  source   = "./modules/s3"
  app_name = var.app_name
  tags     = local.common_tags
}

module "sqs" {
  count    = var.enable_sqs ? 1 : 0
  source   = "./modules/sqs"
  app_name = var.app_name
  tags     = local.common_tags
}

module "sns" {
  count         = var.enable_sns && var.enable_sqs ? 1 : 0
  source        = "./modules/sns"
  app_name      = var.app_name
  sqs_queue_arn = module.sqs[0].queue_arn
  tags          = local.common_tags
}

module "dynamodb" {
  count    = var.enable_dynamodb ? 1 : 0
  source   = "./modules/dynamodb"
  app_name = var.app_name
  tags     = local.common_tags
}

module "secretsmanager" {
  count       = var.enable_secretsmanager ? 1 : 0
  source      = "./modules/secretsmanager"
  app_name    = var.app_name
  environment = var.environment
  tags        = local.common_tags
}

module "kms" {
  count    = var.enable_kms ? 1 : 0
  source   = "./modules/kms"
  app_name = var.app_name
  tags     = local.common_tags
}

module "iam" {
  count    = var.enable_iam ? 1 : 0
  source   = "./modules/iam"
  app_name = var.app_name
  tags     = local.common_tags
}

module "lambda" {
  count    = var.enable_lambda && var.enable_iam ? 1 : 0
  source   = "./modules/lambda"
  app_name = var.app_name
  role_arn = module.iam[0].lambda_role_arn
  tags     = local.common_tags
}

module "cloudwatch" {
  count                = var.enable_cloudwatch && var.enable_lambda ? 1 : 0
  source               = "./modules/cloudwatch"
  app_name             = var.app_name
  lambda_function_name = module.lambda[0].function_name
  tags                 = local.common_tags
}

module "eventbridge" {
  count                = var.enable_eventbridge && var.enable_lambda ? 1 : 0
  source               = "./modules/eventbridge"
  app_name             = var.app_name
  lambda_arn           = module.lambda[0].function_arn
  lambda_function_name = module.lambda[0].function_name
  tags                 = local.common_tags
}

module "ssm" {
  count       = var.enable_ssm ? 1 : 0
  source      = "./modules/ssm"
  app_name    = var.app_name
  environment = var.environment
  tags        = local.common_tags
}

module "kinesis" {
  count    = var.enable_kinesis ? 1 : 0
  source   = "./modules/kinesis"
  app_name = var.app_name
  tags     = local.common_tags
}

module "stepfunctions" {
  count    = var.enable_stepfunctions ? 1 : 0
  source   = "./modules/stepfunctions"
  app_name = var.app_name
}

module "apigateway" {
  count                = var.enable_apigateway && var.enable_lambda ? 1 : 0
  source               = "./modules/apigateway"
  app_name             = var.app_name
  lambda_invoke_arn    = module.lambda[0].invoke_arn
  lambda_function_name = module.lambda[0].function_name
  localstack_endpoint  = var.localstack_endpoint
  tags                 = local.common_tags
}
