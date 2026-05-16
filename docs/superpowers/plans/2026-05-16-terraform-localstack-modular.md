# Template Terraform LocalStack Modular — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrar a infra Terraform plana para uma estrutura modular com todos os serviços free do LocalStack, parametrizada por `var.app_name`.

**Architecture:** Cada serviço AWS vira um módulo Terraform independente em `infra/modules/{service}/`. O `main.tf` raiz instancia todos os módulos passando variáveis globais. Isso permite que quem faz fork habilite/desabilite serviços comentando um bloco.

**Tech Stack:** Terraform >= 1.0, AWS Provider ~> 5.0, LocalStack (free tier), Python 3.12 (Lambda handler), Docker (LAMBDA_EXECUTOR).

---

## Mapa de arquivos

| Ação | Arquivo |
|---|---|
| Modificar | `docker-compose.yml` |
| Criar | `.env.example` |
| Modificar | `infra/provider.tf` |
| Criar | `infra/variables.tf` |
| Criar | `infra/outputs.tf` |
| Reescrever | `infra/main.tf` |
| Deletar | `infra/s3.tf`, `infra/sqs.tf`, `infra/sns.tf`, `infra/dynamodb.tf`, `infra/secretsmanager.tf`, `infra/teste.txt` |
| Deletar | `infra/terraform.tfstate`, `infra/terraform.tfstate.backup` (recriar do zero no LocalStack) |
| Criar | `infra/modules/s3/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/sqs/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/sns/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/dynamodb/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/secretsmanager/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/kms/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/iam/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/lambda/main.tf`, `variables.tf`, `outputs.tf`, `src/handler.py` |
| Criar | `infra/modules/cloudwatch/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/eventbridge/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/ssm/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/kinesis/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/stepfunctions/main.tf`, `variables.tf`, `outputs.tf` |
| Criar | `infra/modules/apigateway/main.tf`, `variables.tf`, `outputs.tf` |

---

## Task 1: Atualizar docker-compose.yml e criar .env.example

**Files:**
- Modify: `docker-compose.yml`
- Create: `.env.example`

- [ ] **Step 1: Substituir o conteúdo de `docker-compose.yml`**

```yaml
services:
  localstack:
    container_name: dev_localstack
    image: localstack/localstack:latest
    ports:
      - "127.0.0.1:4566:4566"
      - "127.0.0.1:4510-4559:4510-4559"
    environment:
      - LOCALSTACK_AUTH_TOKEN=${LOCALSTACK_AUTH_TOKEN:-}
      - DEBUG=1
      - SERVICES=s3,sqs,sns,dynamodb,lambda,secretsmanager,iam,cloudwatch,logs,events,kms,ssm,kinesis,stepfunctions,apigateway
      - LAMBDA_EXECUTOR=docker
      - DOCKER_HOST=unix:///var/run/docker.sock
      - AWS_DEFAULT_REGION=us-east-1
    volumes:
      - "./infra/localstack-data:/var/lib/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    networks:
      - dev_network

networks:
  dev_network:
    driver: bridge
```

- [ ] **Step 2: Criar `.env.example` na raiz**

```
# Copie para .env e preencha se tiver conta LocalStack Pro
# Sem token, todos os serviços free continuam funcionando
LOCALSTACK_AUTH_TOKEN=
```

- [ ] **Step 3: Garantir que `.env` está no `.gitignore`**

Abrir `.gitignore` e verificar se `.env` já está listado. Se não estiver, adicionar a linha `.env` ao arquivo.

- [ ] **Step 4: Commit**

```bash
git add docker-compose.yml .env.example .gitignore
git commit -m "chore: adiciona todos os servicos localstack free no docker-compose"
```

---

## Task 2: Atualizar provider.tf e criar variables.tf

**Files:**
- Modify: `infra/provider.tf`
- Create: `infra/variables.tf`

- [ ] **Step 1: Substituir `infra/provider.tf`**

```hcl
provider "aws" {
  region = var.region

  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  s3_use_path_style = true

  endpoints {
    s3             = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    iam            = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    events         = "http://localhost:4566"
    kms            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    sfn            = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
  }
}
```

- [ ] **Step 2: Criar `infra/variables.tf`**

```hcl
variable "app_name" {
  description = "Nome da aplicação — usado como prefixo em todos os recursos"
  type        = string
  default     = "myapp"
}

variable "region" {
  description = "Região AWS (usada apenas no provider)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nome do ambiente (local, dev, staging)"
  type        = string
  default     = "local"
}
```

- [ ] **Step 3: Commit**

