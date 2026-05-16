# template-localstack-terraform

Template de infraestrutura AWS local usando **Terraform** + **LocalStack** (free tier). Simula 14 serviços AWS sem custo, ideal como starter de projetos ou ambiente de desenvolvimento local.

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Docker Desktop | 24+ |
| Terraform | 1.0+ |
| AWS CLI | 2.x |

---

## Estrutura do projeto

```
.
├── docker-compose.yml          # LocalStack container
├── .env.example                # Variáveis de ambiente (copie para .env)
├── infra/
│   ├── provider.tf             # Provider AWS apontando para LocalStack
│   ├── variables.tf            # app_name, region, environment
│   ├── outputs.tf              # ARNs e URLs centralizados
│   ├── main.tf                 # Instancia todos os módulos
│   └── modules/
│       ├── s3/                 # Bucket de storage
│       ├── sqs/                # Fila + Dead Letter Queue
│       ├── sns/                # Tópico de eventos
│       ├── dynamodb/           # Banco NoSQL
│       ├── secretsmanager/     # Gerenciador de segredos
│       ├── kms/                # Chave de criptografia
│       ├── iam/                # Role de execução Lambda
│       ├── lambda/             # Função serverless (Python 3.12)
│       ├── cloudwatch/         # Logs e alarmes
│       ├── eventbridge/        # Agendamento de eventos
│       ├── ssm/                # Parâmetros de configuração
│       ├── kinesis/            # Stream de dados
│       ├── stepfunctions/      # Orquestração de fluxos
│       └── apigateway/         # REST API
└── app/                        # Aplicação (Spring Boot — opcional)
```

---

## Quick Start

### 1. Configurar variáveis de ambiente

```bash
cp .env.example .env
# Edite .env se tiver token LocalStack Pro (opcional)
```

### 2. Subir o LocalStack

```bash
docker compose up -d
```

Aguarde o container ficar saudável:
```bash
docker compose ps
# Status esperado: "Up" ou "healthy"
```

### 3. Aplicar a infraestrutura

```bash
cd infra
terraform init
terraform apply -auto-approve
```

### 4. Verificar os recursos criados

```bash
terraform output
```

---

## Personalização

Edite `infra/variables.tf` para renomear todos os recursos de uma vez:

```hcl
variable "app_name" {
  default = "minha-app"   # <-- altere aqui
}
```

Todos os recursos seguem o padrão `{app_name}-{servico}`. Com `app_name = "myapp"` (padrão):

| Serviço | Nome do recurso |
|---|---|
| S3 | `myapp-storage` |
| SQS | `myapp-queue` / `myapp-queue-dlq` |
| SNS | `myapp-events` |
| DynamoDB | `myapp-table` |
| Lambda | `myapp-fn` |
| Kinesis | `myapp-stream` |
| Step Functions | `myapp-state-machine` |
| API Gateway | `myapp-api` |

---

## Serviços disponíveis

> Todos os comandos usam `--endpoint-url http://localhost:4566 --region us-east-1`.
> Para simplificar, configure um profile AWS local:
>
> ```bash
> aws configure --profile localstack
> # Access Key: test | Secret Key: test | Region: us-east-1 | Output: json
> ```
>
> Depois use `--profile localstack` no lugar de `--endpoint-url`.

---

### S3 — Object Storage

Bucket para armazenamento de arquivos e objetos.

```bash
# Listar buckets
aws s3 ls --endpoint-url http://localhost:4566

# Enviar arquivo
aws s3 cp arquivo.txt s3://myapp-storage/ --endpoint-url http://localhost:4566

# Listar objetos do bucket
aws s3 ls s3://myapp-storage/ --endpoint-url http://localhost:4566

# Baixar arquivo
aws s3 cp s3://myapp-storage/arquivo.txt ./arquivo-baixado.txt --endpoint-url http://localhost:4566

# Deletar objeto
aws s3 rm s3://myapp-storage/arquivo.txt --endpoint-url http://localhost:4566
```

---

### SQS — Filas de Mensagens

