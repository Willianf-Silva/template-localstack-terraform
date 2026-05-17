locals {
  default_parameters = {
    env       = var.environment
    log_level = var.log_level
  }
  all_parameters = merge(local.default_parameters, var.extra_parameters)
}

resource "aws_ssm_parameter" "params" {
  for_each = local.all_parameters

  name  = "/${var.app_name}/config/${each.key}"
  type  = "String"
  value = each.value
  tags  = var.tags
}