```bash
git add infra/provider.tf infra/variables.tf
git commit -m "chore: atualiza provider com todos os endpoints e adiciona variables"
```

---

## Task 3: Criar outputs.tf raiz

**Files:**
- Create: `infra/outputs.tf`

- [ ] **Step 1: Criar `infra/outputs.tf`**

```hcl
output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "sqs_dlq_url" {
  value = module.sqs.dlq_url
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "kms_key_arn" {
  value = module.kms.key_arn
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "lambda_function_arn" {
  value = module.lambda.function_arn
}

output "cloudwatch_log_group" {
  value = module.cloudwatch.log_group_name
}

output "kinesis_stream_name" {
  value = module.kinesis.stream_name
}

output "stepfunctions_arn" {
  value = module.stepfunctions.state_machine_arn
}

output "api_gateway_id" {
  value = module.apigateway.api_id
}

output "api_gateway_url" {
  value = module.apigateway.api_url
}
```

- [ ] **Step 2: Commit**

```bash
git add infra/outputs.tf
git commit -m "chore: adiciona outputs centralizados da infra"
```

---

## Task 4: Módulo S3

**Files:**
- Create: `infra/modules/s3/variables.tf`
- Create: `infra/modules/s3/main.tf`
- Create: `infra/modules/s3/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/s3/variables.tf`**

```hcl
variable "app_name" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/s3/main.tf`**

```hcl
resource "aws_s3_bucket" "storage" {
  bucket = "${var.app_name}-storage"
}
```

- [ ] **Step 3: Criar `infra/modules/s3/outputs.tf`**

```hcl
output "bucket_name" {
  value = aws_s3_bucket.storage.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.storage.arn
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/s3/
git commit -m "feat: adiciona modulo s3"
```

---

## Task 5: Módulo SQS (com DLQ)

**Files:**
- Create: `infra/modules/sqs/variables.tf`
- Create: `infra/modules/sqs/main.tf`
- Create: `infra/modules/sqs/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/sqs/variables.tf`**

```hcl
variable "app_name" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/sqs/main.tf`**

```hcl
resource "aws_sqs_queue" "dlq" {
  name = "${var.app_name}-queue-dlq"
}

resource "aws_sqs_queue" "main" {
  name = "${var.app_name}-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}
```

- [ ] **Step 3: Criar `infra/modules/sqs/outputs.tf`**

```hcl
output "queue_url" {
  value = aws_sqs_queue.main.url
}

output "queue_arn" {
  value = aws_sqs_queue.main.arn
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/sqs/
git commit -m "feat: adiciona modulo sqs com DLQ"
```

---

## Task 6: Módulo SNS

**Files:**
- Create: `infra/modules/sns/variables.tf`
- Create: `infra/modules/sns/main.tf`
- Create: `infra/modules/sns/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/sns/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "sqs_queue_arn" {
  type        = string
  description = "ARN da fila SQS que receberá mensagens do tópico"
}
```

- [ ] **Step 2: Criar `infra/modules/sns/main.tf`**

```hcl
resource "aws_sns_topic" "events" {
  name = "${var.app_name}-events"
}

resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.events.arn
  protocol  = "sqs"
  endpoint  = var.sqs_queue_arn
}
```

- [ ] **Step 3: Criar `infra/modules/sns/outputs.tf`**

```hcl
output "topic_arn" {
  value = aws_sns_topic.events.arn
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/sns/
git commit -m "feat: adiciona modulo sns com subscription para sqs"
```

---

## Task 7: Módulo DynamoDB

**Files:**
- Create: `infra/modules/dynamodb/variables.tf`
- Create: `infra/modules/dynamodb/main.tf`
- Create: `infra/modules/dynamodb/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/dynamodb/variables.tf`**

```hcl
variable "app_name" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/dynamodb/main.tf`**

```hcl
resource "aws_dynamodb_table" "main" {
  name         = "${var.app_name}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
```

- [ ] **Step 3: Criar `infra/modules/dynamodb/outputs.tf`**

```hcl
output "table_name" {
  value = aws_dynamodb_table.main.name
}

output "table_arn" {
  value = aws_dynamodb_table.main.arn
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/dynamodb/
git commit -m "feat: adiciona modulo dynamodb"
```

---

## Task 8: Módulo Secrets Manager

**Files:**
- Create: `infra/modules/secretsmanager/variables.tf`
- Create: `infra/modules/secretsmanager/main.tf`
- Create: `infra/modules/secretsmanager/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/secretsmanager/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/secretsmanager/main.tf`**

