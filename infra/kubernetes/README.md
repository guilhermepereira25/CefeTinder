# Kubernetes

Esta etapa cria o cluster Kubernetes usado para publicar a API 2 (`Notification Service`).

## Cluster

O cluster local usa `kind` com:

- 1 node `control-plane`.
- 2 nodes `worker`.

Arquivo de configuração:

```text
infra/kubernetes/kind-cluster.yaml
```

Essa configuração atende ao requisito do trabalho de possuir no mínimo 2 workers.

## Criar cluster

Execute a partir da raiz do repositório:

```bash
kind create cluster --config infra/kubernetes/kind-cluster.yaml
```

## Validar cluster

```bash
kubectl cluster-info --context kind-cefetinder
kubectl get nodes
```

Resultado esperado:

```text
cefetinder-control-plane   Ready
cefetinder-worker          Ready
cefetinder-worker2         Ready
```

## Portas reservadas para Ingress

O `control-plane` mapeia portas para publicação posterior do Ingress:

- `localhost:8081` -> porta `80` do cluster.
- `localhost:8445` -> porta `443` do cluster.

Essas portas serão usadas na etapa de `Ingress` do `Notification Service`.

## Instalar Ingress Controller

O Ingress usa `ingress-nginx` no cluster `kind`:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
```

## Instalar Metrics Server

O HPA depende do `metrics-server` para coletar uso de CPU:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl rollout status deployment/metrics-server -n kube-system
```

## Carregar imagem da API 2

Depois de criar o cluster, carregue a imagem Docker local da API 2:

```bash
kind load docker-image cefetinder/notification-service:latest --name cefetinder
```

## Namespace

A aplicação usa o namespace dedicado `cefetinder`:

```bash
kubectl apply -f infra/kubernetes/namespace.yaml
```

## Deployment da API 2

O `Notification Service` é implantado com:

- 2 réplicas.
- Estratégia `RollingUpdate`.
- Porta `8080`.
- `livenessProbe` TCP.
- `readinessProbe` TCP.
- Requests e limits de CPU/memória.

Aplicação do manifest:

```bash
kubectl apply -f infra/kubernetes/deployment.yaml
```

Validação:

```bash
kubectl get deployment notification-service -n cefetinder
kubectl get pods -n cefetinder -l app=notification-service
kubectl describe deployment notification-service -n cefetinder
```

## Service

O `Service` interno publica a porta `8080` do `Notification Service` dentro do cluster:

```bash
kubectl apply -f infra/kubernetes/service.yaml
kubectl get svc notification-service -n cefetinder
```

## Ingress

O `Ingress` publica a rota `/notifications` apontando para o `Service` da API 2:

```bash
kubectl apply -f infra/kubernetes/ingress.yaml
kubectl get ingress notification-service -n cefetinder
```

Com o mapeamento de portas do `kind`, a rota fica disponível localmente em:

```text
http://localhost:8081/notifications
```

## HPA

O `HorizontalPodAutoscaler` mantém no mínimo 2 réplicas e escala até 5 réplicas com target de CPU em 60%:

```bash
kubectl apply -f infra/kubernetes/hpa.yaml
kubectl get hpa notification-service -n cefetinder
```

## ResourceQuota e LimitRange

O namespace `cefetinder` possui quota de recursos e limites padrão para containers:

```bash
kubectl apply -f infra/kubernetes/limit-range.yaml
kubectl apply -f infra/kubernetes/resource-quota.yaml

kubectl get limitrange cefetinder-limits -n cefetinder
kubectl get resourcequota cefetinder-quota -n cefetinder
```

## Aplicar todos os manifests da API 2

```bash
kubectl apply -f infra/kubernetes/namespace.yaml
kubectl apply -f infra/kubernetes/limit-range.yaml
kubectl apply -f infra/kubernetes/resource-quota.yaml
kubectl apply -f infra/kubernetes/deployment.yaml
kubectl apply -f infra/kubernetes/service.yaml
kubectl apply -f infra/kubernetes/ingress.yaml
kubectl apply -f infra/kubernetes/hpa.yaml
```

## Validação final

```bash
kubectl get nodes
kubectl get pods -n cefetinder
kubectl get deployment -n cefetinder
kubectl get svc -n cefetinder
kubectl get ingress -n cefetinder
kubectl get hpa -n cefetinder
kubectl get resourcequota -n cefetinder
kubectl get limitrange -n cefetinder
```
