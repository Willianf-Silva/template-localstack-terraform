locals {
  state_machine_name = "${var.app_name}-state-machine"
  state_machine_arn  = "arn:aws:states:us-east-1:000000000000:stateMachine:${var.app_name}-state-machine"
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

# O provider AWS >= 5.26 chama ValidateStateMachineDefinition que nao existe
# no LocalStack community. Criamos via CLI para contornar a validacao do provider.
resource "terraform_data" "sfn_state_machine" {
  input = {
    arn = local.state_machine_arn
  }

  triggers_replace = [
    local.state_machine_name,
    aws_iam_role.sfn.arn,
    local.definition,
  ]

  provisioner "local-exec" {
    environment = {
      ENDPOINT   = "http://localhost:4566"
      NAME       = local.state_machine_name
      ROLE_ARN   = aws_iam_role.sfn.arn
      DEFINITION = local.definition
    }
    command = <<-EOT
      aws --endpoint-url "$ENDPOINT" --region us-east-1 \
        sfn create-state-machine \
        --name "$NAME" \
        --role-arn "$ROLE_ARN" \
        --type EXPRESS \
        --definition "$DEFINITION"
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    environment = {
      ENDPOINT = "http://localhost:4566"
      ARN      = self.input.arn
    }
    command = <<-EOT
      aws --endpoint-url "$ENDPOINT" --region us-east-1 \
        sfn delete-state-machine \
        --state-machine-arn "$ARN" 2>/dev/null || true
    EOT
  }

  depends_on = [aws_iam_role.sfn]
}
