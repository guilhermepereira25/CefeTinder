# CEFETinder ❤️

<img width="500" height="106" alt="CEFETinder (1)" src="https://github.com/user-attachments/assets/c634f3f1-9bb1-42d4-a8bb-0401de5fab6f" />

Um aplicativo de encontros para estudantes do CEFET, desenvolvido com arquitetura de microsserviços.

## Repositório original

Este trabalho utiliza como base o repositório original disponível em:

https://github.com/CainaZumaa/CefeTinder

## Arquitetura

O projeto utiliza uma arquitetura de microsserviços com os seguintes componentes:

![Diagrama de Arquitetura](./CEFET_TINDER.drawio.png)

- **Kong API Gateway**: Roteamento e gerenciamento de APIs
- **RabbitMQ**: Fila de mensagens para comunicação assíncrona
- **GraphQL**: API GraphQL para o frontend e gerenciamento de rotas
- **User Service**: Gerenciamento de usuários e preferências (gRPC)
- **Match Service**: Sistema de matching e likes (gRPC)
- **Notification Service**: Sistema de notificações em tempo real (WebSocket)

## APIs escolhidas para o trabalho

Para atender aos requisitos do trabalho de infraestrutura e DevOps, foram escolhidas duas APIs principais do projeto. A lógica de negócio original será mantida; o escopo do trabalho é adicionar a camada de infraestrutura ao redor dessas APIs.

### API 1: GraphQL Server

- **Linguagem:** TypeScript, executado em Node.js.
- **Localização principal:** `src/graphql/server.ts`.
- **Porta interna:** `4000`.
- **Rota via gateway:** `/graphql`.
- **Responsabilidade:** expor a API principal consumida pelo frontend, centralizando as operações de usuários, preferências, likes e matches por meio de GraphQL.
- **Comunicação interna:** acessa os serviços `User Service` e `Match Service` via gRPC.
- **Uso no trabalho:** será a API usada como foco para containerização com Docker, publicação da imagem em registry privado e deploy em EC2 ou ambiente equivalente.

### API 2: Notification Service

- **Linguagem:** TypeScript, executado em Node.js.
- **Localização principal:** `src/websocket/server.ts` e `src/notification-service/`.
- **Porta interna:** `8080`.
- **Rota via gateway:** `/notifications`.
- **Responsabilidade:** manter conexões WebSocket para envio de notificações em tempo real, como eventos de likes e matches.
- **Comunicação interna:** consome eventos publicados no RabbitMQ pelo serviço de matches.
- **Uso no trabalho:** será a API usada como foco para implantação em Kubernetes, com Deployment, Service, Ingress, HPA, probes, quotas e limites de recursos.

## API Gateway do trabalho

O gateway da entrega de infraestrutura será provisionado com Terraform usando API Gateway compatível com AWS via Floci. Ele será o ponto único de entrada externo para as APIs escolhidas.

### Rotas publicadas

- `/graphql`: encaminha requisições para a API 1, o `GraphQL Server`.
- `/graphql/{proxy+}`: encaminha subrotas da API GraphQL, caso sejam necessárias.
- `/notifications`: encaminha requisições para a API 2, o `Notification Service`.
- `/notifications/{proxy+}`: encaminha subrotas do serviço de notificações, caso sejam necessárias.

### Infraestrutura relacionada

- Módulo Terraform: `infra/terraform/modules/api-gateway`.
- Variáveis de exemplo: `infra/terraform/terraform.tfvars.example`.
- Documentação da etapa: `infra/gateway/README.md`.

As URLs reais das APIs serão conectadas ao gateway nas próximas etapas, quando a API 1 estiver publicada em EC2 ou equivalente e a API 2 estiver publicada pelo Ingress do Kubernetes.

## Docker e Registry da API 1

A API 1 (`GraphQL Server`) possui um Dockerfile multi-stage dedicado em `infra/apis/api-1/Dockerfile`. A imagem será publicada em um registry privado no GitHub Container Registry (`GHCR`).

