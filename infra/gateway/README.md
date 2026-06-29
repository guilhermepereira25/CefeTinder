# API Gateway

Esta etapa provisiona um API Gateway compatível com AWS via Floci para ser o ponto único de entrada externo das APIs escolhidas no trabalho.

## Rotas

| Rota | Destino | Responsabilidade |
|---|---|---|
| `/graphql` | GraphQL Server | API principal consumida pelo frontend. |
| `/graphql/{proxy+}` | GraphQL Server | Subrotas da API GraphQL, caso sejam necessárias. |
| `/notifications` | Notification Service | Endpoint público do serviço de notificações em tempo real. |
| `/notifications/{proxy+}` | Notification Service | Subrotas do serviço de notificações, caso sejam necessárias. |

## Implementação

O gateway é declarado em Terraform no módulo `infra/terraform/modules/api-gateway` usando API Gateway v2 do provider AWS.

As URLs internas dos serviços ficam parametrizadas:

- `graphql_api_url`: URL da API 1, que será publicada em EC2 ou equivalente.
- `notification_api_url`: URL da API 2, que será publicada via Ingress no Kubernetes.

Enquanto EC2 e Kubernetes ainda não estiverem prontos, os valores podem apontar para endpoints temporários usados na homologação.

## Execução

Copie o exemplo de variáveis e ajuste os endpoints conforme o ambiente:

```bash
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
```

Depois execute:

```bash
terraform -chdir=infra/terraform init
terraform -chdir=infra/terraform plan
terraform -chdir=infra/terraform apply
```

Após o apply, consulte os outputs:

```bash
terraform -chdir=infra/terraform output gateway_url
terraform -chdir=infra/terraform output graphql_route
terraform -chdir=infra/terraform output notification_route
```

## Observação sobre WebSocket

O Notification Service usa WebSocket. Esta primeira implementação cria um HTTP API Gateway com integração HTTP proxy para manter a rota `/notifications` como ponto público. Caso o Floci exija suporte específico para WebSocket API, esta etapa deve ser evoluída para um API Gateway WebSocket dedicado para o Notification Service.
