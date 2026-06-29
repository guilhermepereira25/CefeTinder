# API 1 - GraphQL Docker Image

Esta pasta contém o Dockerfile multi-stage da API 1 escolhida para o trabalho: `GraphQL Server`.

## Responsabilidade

A imagem executa o servidor GraphQL em Node.js na porta `4000`. O serviço continua dependendo dos serviços gRPC internos:

- `USER_SERVICE_ADDRESS`
- `MATCH_SERVICE_ADDRESS`

## Build local

Execute a partir da raiz do repositório:

```bash
docker build -f infra/apis/api-1/Dockerfile -t cefetinder/graphql-api:latest .
```

## Execução local

```bash
docker run --rm \
  -p 4000:4000 \
  -e USER_SERVICE_ADDRESS=host.docker.internal:50051 \
  -e MATCH_SERVICE_ADDRESS=host.docker.internal:50052 \
  cefetinder/graphql-api:latest
```

## Build e push para GHCR

O registry escolhido para esta etapa é o GitHub Container Registry (`GHCR`). A criação do ECR via Floci foi testada, mas o recurso `aws_ecr_repository` ficou preso durante o `terraform apply` até timeout. Por isso, a imagem da API 1 será publicada no GHCR, que atende ao requisito de registry privado.

Crie um token GitHub com permissão `write:packages` e autentique o Docker:

```bash
export GITHUB_USER=<seu-usuario-github>
export GHCR_TOKEN=<seu-token-github>

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin
```

Com GitHub CLI, atualize o token local e autentique o Docker:

```bash
gh auth refresh -s write:packages
gh auth token | docker login ghcr.io -u "$GITHUB_USER" --password-stdin
```

Faça build, tag e push:

```bash
export IMAGE_NAME=ghcr.io/$GITHUB_USER/cefetinder-graphql-api:latest

docker build -f infra/apis/api-1/Dockerfile -t cefetinder/graphql-api:latest .
docker tag cefetinder/graphql-api:latest "$IMAGE_NAME"
docker push "$IMAGE_NAME"
```

Imagem testada localmente neste repositório:

```bash
ghcr.io/guilhermepereira25/cefetinder-graphql-api:latest
```

O push dessa imagem exige token com escopo `write:packages`. Sem esse escopo, o GHCR retorna `permission_denied`.

Para pull da imagem publicada:

```bash
docker pull "$IMAGE_NAME"
```
