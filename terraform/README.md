# Terraform – Catálogo DocumentDB

Infraestrutura como código para o cluster **Amazon DocumentDB** do projeto de catálogo do e-commerce ([ecommerce-docs](https://github.com/LucasHirao/ecommerce-docs)).

## Recursos

- VPC com subnets privadas em múltiplas AZs
- Cluster DocumentDB (compatível MongoDB) com criptografia e TLS
- Security group restrito à VPC
- Parâmetro `tls = enabled` no cluster

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.5
- Credenciais AWS configuradas (variáveis de ambiente ou `~/.aws/credentials`)

## Uso local (sandbox)

1. Configure credenciais AWS (ex.: `export AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).
2. Crie `terraform.tfvars` a partir de `terraform.tfvars.example` e defina `documentdb_username` e `documentdb_password` (ou use `TF_VAR_*`).
3. Inicialize e aplique:

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

O state fica local por padrão (adequado para sandbox).

## Uso em CI/CD

O deploy é feito pelo GitHub Actions usando secrets:

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- `DOCUMENTDB_USERNAME`, `DOCUMENTDB_PASSWORD` (ou `TF_VAR_documentdb_username` / `TF_VAR_documentdb_password`)

Em conta sandbox, atualize os secrets no repositório antes de rodar o workflow de deploy.

## Backend remoto (opcional)

Para state em S3 e lock com DynamoDB (recomendado em ambientes não sandbox):

1. Crie um bucket S3 e uma tabela DynamoDB para lock.
2. Crie um arquivo `backend.tf` ou use `-backend-config`:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "SEU_BUCKET"
    key            = "catalogo-documentdb/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

Depois: `terraform init -reconfigure`.

## Variáveis principais

| Variável | Descrição | Default |
|----------|-----------|---------|
| `aws_region` | Região AWS | `us-east-1` |
| `environment` | Ambiente (sandbox, dev, prod) | `sandbox` |
| `project_name` | Prefixo dos recursos | `ecommerce-catalogo` |
| `documentdb_instance_class` | Classe da instância | `docdb.t3.medium` |
| `documentdb_cluster_size` | Número de instâncias | `1` |
| `documentdb_username` | Usuário master | (obrigatório) |
| `documentdb_password` | Senha master | (obrigatório) |

## Outputs

- `documentdb_cluster_endpoint` – endpoint de escrita
- `documentdb_cluster_reader_endpoint` – endpoint de leitura
- `documentdb_port` – porta (27017)
- `vpc_id`, `documentdb_security_group_id`
