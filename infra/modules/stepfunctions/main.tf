data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn" {
  name               = "${var.app_name}-sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json
}

resource "aws_sfn_state_machine" "main" {
  name     = "${var.app_name}-state-machine"
  role_arn = aws_iam_role.sfn.arn
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