Fila principal com Dead Letter Queue (DLQ) configurada. Mensagens que falham 3 vezes vão para a DLQ.

```bash
# Listar filas
aws sqs list-queues --endpoint-url http://localhost:4566

# Enviar mensagem
aws sqs send-message \
  --endpoint-url http://localhost:4566 \
  --queue-url http://localhost:4566/000000000000/myapp-queue \
  --message-body '{"evento": "pedido_criado", "id": "123"}'

# Receber mensagem
aws sqs receive-message \
  --endpoint-url http://localhost:4566 \
  --queue-url http://localhost:4566/000000000000/myapp-queue \
  --max-number-of-messages 5

# Deletar mensagem (use o ReceiptHandle retornado no receive)
aws sqs delete-message \
  --endpoint-url http://localhost:4566 \
  --queue-url http://localhost:4566/000000000000/myapp-queue \
  --receipt-handle <ReceiptHandle>

# Ver mensagens na DLQ
aws sqs receive-message \
  --endpoint-url http://localhost:4566 \
  --queue-url http://localhost:4566/000000000000/myapp-queue-dlq
```

---

### SNS — Tópico de Eventos

Tópico pub/sub com subscription automática para a fila SQS. Mensagens publicadas no tópico chegam na fila.

```bash
# Listar tópicos
aws sns list-topics --endpoint-url http://localhost:4566

# Publicar mensagem no tópico (entrega na fila SQS automaticamente)
aws sns publish \
  --endpoint-url http://localhost:4566 \
  --topic-arn arn:aws:sns:us-east-1:000000000000:myapp-events \
  --message '{"tipo": "notificacao", "conteudo": "Olá!"}'

# Listar subscriptions
aws sns list-subscriptions --endpoint-url http://localhost:4566
```

---

### DynamoDB — Banco de Dados NoSQL

Tabela com `id` como chave primária (String), modo PAY_PER_REQUEST.

```bash
# Listar tabelas
aws dynamodb list-tables --endpoint-url http://localhost:4566

# Inserir item
aws dynamodb put-item \
  --endpoint-url http://localhost:4566 \
  --table-name myapp-table \
  --item '{"id": {"S": "1"}, "nome": {"S": "João"}, "ativo": {"BOOL": true}}'

# Buscar item por chave
aws dynamodb get-item \
  --endpoint-url http://localhost:4566 \
  --table-name myapp-table \
  --key '{"id": {"S": "1"}}'

# Listar todos os itens
aws dynamodb scan \
  --endpoint-url http://localhost:4566 \
  --table-name myapp-table

# Deletar item
aws dynamodb delete-item \
  --endpoint-url http://localhost:4566 \
  --table-name myapp-table \
  --key '{"id": {"S": "1"}}'
```

---

### Secrets Manager — Gerenciador de Segredos

Armazena credenciais e configurações sensíveis. O secret padrão contém `api_key` e `db_password`.

```bash
# Listar secrets
aws secretsmanager list-secrets --endpoint-url http://localhost:4566

# Ler o valor do secret
aws secretsmanager get-secret-value \
  --endpoint-url http://localhost:4566 \
  --secret-id local/myapp/credentials

# Atualizar o valor do secret
aws secretsmanager put-secret-value \
  --endpoint-url http://localhost:4566 \
  --secret-id local/myapp/credentials \
  --secret-string '{"api_key": "nova-key", "db_password": "nova-senha"}'
```

---

### KMS — Chave de Criptografia

Chave simétrica para criptografar dados em repouso.

```bash
# Listar aliases
aws kms list-aliases --endpoint-url http://localhost:4566

# Criptografar texto
aws kms encrypt \
  --endpoint-url http://localhost:4566 \
  --key-id alias/myapp-key \
  --plaintext "texto-secreto" \
  --query CiphertextBlob \
  --output text

# Descriptografar (passe o CiphertextBlob retornado acima)
aws kms decrypt \
  --endpoint-url http://localhost:4566 \
  --ciphertext-blob <CiphertextBlob> \
  --query Plaintext \
  --output text | base64 --decode
```

