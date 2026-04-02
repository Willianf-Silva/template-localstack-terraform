# template-localstack-terraform
Criando a infra de recursos AWS utilizando terraform e localstack

# AWS CLI
## Comandos

### Listar os buckets S3 locais
```bash
aws s3 ls --profile localstack
```

### Listar as filas SQS locais
```bash
aws sqs list-queues --profile localstack
```

### Enviar um arquivo de teste para o seu bucket local
```bash
aws s3 cp meu_arquivo.txt s3://local-app-storage/ --profile localstack
```


# Setup da Aplicação Spring Boot com LocalStack
Este guia documenta o processo de inicialização do módulo da aplicação (`/app`) utilizando o Spring Initializr e a sua integração com a infraestrutura local AWS (LocalStack).

## 1. Inicialização do Projeto (Spring Initializr)
Acesse [start.spring.io](https://start.spring.io/) e gere o projeto com as seguintes especificações:

* **Project:** Maven
* **Language:** Java
* **Spring Boot:** 3.2.x ou superior (Estável)
* **Group:** `com.saas`
* **Artifact:** `core` (gera o nome do projeto como `saas-core-api`)
* **Packaging:** Jar
* **Java:** 21
* **Dependencies:** Spring Web

**Ação:** Faça o download do arquivo `.zip` e extraia todo o seu conteúdo para dentro da pasta `app/` na raiz do repositório. A estrutura deve ficar semelhante a esta:
```text
raiz_projeto/
├── app/
│   ├── src/
│   ├── pom.xml
│   └── mvnw
├── infra/
└── docker-compose.yaml
```

## 2. Configuração de Dependências (`pom.xml`)
Para conectar a aplicação à nuvem simulada, adicionamos o **Spring Cloud AWS** na versão 3.x, que utiliza internamente o AWS SDK v2.

Adicione o gerenciador de dependências imediatamente **antes** da tag `<build>`:
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
```

Adicione os starters específicos na sua lista de `<dependencies>`:
```xml
<dependency>
    <groupId>io.awspring.cloud</groupId>
    <artifactId>spring-cloud-aws-starter-s3</artifactId>
</dependency>
<dependency>
    <groupId>io.awspring.cloud</groupId>
    <artifactId>spring-cloud-aws-starter-sqs</artifactId>
</dependency>
```

## 3. Variáveis de Ambiente (`application.yml`)
Renomeie o arquivo padrão `src/main/resources/application.properties` para `application.yml` e configure os endpoints da AWS para apontarem para o roteador do LocalStack na porta `4566`.

```yaml
spring:
  application:
    name: saas-core-api
  cloud:
    aws:
      credentials:
        access-key: test
        secret-key: test
      region:
        static: us-east-1
      # Roteamento global para o LocalStack
      endpoint: http://localhost:4566
      s3:
        endpoint: http://localhost:4566
        path-style-access-enabled: true  # Obrigatório apenas no LocalStack
      sqs:
        endpoint: http://localhost:4566
      dynamodb:
        endpoint: http://localhost:4566

app:
  aws:
    s3:
      bucket-name: local-app-storage
    sqs:
      queue-name: app-main-queue
    dynamodb:
      table-name: AppConfigTable
```

## 4. Implementação Base (Exemplo Upload S3)
Estrutura de classes inicial para validar a comunicação de upload com o S3 local.

**Serviço (`src/main/java/com/saas/core/service/S3StorageService.java`):**
```java
package com.saas.core.service;

import io.awspring.cloud.s3.S3Template;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.UUID;

@Service
public class S3StorageService {
    private final S3Template s3Template;
    private final String bucketName;

    public S3StorageService(S3Template s3Template, @Value("${app.aws.s3.bucket-name}") String bucketName) {
        this.s3Template = s3Template;
        this.bucketName = bucketName;
    }

    public String uploadFile(MultipartFile file) {
        try {
            String uniqueFileName = UUID.randomUUID() + "-" + file.getOriginalFilename();
            s3Template.upload(bucketName, uniqueFileName, file.getInputStream());
            return uniqueFileName;
        } catch (IOException e) {
            throw new RuntimeException("Falha ao enviar arquivo para o S3 Local", e);
        }
    }
}
```

**Controlador (`src/main/java/com/saas/core/controller/FileUploadController.java`):**
```java
package com.saas.core.controller;

import com.saas.core.service.S3StorageService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/files")
public class FileUploadController {
    private final S3StorageService s3StorageService;

    public FileUploadController(S3StorageService s3StorageService) {
        this.s3StorageService = s3StorageService;
    }

    @PostMapping("/upload")
    public ResponseEntity<String> upload(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Arquivo não pode ser vazio!");
        }
        String savedFileName = s3StorageService.uploadFile(file);
        return ResponseEntity.ok("Sucesso! Arquivo salvo como: " + savedFileName);
    }
}
```