```hcl
resource "aws_secretsmanager_secret" "app" {
  name = "${var.environment}/${var.app_name}/credentials"
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    api_key     = "local-key-123"
    db_password = "local-password"
  })
}
```

- [ ] **Step 3: Criar `infra/modules/secretsmanager/outputs.tf`**

```hcl
output "secret_arn" {
  value = aws_secretsmanager_secret.app.arn
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/secretsmanager/
git commit -m "feat: adiciona modulo secretsmanager"
```

---

## Task 9: Módulo KMS

**Files:**
- Create: `infra/modules/kms/variables.tf`
- Create: `infra/modules/kms/main.tf`
- Create: `infra/modules/kms/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/kms/variables.tf`**

```hcl
variable "app_name" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/kms/main.tf`**

```hcl
resource "aws_kms_key" "main" {
  description             = "Chave KMS para ${var.app_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.app_name}-key"
  target_key_id = aws_kms_key.main.key_id
}
```

- [ ] **Step 3: Criar `infra/modules/kms/outputs.tf`**

```hcl
output "key_arn" {
  value = aws_kms_key.main.arn
}

output "key_id" {
  value = aws_kms_key.main.key_id
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/kms/
git commit -m "feat: adiciona modulo kms"
```

---

## Task 10: Módulo IAM

**Files:**
- Create: `infra/modules/iam/variables.tf`
- Create: `infra/modules/iam/main.tf`
- Create: `infra/modules/iam/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/iam/variables.tf`**

```hcl
variable "app_name" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/iam/main.tf`**

```hcl
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.app_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.app_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "*"
      }
    ]
  })
}
```

- [ ] **Step 3: Criar `infra/modules/iam/outputs.tf`**

```hcl
output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  value = aws_iam_role.lambda.name
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/iam/
git commit -m "feat: adiciona modulo iam com role para lambda"
```

---

## Task 11: Módulo Lambda

**Files:**
- Create: `infra/modules/lambda/variables.tf`
- Create: `infra/modules/lambda/main.tf`
- Create: `infra/modules/lambda/outputs.tf`
- Create: `infra/modules/lambda/src/handler.py`

- [ ] **Step 1: Criar `infra/modules/lambda/src/handler.py`**

```python
import json
import os

def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from LocalStack Lambda!",
            "app": os.environ.get("APP_NAME", "unknown"),
            "event": event
        })
    }
```

- [ ] **Step 2: Criar `infra/modules/lambda/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "role_arn" {
  type        = string
  description = "ARN da IAM role de execução da função"
}
```

- [ ] **Step 3: Criar `infra/modules/lambda/main.tf`**

```hcl
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

  environment {
    variables = {
      APP_NAME = var.app_name
    }
  }
}
```

- [ ] **Step 4: Criar `infra/modules/lambda/outputs.tf`**

```hcl
output "function_name" {
  value = aws_lambda_function.main.function_name
}

output "function_arn" {
  value = aws_lambda_function.main.arn
}

output "invoke_arn" {
  value = aws_lambda_function.main.invoke_arn
}
```

- [ ] **Step 5: Adicionar `handler.zip` ao `.gitignore`**

Adicionar a linha `infra/modules/lambda/src/handler.zip` ao `.gitignore` para não versionar o artefato gerado.

- [ ] **Step 6: Commit**

```bash
git add infra/modules/lambda/ .gitignore
git commit -m "feat: adiciona modulo lambda com handler python"
```

---

## Task 12: Módulo CloudWatch

**Files:**
- Create: `infra/modules/cloudwatch/variables.tf`
- Create: `infra/modules/cloudwatch/main.tf`
- Create: `infra/modules/cloudwatch/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/cloudwatch/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda para criar o log group e o alarme"
}
```

- [ ] **Step 2: Criar `infra/modules/cloudwatch/main.tf`**

```hcl
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.app_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarme disparado quando Lambda retorna erro"

  dimensions = {
    FunctionName = var.lambda_function_name
  }
}
```

- [ ] **Step 3: Criar `infra/modules/cloudwatch/outputs.tf`**

```hcl
output "log_group_name" {
  value = aws_cloudwatch_log_group.lambda.name
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.lambda_errors.alarm_name
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/cloudwatch/
git commit -m "feat: adiciona modulo cloudwatch com log group e alarme"
```

---

## Task 13: Módulo EventBridge

**Files:**
- Create: `infra/modules/eventbridge/variables.tf`
- Create: `infra/modules/eventbridge/main.tf`
- Create: `infra/modules/eventbridge/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/eventbridge/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "lambda_arn" {
  type        = string
  description = "ARN da função Lambda alvo do agendamento"
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda (necessário para aws_lambda_permission)"
}
```