### Decisão sobre registry

Inicialmente foi prevista a criação de um registry ECR compatível com AWS via Floci. Durante a execução, o `terraform plan` funcionou, mas o `terraform apply` para `aws_ecr_repository` ficou preso até timeout, mesmo com a API ECR respondendo via AWS CLI. Para manter a entrega funcional e permitir build/push real da imagem Docker, a estratégia foi alterada para GitHub Container Registry.

O GHCR atende ao requisito de Docker Registry privado e será usado para armazenar a imagem da API 1.

### Autenticação no GHCR

Crie um token GitHub com permissão de escrita em pacotes (`write:packages`) e autentique o Docker:

```bash
export GITHUB_USER=<seu-usuario-github>
export GHCR_TOKEN=<seu-token-github>

echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin
```

Se estiver usando GitHub CLI, também é possível atualizar as permissões do token local antes do login:

```bash
gh auth refresh -s write:packages
gh auth token | docker login ghcr.io -u "$GITHUB_USER" --password-stdin
```

### Build e push da imagem

Execute a partir da raiz do repositório:

```bash
export GITHUB_USER=<seu-usuario-github>
export IMAGE_NAME=ghcr.io/$GITHUB_USER/cefetinder-graphql-api:latest

docker build -f infra/apis/api-1/Dockerfile -t cefetinder/graphql-api:latest .
docker tag cefetinder/graphql-api:latest "$IMAGE_NAME"
docker push "$IMAGE_NAME"
```

Para publicar como pacote privado, ajuste a visibilidade do pacote no GitHub após o primeiro push ou use as configurações da organização/repositório.

No ambiente local, o build da imagem foi validado com sucesso. O push para `ghcr.io/guilhermepereira25/cefetinder-graphql-api:latest` foi testado, mas o token GitHub configurado localmente não possuía o escopo `write:packages`, então o GHCR recusou a publicação. Após autenticar com um token contendo esse escopo, os comandos acima fazem a publicação da imagem.

Documentação específica da imagem: `infra/apis/api-1/README.md`.

### Execução local da imagem

Depois do build, a imagem pode ser testada localmente com:

```bash
docker run --rm \
  -p 4000:4000 \
  -e USER_SERVICE_ADDRESS=host.docker.internal:50051 \
  -e MATCH_SERVICE_ADDRESS=host.docker.internal:50052 \
  cefetinder/graphql-api:latest
```

## Kubernetes da API 2

A API 2 (`Notification Service`) será implantada em Kubernetes. O cluster local de homologação usa `kind` com 1 control-plane e 2 workers, atendendo ao requisito de no mínimo 2 worker nodes.

Arquivos relacionados:

- Configuração do cluster: `infra/kubernetes/kind-cluster.yaml`.
- Namespace: `infra/kubernetes/namespace.yaml`.
- Deployment da API 2: `infra/kubernetes/deployment.yaml`.
- Service da API 2: `infra/kubernetes/service.yaml`.
- Ingress da API 2: `infra/kubernetes/ingress.yaml`.
- HPA da API 2: `infra/kubernetes/hpa.yaml`.
- ResourceQuota: `infra/kubernetes/resource-quota.yaml`.
- LimitRange: `infra/kubernetes/limit-range.yaml`.
- Documentação da etapa: `infra/kubernetes/README.md`.
- Dockerfile da API 2: `infra/apis/api-2/Dockerfile`.

Criação do cluster:

```bash
kind create cluster --config infra/kubernetes/kind-cluster.yaml
```

Validação:

```bash
kubectl get nodes
```

Resultado esperado:

```text
cefetinder-control-plane   Ready
cefetinder-worker          Ready
cefetinder-worker2         Ready
```

Aplicação do namespace e deployment:

