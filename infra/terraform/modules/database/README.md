# Database Module

Este módulo provisiona o banco principal do CEFETinder como uma instância RDS PostgreSQL simulada no Floci.

## Decisão técnica

O banco escolhido foi PostgreSQL porque o projeto original já utiliza PostgreSQL nos serviços de usuários e matches. A fase 5 do trabalho exige provisionar o banco simulando RDS ou DynamoDB com Terraform; como o domínio atual já usa banco relacional, RDS PostgreSQL é a opção mais aderente.

Nesta etapa não será implementado foco em réplica ou segregação leitura/escrita. A decisão foi manter a fase concentrada no provisionamento do banco principal via Terraform/Floci. A replicação pode ser evoluída posteriormente como melhoria ou pontuação extra.

## Recurso criado

- `aws_db_instance.postgres`

## Configuração padrão

- Engine: `postgres`
- Versão: `16.3`
- Classe: `db.t3.micro`
- Storage: `20 GiB`
- Database: `cefetinder`
- Usuário: `user`

## Requisitos do Floci

O serviço RDS do Floci cria containers Docker reais para o banco. Por isso, o serviço `floci` no `docker-compose.yml` precisa de:

- Docker socket montado em `/var/run/docker.sock`.
- Portas `7001-7099` expostas para os proxies TCP do RDS.
- Variável `FLOCI_SERVICES_DOCKER_NETWORK` apontando para a rede Docker do projeto.
- Variável `FLOCI_SERVICES_RDS_PROXY_BASE_PORT` definida como `7001`.

Neste projeto, a rede usada pelo Floci para criar o container RDS é:

```text
cefetinder_cefet-tinder-network
```

## Validação

Depois do `terraform apply`, valide a instância:

```bash
aws rds describe-db-instances \
  --db-instance-identifier cefetinder-postgres \
  --endpoint-url http://localhost:4566 \
  --region us-east-1

pg_isready -h localhost -p 7001 -U user -d cefetinder
```

## Outputs

- `identifier`
- `address`
- `port`
- `endpoint`
- `database_name`
- `username`