---

### Lambda — Função Serverless

Função Python 3.12 de exemplo que retorna um JSON com a mensagem recebida. Usa a IAM role criada pelo módulo `iam`.

```bash
# Listar funções
aws lambda list-functions --endpoint-url http://localhost:4566

# Invocar a função
aws lambda invoke \
  --endpoint-url http://localhost:4566 \
  --region us-east-1 \
  --function-name myapp-fn \
  --payload '{"chave": "valor"}' \
  /tmp/resposta.json && cat /tmp/resposta.json

# Ver logs (CloudWatch Logs)
aws logs get-log-events \
  --endpoint-url http://localhost:4566 \
  --log-group-name /aws/lambda/myapp-fn \
  --log-stream-name $(aws logs describe-log-streams \
    --endpoint-url http://localhost:4566 \
    --log-group-name /aws/lambda/myapp-fn \
    --query 'logStreams[0].logStreamName' \
    --output text)
```

O código-fonte da função está em `infra/modules/lambda/src/handler.py`. Para atualizar o código, edite o arquivo e rode `terraform apply`.

---

### CloudWatch — Logs e Alarmes

Log group criado automaticamente para a Lambda. Alarme disparado quando a função retorna erro.

```bash
# Listar log groups
aws logs describe-log-groups --endpoint-url http://localhost:4566

# Ver logs da Lambda em tempo real
aws logs tail /aws/lambda/myapp-fn \
  --endpoint-url http://localhost:4566

# Listar alarmes
aws cloudwatch describe-alarms \
  --endpoint-url http://localhost:4566

# Ver estado do alarme
aws cloudwatch describe-alarms \
  --endpoint-url http://localhost:4566 \
  --alarm-names myapp-lambda-errors \
  --query 'MetricAlarms[0].StateValue'
```

---

### EventBridge — Agendamento de Eventos

Rule configurada para disparar a Lambda a cada 5 minutos automaticamente.

```bash
# Listar regras
aws events list-rules --endpoint-url http://localhost:4566

# Ver detalhes da regra de schedule
aws events describe-rule \
  --endpoint-url http://localhost:4566 \
  --name myapp-schedule

# Ver targets da regra (Lambda)
aws events list-targets-by-rule \
  --endpoint-url http://localhost:4566 \
  --rule myapp-schedule

# Disparar evento manualmente
aws events put-events \
  --endpoint-url http://localhost:4566 \
  --entries '[{
    "Source": "myapp",
    "DetailType": "evento-manual",
    "Detail": "{\"acao\": \"teste\"}"
  }]'
```

---

### SSM Parameter Store — Parâmetros de Configuração

Armazena configurações da aplicação. Dois parâmetros criados por padrão: `env` e `log_level`.

```bash
# Listar parâmetros
aws ssm describe-parameters --endpoint-url http://localhost:4566

# Ler parâmetro de ambiente
aws ssm get-parameter \
  --endpoint-url http://localhost:4566 \
  --name /myapp/config/env \
  --query Parameter.Value \
  --output text

# Ler parâmetro de log level
aws ssm get-parameter \
  --endpoint-url http://localhost:4566 \
  --name /myapp/config/log_level \
  --query Parameter.Value \
  --output text

# Atualizar parâmetro
aws ssm put-parameter \
  --endpoint-url http://localhost:4566 \
  --name /myapp/config/log_level \
  --value DEBUG \
  --type String \
  --overwrite
```

---

### Kinesis — Stream de Dados

Data stream com 1 shard e retenção de 24 horas para processamento de eventos em tempo real.

