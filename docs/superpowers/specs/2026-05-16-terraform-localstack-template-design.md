# Design: Template Terraform + LocalStack Free Tier

**Data:** 2026-05-16  
**Status:** Aprovado  
**Objetivo:** Starter de projetos + ambiente de desenvolvimento local simulando AWS com todos os serviços disponíveis no LocalStack free tier, usando estrutura modular Terraform.

---

## 1. Contexto

O repositório `template-localstack-terraform` serve como ponto de partida para novos projetos que precisam simular serviços AWS localmente sem custo. A pasta `infra/` contém a infraestrutura Terraform e `app/` a aplicação (Spring Boot).

Estado atual da `infra/`: S3, SQS, SNS (com subscription para SQS), DynamoDB e Secrets Manager — todos em arquivos `.tf` planos, sem parametrização.

---

## 2. Decisões de design

| Decisão | Escolha | Motivo |
|---|---|---|
| Organização | Módulos Terraform | Permite habilitar/desabilitar serviços comentando um bloco no `main.tf` |
| Lambda executor | `docker` | Execução real de funções no LocalStack free tier requer Docker socket |
| Empacotamento Lambda | `archive_file` data source | Zero dependências externas de build |
| Parametrização | `var.app_name` global | Quem faz fork altera só uma variável para renomear todos os recursos |
| Auth token LocalStack | Opcional via `.env.example` | Free tier funciona sem token; Pro adiciona persistência e mais serviços |

---

## 3. Estrutura de arquivos

```
infra/
├── provider.tf          (atualizar endpoints para todos os serviços)
├── version.tf           (sem alteração)
├── variables.tf         (novo — app_name, region, environment)
├── outputs.tf           (novo — ARNs/URLs centralizados)
├── main.tf              (reescrever — chama módulos)
│
└── modules/
    ├── s3/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── sqs/
    │   ├── main.tf      (fila principal + DLQ)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── sns/
    │   ├── main.tf      (tópico + subscription SQS)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── dynamodb/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── secretsmanager/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/
    │   ├── main.tf      (role + policies para Lambda)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── lambda/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── src/
    │       └── handler.py
    ├── cloudwatch/
    │   ├── main.tf      (log group + alarme de erro)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eventbridge/
    │   ├── main.tf      (rule de schedule rate(5 minutes) → Lambda)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── kms/
    │   ├── main.tf      (chave simétrica SYMMETRIC_DEFAULT)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ssm/
    │   ├── main.tf      (parâmetros /{app_name}/config/*)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── kinesis/
    │   ├── main.tf      (data stream 1 shard)
    │   ├── variables.tf
    │   └── outputs.tf
    ├── stepfunctions/
    │   ├── main.tf      (state machine com 2 estados Pass)
    │   ├── variables.tf
    │   └── outputs.tf
    └── apigateway/
        ├── main.tf      (REST API + recurso /health + integração Lambda)
        ├── variables.tf
        └── outputs.tf
```

---

## 4. Serviços incluídos

### Migrados para módulos (existentes)

| Módulo | Recurso | Nome padrão |
|---|---|---|
| `s3` | `aws_s3_bucket` | `{app_name}-storage` |
| `sqs` | `aws_sqs_queue` (principal + DLQ) | `{app_name}-queue`, `{app_name}-queue-dlq` |
| `sns` | `aws_sns_topic` + subscription SQS | `{app_name}-events` |
| `dynamodb` | `aws_dynamodb_table` | `{app_name}-table` |
| `secretsmanager` | `aws_secretsmanager_secret` | `dev/{app_name}/credentials` |

### Novos módulos

| Módulo | Recurso | Detalhes |
|---|---|---|
| `iam` | `aws_iam_role` + `aws_iam_role_policy` | Assume role para Lambda; permissões: CloudWatch Logs, S3 read, SQS receive |
| `lambda` | `aws_lambda_function` | Python 3.12, handler.py empacotado por `archive_file`, recebe role ARN do módulo `iam` |
| `cloudwatch` | `aws_cloudwatch_log_group` + `aws_cloudwatch_metric_alarm` | Log group `/aws/lambda/{app_name}`, alarme em cima de `Errors` |
| `eventbridge` | `aws_cloudwatch_event_rule` + target | Schedule `rate(5 minutes)` → Lambda |
| `kms` | `aws_kms_key` + `aws_kms_alias` | Chave simétrica, alias `alias/{app_name}-key` |
| `ssm` | `aws_ssm_parameter` | `/{app_name}/config/env` e `/{app_name}/config/log_level` |
| `kinesis` | `aws_kinesis_stream` | 1 shard, retenção 24h |
| `stepfunctions` | `aws_sfn_state_machine` | State machine `EXPRESS` com dois estados `Pass` |
| `apigateway` | `aws_api_gateway_rest_api` + resource + method + integration | REST API, recurso `/health`, `GET` integrado ao Lambda |

---

## 5. provider.tf — endpoints atualizados

Todos os serviços novos precisam de endpoint apontando para `http://localhost:4566`:

```hcl
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
  events         = "http://localhost:4566"   # EventBridge
  kms            = "http://localhost:4566"
  ssm            = "http://localhost:4566"
  kinesis        = "http://localhost:4566"
  sfn            = "http://localhost:4566"   # StepFunctions
  apigateway     = "http://localhost:4566"
}
```

---

## 6. docker-compose.yml — ajustes

```yaml
environment:
  - SERVICES=s3,sqs,sns,dynamodb,lambda,secretsmanager,
             iam,cloudwatch,logs,events,kms,ssm,kinesis,
             stepfunctions,apigateway
  - LAMBDA_EXECUTOR=docker
volumes:
  - ./infra/localstack-data:/var/lib/localstack
  - /var/run/docker.sock:/var/run/docker.sock
```

Adicionar `.env.example` na raiz com:
```
LOCALSTACK_AUTH_TOKEN=   # opcional — necessário apenas para features Pro
```

---

## 7. variables.tf (raiz)

```hcl
variable "app_name" {
  default = "myapp"
}
variable "region" {
  default = "us-east-1"
}
variable "environment" {
  default = "local"
}
```

---

## 8. Fluxo de dependências entre módulos

```
kms ──────────────────────────────────────────────┐
                                                   ↓
iam ──────────────────────────────────────────→ lambda
                                                   ↓
cloudwatch ←───────────────────────────────────────┤
eventbridge ←──────────────────────────────────────┤
apigateway ←───────────────────────────────────────┘

sqs ←── sns (subscription)
sqs ←── lambda (trigger opcional, não obrigatório no template)
```

O `main.tf` garante essa ordem passando outputs entre módulos (ex: `module.iam.role_arn` → `module.lambda.role_arn`).

---

## 9. Critérios de sucesso

- `terraform init && terraform apply` sem erros com LocalStack rodando
- Todos os recursos aparecem no LocalStack (`awslocal s3 ls`, `awslocal lambda list-functions`, etc.)
- Função Lambda invocável via `awslocal lambda invoke`
- API Gateway responde em `http://localhost:4566/restapis/{id}/local/_user_request_/health`
- Quem faz fork: só muda `var.app_name` em `variables.tf` para renomear tudo

---

## 10. Fora do escopo

- Serviços LocalStack Pro (RDS, Cognito, ECS, EKS, OpenSearch, MSK, Athena, Glue)
- CI/CD pipeline
- Múltiplos ambientes (dev/staging/prod) — o template é `local` apenas
- Testes automatizados de infra (Terratest)
