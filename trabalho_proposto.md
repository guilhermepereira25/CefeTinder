# Trabalho Final

## Escolha do Projeto

Cada aluno deve selecionar **um projeto já existente** de autoria própria ou open source para aplicar os requisitos de infraestrutura e DevOps deste trabalho. São aceitas as seguintes origens:

- Projeto desenvolvido na disciplina de **Arquitetura de software, Engenharia de software, Programação web** (ou equivalente).
- Projeto pessoal hospedado no seu GitHub.
- Aplicação **open source** de terceiros que você tenha interesse em usar como base.

### Critérios obrigatórios para o projeto escolhido

1. Os repositórios Git devem ter sido **criado antes de 11/06/2026** (data de postagem deste trabalho). Repositórios criados após essa data serão desconsiderados.
2. Os repositório escolhidos devem se comunicar de alguma forma, eles devem possuir **no mínimo duas aplicações** (dois microsserviços, um front e um back) e **pelo menos um banco de dados**.
3. O repositório **não deve conter nenhum dos artefatos de DevOps listados nos requisitos técnicos** (Dockerfiles, manifestos Kubernetes, arquivos Terraform, playbooks Ansible, pipelines CI/CD, etc.).
4. Dois alunos não podem escolher o mesmo repositório

### Validação do repositório

Antes de iniciar o trabalho, envie o link do repositório Git escolhido para validação pelo professor. A validação confirmará que:

- O repositório foi criado dentro do prazo exigido.
- O projeto contempla as duas APIs e o banco de dados mínimos.
- O repositório não continha arquivos de DevOps no momento da postagem deste trabalho.

> **Atenção:** não será aceito projeto que não passe pela validação. Aguarde a confirmação antes de começar a implementação.

---

## Contexto do Trabalho

No projeto, você assumirá o papel de engenheiro de infraestrutura responsável por estruturar toda a camada de DevOps da aplicação. Os requisitos a seguir devem ser implementados sobre as APIs e o banco de dados já existentes no projeto escolhido. Adapte nomes, rotas e variáveis de ambiente conforme o domínio do seu projeto.

---

## Requisitos Técnicos Obrigatórios

### 1. APIs

- Identifique as **duas APIs principais** do projeto e documente no README o papel de cada uma (rotas, responsabilidades, linguagem).
- As APIs devem permanecer com seu domínio original — não substitua a lógica de negócio, apenas adicione a infraestrutura ao redor.
- Se o projeto tiver mais de duas APIs, escolha duas como foco e documente a decisão.

### 2. API Gateway

- Utilize um gateway na frente das duas APIs (localstack, floci ou cloud).
- Configure rotas apontando cada prefixo de caminho para a API correspondente.
- O gateway deve ser o único ponto de entrada exposto externamente.

### 3. Docker

- A primeira API deve ser containerizada com um `Dockerfile`, caso necessário, use multi-stage.
- Publique a imagem em um **Docker Registry privado** (pode usar o Docker Hub).
- A API deve ser publicado em um EC2 ou algo similar

### 4. Kubernetes

- A segunda API deve ser implantada no Kubernetes com:
  - Cluster com **no mínimo 2 nodes worker**.
  - `Deployment` com pelo menos 2 réplicas e `RollingUpdate` configurado.
  - `Service` apontando para o gateway.
  - `Ingress` configurado para publicação externa e roteamento das requisições.
  - `HorizontalPodAutoscaler` com base em uso de CPU (target: 60%).
  - `ResourceQuota` e `LimitRange` aplicados ao namespace do projeto.
  - `Liveness` e `Readiness` probes configurados.

### 5. Banco de Dados

- Provisione o banco de dados do projeto simulando um RDS ou DynamoDB com o Terraform.
- Configure um **cluster de leitura** no Kubernetes:
  - 2 pods (use `StatefulSet` com replicação adequada ao banco escolhido)
- Não será considerado na correção banco segregado para escrita devido a necessidade de replicação de dados. Será visto como pontuação extra (+ 1 ponto)

### 6. Terraform + LocalStack ou Floci ou Cloud

- Utilize Terraform para provisionar sua infra:
  - Instância EC2 (simula servidor de CI)
  - Instância do banco de dados (RDS ou equivalente)
  - K8s
  - É obirgatório o uso de namespaces
- Separe os recursos em **módulos Terraform** (vários arquivos)

### 7. CI/CD com Ansible + Pipeline

- O pipeline (GitHub Actions) deve:
  1. **Testes unitários** de ambas as APIs (pelo menos um para cada API).
  2. **Análise de qualidade** com SonarQube:
     - Suba o SonarQube em um container Docker no ambiente de CI.
     - O pipeline falha se o Quality Gate não passar.
  3. **SAST** — utilize `Trivy` (scan de imagem) ou `Semgrep` (scan de código).
  4. **DAST** — após o deploy em ambiente de homologação, execute `OWASP ZAP` em modo baseline contra o gateway.
  5. **Build e push** da imagem Docker da primeira API para o registry.
  6. **Deploy via Ansible**:
     - Playbook `deploy-docker.yml` — faz pull e restart da primeira API no host Docker.
     - Playbook `deploy-k8s.yml` — aplica os manifestos Kubernetes da segunda API.
  7. **Notificação** de sucesso/falha (pode ser via `echo` com resumo ou webhook simples).


## Estrutura sugerida

```
infra/
├── apis/
│   ├── api-1/
│   │   ├── Docker/
│   └── api-2/      
│       ├── Docker/ 
├── gateway/
│   └── arquivo.conf 
├── kubernetes/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── resource-quota.yaml
│   └── database/
│       ├── statefulset-primary.yaml
│       └── statefulset-replica.yaml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── modules/
│       ├── compute/
│       ├── database/
│       └── storage/
├── ansible/
│   ├── ansible.cfg
│   ├── hosts.ini
│   └── playbooks/
│       ├── deploy-docker.yml
│       └── deploy-k8s.yml
├── .github/workflows/pipeline.yml 
└── README.md explicando o projeto e com git do projeto original para validação
```

---

## Critérios de Avaliação

| Critério | Peso |
|---|---|
| Gateway configurado e roteando corretamente | 1 ponto |
| Docker multi-stage + push para registry | 1 ponto |
| Kubernetes com 2+ nodes, HPA, probes, quotas | 2 pontos |
| Banco com cluster leitura/escrita no K8s | 1 ponto |
| Terraform | 2 pontos |
| CI/ CD com Ansible | 1 ponto |
| Total | 8 pontos |

---

## Observações

- O link do repositório original **deve constar no README** do projeto entregue
- O SonarQube deve estar rodando em algum lugar acessível pelo pipeline (container local, instância EC2 via LocalStack, etc.).
- Para o DAST com OWASP ZAP, a URL alvo deve ser o gateway em ambiente de homologação.
- O cluster Kubernetes pode ser criado com `kind`, `k3d` ou `minikube` ou localstack ou floci ou uma cloud a sua escolha com múltiplos nodes.
- Não é permitido adicionar lógica de negócio nova às APIs; o escopo do trabalho é exclusivamente a camada de infraestrutura e DevOps.
