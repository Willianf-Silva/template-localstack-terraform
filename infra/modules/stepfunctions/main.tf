resource "aws_sfn_state_machine" "main" {
  name     = "${var.app_name}-state-machine"
  role_arn = var.lambda_role_arn
  type     = "EXPRESS"

  definition = jsonencode({
    Comment = "State machine de exemplo para ${var.app_name}"
    StartAt = "PrimeiroEstado"
    States = {
      PrimeiroEstado = {
        Type   = "Pass"
        Result = { etapa = "primeiro" }
        Next   = "SegundoEstado"
      }
      SegundoEstado = {
        Type   = "Pass"
        Result = { etapa = "segundo" }
        End    = true
      }
    }
  })
}