```bash
kubectl apply -f infra/kubernetes/namespace.yaml
kubectl apply -f infra/kubernetes/deployment.yaml
```

O deployment do `Notification Service` usa 2 réplicas, estratégia `RollingUpdate`, probes TCP de liveness/readiness e requests/limits de CPU e memória.

Aplicação dos recursos complementares:

```bash
kubectl apply -f infra/kubernetes/limit-range.yaml
kubectl apply -f infra/kubernetes/resource-quota.yaml
kubectl apply -f infra/kubernetes/service.yaml
kubectl apply -f infra/kubernetes/ingress.yaml
kubectl apply -f infra/kubernetes/hpa.yaml
```

O `Service` expõe a API 2 internamente na porta `8080`, o `Ingress` publica `/notifications`, e o `HorizontalPodAutoscaler` escala de 2 até 5 réplicas com target de CPU em 60%.

## Banco de Dados

O banco principal do projeto é provisionado com Terraform como uma instância RDS PostgreSQL simulada no Floci.

### Decisão técnica

Foi escolhido PostgreSQL porque o CEFETinder já utiliza PostgreSQL nos serviços de usuários e matches. Como o requisito da fase 5 pede RDS ou DynamoDB, o RDS PostgreSQL é a alternativa mais compatível com o domínio e com a implementação existente.

Nesta etapa, não vamos focar na réplica ou na segregação leitura/escrita. A fase atual fica concentrada no provisionamento do banco principal via Terraform/Floci. A replicação poderá ser tratada posteriormente como evolução.

### Infraestrutura relacionada

- Módulo Terraform: `infra/terraform/modules/database`.
- Recurso provisionado: `aws_db_instance`.
- Engine: `postgres`.
- Versão: `16.3`.
- Banco padrão: `cefetinder`.

O Floci foi configurado no `docker-compose.yml` com Docker socket, portas `7001-7099` e rede `cefetinder_cefet-tinder-network`, pois o RDS do Floci cria containers PostgreSQL reais e expõe o acesso por proxy TCP.

### Execução

```bash
terraform -chdir=infra/terraform init
terraform -chdir=infra/terraform apply
```

### Validação

```bash
terraform -chdir=infra/terraform output database_endpoint

aws rds describe-db-instances \
  --db-instance-identifier cefetinder-postgres \
  --endpoint-url http://localhost:4566

pg_isready -h localhost -p 7001 -U user -d cefetinder
```

### Estrutura do projeto

- `src/services/user`: Serviço de gerenciamento de usuários
- `src/services/match`: Serviço de sistema de matching
- `src/services/notification`: Serviço de notificações em tempo real

#### GraphQL

Utilizamos o TypeGraphQL para definir o esquema GraphQL e os resolvers.

Os schemas estão definidos em `src/graphql/types` e os resolvers em `src/graphql/resolvers`.

O schema principal é montado dinamicamente em `src/graphql/schema.ts`, utilizando o TypeGraphQL.

#### gRPC

Os serviços de User e Match se comunicam via gRPC.

O projeto utiliza typescript, dessa forma, é possível gerar os tipos automaticamente a partir dos arquivos .proto.

Basta rodar o comando:

```bash
npm run generate:proto
```

Os arquivos gerados ficarão na pasta `src/proto`.

## Pré-requisitos

Antes de rodar o projeto, certifique-se de ter instalado:

- Docker e Docker Compose

## Executando o projeto com Docker Compose

Instale as dependências e inicie os serviços com Docker Compose:

```bash
docker-compose up --build -d
```

## Executando testes com jmeter

O projeto inclui testes de carga utilizando Apache JMeter. Para executar os testes, siga os passos abaixo:
Use o arquivo `jmeter/test.jmx` para definir o plano de teste.

Rode o seguinte comando para executar os testes:

```bash
docker run --rm -v "%cd%\jmeter:/tests" -w /tests justb4/jmeter -n -t test.jmx -l results.jtl -e -o report
```