```bash
# Listar streams
aws kinesis list-streams --endpoint-url http://localhost:4566

# Enviar registro para o stream
aws kinesis put-record \
  --endpoint-url http://localhost:4566 \
  --stream-name myapp-stream \
  --partition-key "chave-1" \
  --data '{"evento": "clique", "usuario": "user-42"}'

# Obter shard iterator para leitura
SHARD_ITERATOR=$(aws kinesis get-shard-iterator \
  --endpoint-url http://localhost:4566 \
  --stream-name myapp-stream \
  --shard-id shardId-000000000000 \
  --shard-iterator-type TRIM_HORIZON \
  --query ShardIterator \
  --output text)

# Ler registros do stream
aws kinesis get-records \
  --endpoint-url http://localhost:4566 \
  --shard-iterator $SHARD_ITERATOR
```

---

### Step Functions — Orquestração de Fluxos

State machine `EXPRESS` de exemplo com dois estados `Pass` em sequência. Tem role própria com trust para `states.amazonaws.com`.

```bash
# Listar state machines
aws stepfunctions list-state-machines --endpoint-url http://localhost:4566

# Iniciar execução
aws stepfunctions start-execution \
  --endpoint-url http://localhost:4566 \
  --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:myapp-state-machine \
  --input '{"dados": "entrada"}'

# Ver resultado da execução (use o executionArn retornado acima)
aws stepfunctions describe-execution \
  --endpoint-url http://localhost:4566 \
  --execution-arn <executionArn>

# Listar execuções
aws stepfunctions list-executions \
  --endpoint-url http://localhost:4566 \
  --state-machine-arn arn:aws:states:us-east-1:000000000000:stateMachine:myapp-state-machine
```

---

### API Gateway — REST API

REST API com rota `GET /health` integrada à Lambda via proxy. Retorna o mesmo JSON da função Lambda.

```bash
# Listar APIs
aws apigateway get-rest-apis --endpoint-url http://localhost:4566

# Obter o ID da API (necessário para a URL)
API_ID=$(aws apigateway get-rest-apis \
  --endpoint-url http://localhost:4566 \
  --query 'items[?name==`myapp-api`].id' \
  --output text)

# Chamar o endpoint /health
curl -s "http://localhost:4566/restapis/${API_ID}/local/_user_request_/health"

# Ou via terraform output (já calcula a URL)
terraform output api_gateway_url
```

---

## Configuração do Profile AWS local (opcional)

Para evitar `--endpoint-url` em todo comando, configure um profile:

```bash
aws configure --profile localstack
```

Preencha com:
- **AWS Access Key ID:** `test`
- **AWS Secret Access Key:** `test`
- **Default region name:** `us-east-1`
- **Default output format:** `json`

Adicione ao `~/.aws/config`:
```ini
[profile localstack]
endpoint_url = http://localhost:4566
```

Depois use:
```bash
aws s3 ls --profile localstack
aws lambda list-functions --profile localstack
```

---

## Integração com Spring Boot

A pasta `app/` contém uma aplicação Spring Boot de exemplo já configurada para conectar ao LocalStack.

### Dependências necessárias (`pom.xml`)

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.awspring.cloud</groupId>
            <artifactId>spring-cloud-aws-dependencies</artifactId>
            <version>3.1.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>io.awspring.cloud</groupId>
        <artifactId>spring-cloud-aws-starter-s3</artifactId>
    </dependency>
    <dependency>
        <groupId>io.awspring.cloud</groupId>
        <artifactId>spring-cloud-aws-starter-sqs</artifactId>
    </dependency>
</dependencies>
```

### Configuração (`application-local.yml`)

```yaml
spring:
  cloud:
    aws:
      credentials:
        access-key: test
        secret-key: test
      region:
        static: us-east-1
      endpoint: http://localhost:4566
      s3:
        endpoint: http://localhost:4566
        path-style-access-enabled: true
      sqs:
        endpoint: http://localhost:4566
      dynamodb:
        endpoint: http://localhost:4566

app:
  aws:
    s3:
      bucket-name: myapp-storage
    sqs:
      queue-name: myapp-queue
    dynamodb:
      table-name: myapp-table
```

---

## Destruir a infraestrutura

```bash
cd infra
terraform destroy -auto-approve
```

Para reiniciar do zero (incluindo dados persistidos):

```bash
docker compose down -v
docker compose up -d
cd infra && terraform apply -auto-approve
```