- [ ] **Step 2: Criar `infra/modules/eventbridge/main.tf`**

```hcl
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.app_name}-schedule"
  description         = "Aciona ${var.app_name} Lambda a cada 5 minutos"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = var.lambda_arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
```

- [ ] **Step 3: Criar `infra/modules/eventbridge/outputs.tf`**

```hcl
output "rule_arn" {
  value = aws_cloudwatch_event_rule.schedule.arn
}

output "rule_name" {
  value = aws_cloudwatch_event_rule.schedule.name
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/eventbridge/
git commit -m "feat: adiciona modulo eventbridge com schedule para lambda"
```

---

## Task 14: Módulo SSM Parameter Store

**Files:**
- Create: `infra/modules/ssm/variables.tf`
- Create: `infra/modules/ssm/main.tf`
- Create: `infra/modules/ssm/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/ssm/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/ssm/main.tf`**

```hcl
resource "aws_ssm_parameter" "env" {
  name  = "/${var.app_name}/config/env"
  type  = "String"
  value = var.environment
}

resource "aws_ssm_parameter" "log_level" {
  name  = "/${var.app_name}/config/log_level"
  type  = "String"
  value = "INFO"
}
```

- [ ] **Step 3: Criar `infra/modules/ssm/outputs.tf`**

```hcl
output "env_parameter_name" {
  value = aws_ssm_parameter.env.name
}

output "log_level_parameter_name" {
  value = aws_ssm_parameter.log_level.name
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/ssm/
git commit -m "feat: adiciona modulo ssm parameter store"
```

---

## Task 15: Módulo Kinesis

**Files:**
- Create: `infra/modules/kinesis/variables.tf`
- Create: `infra/modules/kinesis/main.tf`
- Create: `infra/modules/kinesis/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/kinesis/variables.tf`**

```hcl
variable "app_name" {
  type = string
}
```

- [ ] **Step 2: Criar `infra/modules/kinesis/main.tf`**

```hcl
resource "aws_kinesis_stream" "main" {
  name             = "${var.app_name}-stream"
  shard_count      = 1
  retention_period = 24
}
```

- [ ] **Step 3: Criar `infra/modules/kinesis/outputs.tf`**

```hcl
output "stream_name" {
  value = aws_kinesis_stream.main.name
}

output "stream_arn" {
  value = aws_kinesis_stream.main.arn
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/kinesis/
git commit -m "feat: adiciona modulo kinesis data stream"
```

---

## Task 16: Módulo Step Functions

**Files:**
- Create: `infra/modules/stepfunctions/variables.tf`
- Create: `infra/modules/stepfunctions/main.tf`
- Create: `infra/modules/stepfunctions/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/stepfunctions/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN da IAM role usada pela state machine"
}
```

- [ ] **Step 2: Criar `infra/modules/stepfunctions/main.tf`**

```hcl
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
```

- [ ] **Step 3: Criar `infra/modules/stepfunctions/outputs.tf`**

```hcl
output "state_machine_arn" {
  value = aws_sfn_state_machine.main.arn
}

output "state_machine_name" {
  value = aws_sfn_state_machine.main.name
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/stepfunctions/
git commit -m "feat: adiciona modulo step functions"
```

---

## Task 17: Módulo API Gateway

**Files:**
- Create: `infra/modules/apigateway/variables.tf`
- Create: `infra/modules/apigateway/main.tf`
- Create: `infra/modules/apigateway/outputs.tf`

- [ ] **Step 1: Criar `infra/modules/apigateway/variables.tf`**

```hcl
variable "app_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type        = string
  description = "invoke_arn da função Lambda (formato arn:aws:apigateway:...)"
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda (necessário para aws_lambda_permission)"
}
```

- [ ] **Step 2: Criar `infra/modules/apigateway/main.tf`**

```hcl
resource "aws_api_gateway_rest_api" "main" {
  name = "${var.app_name}-api"
}

resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.health_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [aws_api_gateway_integration.health_lambda]
}

resource "aws_api_gateway_stage" "local" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.main.id
  stage_name    = "local"
}

resource "aws_lambda_permission" "apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}
```

- [ ] **Step 3: Criar `infra/modules/apigateway/outputs.tf`**

```hcl
output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_url" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.main.id}/local/_user_request_/health"
}
```

- [ ] **Step 4: Commit**