## Funcionamento do API Gateway (Kong)

O Kong API Gateway gerencia o roteamento das requisições para os serviços apropriados. Ele expõe as seguintes rotas:

- `/graphql`: Rota para o serviço GraphQL
- `/notifications`: Rota para o serviço de notificações

Os únicos serviços expostos externamente são o GraphQL e o Notification Service. Os serviços de User e Match são acessados internamente via gRPC.

## WebSocket para Notificações em Tempo Real

O Notification Service utiliza WebSocket para enviar notificações em tempo real aos usuários sobre novos matches e mensagens. O serviço escuta conexões WebSocket na rota `/notifications`.

O frontend pode se conectar ao WebSocket da seguinte forma:

```javascript
const socket = new WebSocket("ws://<KONG_API_GATEWAY_URL>/notifications");
socket.onmessage = function (event) {
  const notification = JSON.parse(event.data);
  console.log("Nova notificação:", notification);
};
```

## Padrões de Projeto (Design Patterns)

O projeto implementa diversos padrões de projeto para garantir código limpo, manutenível e escalável:

### 1. **Observer Pattern** 🔔

**Localização:** `src/patterns/observer/`, `src/services/match/MatchService.ts`

**Objetivo:** Implementar um sistema de notificações desacoplado onde múltiplos observadores podem reagir a eventos de match sem acoplamento direto.

**Como funciona:**

- `MatchService` atua como **Subject** que publica eventos (like, super like, match, dislike)
- `NotificationObserver` é um **Observer concreto** que escuta eventos e envia notificações via WebSocket
- Quando um match ocorre, todos os observadores registrados são notificados automaticamente

**Benefícios:**

- Desacoplamento entre lógica de negócio e notificações
- Facilita adição de novos tipos de observadores (analytics, email, push notifications)
- Testabilidade melhorada com mock observers

**Exemplo de uso:**

```typescript
const notificationObserver = new NotificationObserver(notificationService);
matchService.getSubject().attach(notificationObserver);
```

---

### 2. **Repository Pattern** 🗄️

**Localização:** `src/repositories/user/`

**Objetivo:** Abstrair a lógica de acesso a dados, permitindo trocar a implementação do banco de dados sem impactar a camada de negócio.

**Como funciona:**

- `IUserRepository` define o contrato de interface
- `PostgresUserRepository` e `SupabaseUserRepository` são implementações concretas
- `UserService` depende apenas da interface, não da implementação

**Benefícios:**

- Inversão de Dependência (SOLID - D)
- Facilita testes unitários com repositórios mock
- Permite trocar banco de dados sem alterar regras de negócio
- Substituição de Liskov (SOLID - L): qualquer implementação pode substituir a base

**Exemplo de uso:**

```typescript
// UserService usa a interface, não a implementação concreta
constructor(@inject(TYPES.IUserRepository) private repository: IUserRepository)
```

---

### 3. **Factory Pattern** 🏭

**Localização:** `src/factories/DatabaseFactory.ts`

**Objetivo:** Centralizar a criação de objetos complexos (repositórios) e permitir diferentes implementações baseadas em configuração.

**Como funciona:**

- `DatabaseClientFactory.createUserRepository()` cria instâncias de repositórios
- Seleciona entre Postgres ou Supabase baseado em parâmetro
- Encapsula lógica de criação e inicialização

**Benefícios:**

- Centraliza lógica de criação
- Facilita adição de novos tipos de banco de dados
- Segue Open/Closed Principle (SOLID - O)

**Exemplo de uso:**

```typescript
const repository = DatabaseClientFactory.createUserRepository("postgres");
```

---

### 4. **Dependency Injection (DI)** 💉

**Localização:** `src/grpc/user/user.container.ts`, `src/services/user/UserService.ts`

**Objetivo:** Inverter o controle de dependências, permitindo que objetos recebam suas dependências ao invés de criá-las.

