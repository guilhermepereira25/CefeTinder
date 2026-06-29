# Ansible Deploy

Esta pasta contém os playbooks usados pelo pipeline CI/CD.

## API 1 - Docker

O playbook `deploy-docker.yml` faz pull da imagem Docker da API GraphQL e reinicia o container no host Docker.

```bash
ansible-playbook -i infra/ansible/hosts.ini infra/ansible/playbooks/deploy-docker.yml
```

Variáveis por ambiente:

- `GRAPHQL_IMAGE`
- `GRAPHQL_HOST_PORT`
- `USER_SERVICE_ADDRESS`
- `MATCH_SERVICE_ADDRESS`

## API 2 - Kubernetes

O playbook `deploy-k8s.yml` aplica os manifests Kubernetes da API de notificações.

```bash
ansible-playbook -i infra/ansible/hosts.ini infra/ansible/playbooks/deploy-k8s.yml
```

Ele aplica namespace, quotas, deployment, service, ingress e HPA, depois aguarda o rollout do `notification-service`.