```bash
git add infra/modules/apigateway/
git commit -m "feat: adiciona modulo api gateway com rota /health"
```

---

## Task 18: Reescrever main.tf e remover arquivos planos

**Files:**
- Rewrite: `infra/main.tf`
- Delete: `infra/s3.tf`, `infra/sqs.tf`, `infra/sns.tf`, `infra/dynamodb.tf`, `infra/secretsmanager.tf`, `infra/teste.txt`
- Delete: `infra/terraform.tfstate`, `infra/terraform.tfstate.backup`

- [ ] **Step 1: Substituir `infra/main.tf`**

```hcl
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
  source          = "./modules/stepfunctions"
  app_name        = var.app_name
  lambda_role_arn = module.iam.lambda_role_arn
}

module "apigateway" {
  source               = "./modules/apigateway"
  app_name             = var.app_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}
```

- [ ] **Step 2: Deletar os arquivos planos antigos**

```bash
cd infra
rm s3.tf sqs.tf sns.tf dynamodb.tf secretsmanager.tf teste.txt
rm -f terraform.tfstate terraform.tfstate.backup
```

- [ ] **Step 3: Commit**

```bash
git add infra/main.tf
git rm infra/s3.tf infra/sqs.tf infra/sns.tf infra/dynamodb.tf infra/secretsmanager.tf infra/teste.txt
git commit -m "feat: reescreve main.tf com estrutura modular e remove arquivos planos"
```

---

## Task 19: Verificação final — terraform init + apply

**Pré-requisito:** LocalStack deve estar rodando (`docker compose up -d`).

- [ ] **Step 1: Subir o LocalStack**

```bash
docker compose up -d
```

Aguardar o container ficar `healthy`:
```bash
docker compose ps
```
Esperado: `dev_localstack` com status `Up` ou `healthy`.

- [ ] **Step 2: Rodar `terraform init`**

```bash
cd infra
terraform init
```

Esperado: `Terraform has been successfully initialized!`

- [ ] **Step 3: Rodar `terraform validate`**

```bash
terraform validate
```

Esperado: `Success! The configuration is valid.`

- [ ] **Step 4: Rodar `terraform plan`**

```bash
terraform plan
```

Esperado: plano listando criação dos recursos de todos os 14 módulos, sem erros.

- [ ] **Step 5: Rodar `terraform apply`**

```bash
terraform apply -auto-approve
```

Esperado: `Apply complete! Resources: X added, 0 changed, 0 destroyed.`

- [ ] **Step 6: Verificar S3**

```bash
aws s3 ls --endpoint-url http://localhost:4566 --region us-east-1
```

Esperado: `myapp-storage`

- [ ] **Step 7: Verificar SQS**

```bash
aws sqs list-queues --endpoint-url http://localhost:4566 --region us-east-1
```

Esperado: URLs das filas `myapp-queue` e `myapp-queue-dlq`

- [ ] **Step 8: Verificar Lambda**

```bash
aws lambda list-functions --endpoint-url http://localhost:4566 --region us-east-1
```

Esperado: função `myapp-fn` na lista.

- [ ] **Step 9: Invocar Lambda**

```bash
aws lambda invoke \
  --endpoint-url http://localhost:4566 \
  --region us-east-1 \
  --function-name myapp-fn \
  --payload '{}' \
  /tmp/lambda-response.json && cat /tmp/lambda-response.json
```

Esperado:
```json
{"statusCode": 200, "body": "{\"message\": \"Hello from LocalStack Lambda!\", \"app\": \"myapp\", \"event\": {}}"}
```

- [ ] **Step 10: Verificar Kinesis**

```bash
aws kinesis list-streams --endpoint-url http://localhost:4566 --region us-east-1
```

Esperado: `myapp-stream`

- [ ] **Step 11: Verificar Step Functions**

```bash
aws stepfunctions list-state-machines --endpoint-url http://localhost:4566 --region us-east-1
```

Esperado: `myapp-state-machine`

- [ ] **Step 12: Verificar outputs do Terraform**

```bash
terraform output
```

Esperado: todos os outputs preenchidos com valores reais (ARNs, nomes, URLs).

- [ ] **Step 13: Commit final**

```bash
git add infra/.terraform.lock.hcl
git commit -m "chore: atualiza lock file apos terraform init com estrutura modular"
```

> **Nota:** O `terraform.tfstate` já está no `.gitignore`. Para ambientes reais (AWS), use backend remoto (S3 + DynamoDB lock). O `.terraform.lock.hcl` deve ser versionado para garantir versões de provider consistentes entre desenvolvedores.