**Como funciona:**

- Usa biblioteca `inversify` para container IoC
- Registra dependências no container
- Injeta automaticamente no construtor usando decorators `@inject`

**Benefícios:**

- Inversão de Dependência (SOLID - D)
- Facilita testes com dependências mockadas
- Reduz acoplamento entre módulos
- Gerenciamento centralizado de dependências

**Exemplo de uso:**

```typescript
container.bind(TYPES.IUserRepository).toDynamicValue(() => {
  return DatabaseClientFactory.createUserRepository("postgres");
});
```

---

### 5. **Strategy Pattern** 🎯

**Localização:** `src/services/notification/NotificationService.ts`

**Objetivo:** Permitir diferentes estratégias de tratamento de notificações sem modificar a classe principal.

**Como funciona:**

- `NotificationHandler` é a interface abstrata de estratégia
- `MatchNotificationHandler` e `LikeNotificationHandler` são estratégias concretas
- `NotificationService` usa handlers registrados dinamicamente

**Benefícios:**

- Open/Closed Principle (SOLID - O): aberto para extensão, fechado para modificação
- Facilita adição de novos tipos de notificação
- Cada handler tem responsabilidade única (SOLID - S)

**Exemplo de uso:**

```typescript
notificationService.registerHandler("MATCH", new MatchNotificationHandler());
notificationService.registerHandler("EMAIL", new EmailNotificationHandler());
```

---

### 6. **Singleton Pattern** 🔒

**Localização:** `src/services/notification/NotificationService.ts`, `src/config/supabase.ts`

**Objetivo:** Garantir uma única instância de recursos compartilhados (conexões, serviços).

**Como funciona:**

- `getNotificationService()` retorna sempre a mesma instância
- `getSupabaseClient()` mantém uma única conexão com Supabase
- Evita múltiplas conexões e garante estado consistente

**Benefícios:**

- Economia de recursos (memória, conexões)
- Estado global consistente
- Controle sobre instanciação

**Exemplo de uso:**

```typescript
const notificationService = getNotificationService();
// Sempre retorna a mesma instância
```

---

### 7. **Microservices Pattern** 🔄

**Localização:** Arquitetura geral do projeto

**Objetivo:** Dividir a aplicação em serviços independentes e especializados.

**Como funciona:**

- **User Service** (gRPC) - Gerenciamento de usuários
- **Match Service** (gRPC) - Sistema de matching
- **Notification Service** (WebSocket) - Notificações em tempo real
- **GraphQL Service** - API unificada para frontend
- **Kong API Gateway** - Roteamento e gerenciamento

**Benefícios:**

- Escalabilidade independente de cada serviço
- Deploy e manutenção isolados
- Tecnologias diferentes para problemas diferentes
- Tolerância a falhas

---

## Princípios SOLID Aplicados

✅ **S - Single Responsibility Principle**

- Cada serviço tem uma responsabilidade única
- Separação clara entre camadas (repository, service, resolver)

✅ **O - Open/Closed Principle**

- Strategy pattern permite extensão sem modificação
- Factory pattern facilita adição de novos tipos

✅ **L - Liskov Substitution Principle**

- Implementações de repositórios são intercambiáveis
- `PostgresUserRepository` pode substituir `BaseUserRepository`

✅ **I - Interface Segregation Principle**

- Interfaces específicas (`IUserRepository`, `IMatchObserver`)
- Clientes dependem apenas dos métodos que usam

✅ **D - Dependency Inversion Principle**

- Serviços dependem de abstrações, não de implementações concretas
- Dependency Injection via InversifyJS

## Tecnologias

- TypeScript
- GraphQL
- gRPC
- Supabase (PostgreSQL)
- WebSocket

## Funcionalidades

- Filtros por idade e gênero
- Sistema de likes e super likes
- Notificações em tempo real de matches
- Gerenciamento de sessões ativas
- Sistema de matchmaking
