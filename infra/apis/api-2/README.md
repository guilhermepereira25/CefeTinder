# API 2 - Notification Service Docker Image

Esta pasta contém o Dockerfile multi-stage da API 2 escolhida para o trabalho: `Notification Service`.

## Responsabilidade

A imagem executa o serviço de notificações em tempo real na porta `8080`, expondo conexões WebSocket e rotas HTTP auxiliares do serviço.

O consumo de eventos do RabbitMQ é habilitado pela variável:

```text
RABBITMQ_URL
```

Se `RABBITMQ_URL` não estiver definida, o servidor WebSocket sobe normalmente, mas o consumidor de eventos fica desabilitado.

## Build local

Execute a partir da raiz do repositório:

```bash
docker build -f infra/apis/api-2/Dockerfile -t cefetinder/notification-service:latest .
```

## Execução local

Sem RabbitMQ:

```bash
docker run --rm -p 8080:8080 cefetinder/notification-service:latest
```

Com RabbitMQ:

```bash
docker run --rm \
  -p 8080:8080 \
  -e RABBITMQ_URL=amqp://guest:guest@host.docker.internal:5672 \
  cefetinder/notification-service:latest
```

## Imagem para Kubernetes

A imagem local usada nos manifests Kubernetes será:

```text
cefetinder/notification-service:latest
```

Em cluster `kind`, ela poderá ser carregada com:

```bash
kind load docker-image cefetinder/notification-service:latest --name cefetinder
```
