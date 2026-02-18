# Terraform – Catálogo DocumentDB

Infraestrutura como código para o cluster **Amazon DocumentDB** do projeto de catálogo do e-commerce ([ecommerce-docs](https://github.com/LucasHirao/ecommerce-docs)).

## Recursos

- VPC com subnets privadas em múltiplas AZs
- Cluster DocumentDB (compatível MongoDB) com criptografia e TLS
- Security group restrito à VPC
- Parâmetro `tls = enabled` no cluster
- **Parameter Store (SSM)**: endpoint, porta e usuário do DocumentDB (para injeção em ECS)
- **Secrets Manager**: senha master do DocumentDB (para rotação e injeção em ECS)

A infraestrutura está organizada no módulo `modules/catalog_documentdb`.

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

O state fica **local** por padrão (adequado para sandbox).

## Uso em CI/CD

O deploy é feito pelo GitHub Actions usando secrets:

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- `DOCUMENTDB_USERNAME`, `DOCUMENTDB_PASSWORD`

Em conta sandbox, atualize os secrets no repositório antes de rodar o workflow de deploy.

## Variáveis principais

| Variável | Descrição | Default |
|----------|-----------|---------|
| `aws_region` | Região AWS | `us-east-1` |
| `environment` | Ambiente (sandbox, dev, prod) | `sandbox` |
| `project_name` | Prefixo dos recursos | `ecommerce-catalogo` |
| **`use_existing_vpc`** | Se `true`, usa VPC e subnets já existentes na conta | `false` |
| **`vpc_id`** | ID da VPC existente (obrigatório se `use_existing_vpc = true`) | `""` |
| **`subnet_ids`** | IDs das subnets existentes (mín. 2 em AZs diferentes). Vazio = todas as subnets da VPC | `[]` |
| `vpc_cidr` | CIDR da VPC (só quando `use_existing_vpc = false`) | `10.0.0.0/16` |
| `documentdb_instance_class` | Classe da instância | `docdb.t3.medium` |
| `documentdb_cluster_size` | Número de instâncias | `1` |
| `documentdb_username` | Usuário master | (obrigatório) |
| `documentdb_password` | Senha master | (obrigatório) |

### Usar VPC existente na sandbox

1. No console AWS (ou CLI), anote o **ID da VPC** e os **IDs de pelo menos 2 subnets** em AZs diferentes (DocumentDB exige isso).
2. Defina no `terraform.tfvars` ou em variáveis de ambiente:
   - `use_existing_vpc = true`
   - `vpc_id = "vpc-xxxxxxxx"`
   - `subnet_ids = ["subnet-aaa", "subnet-bbb"]`  
   Se `subnet_ids` for omitido ou `[]`, o Terraform usa **todas as subnets** da VPC informada (descoberta automática).

## Outputs

- `documentdb_cluster_endpoint` – endpoint de escrita
- `documentdb_cluster_reader_endpoint` – endpoint de leitura
- `documentdb_port` – porta (27017)
- `vpc_id`, `documentdb_security_group_id`
- **`ssm_parameter_endpoint`**, **`ssm_parameter_port`**, **`ssm_parameter_username`** – nomes dos parâmetros SSM para ECS (`valueFrom` na task definition)
- **`secretsmanager_password_arn`** – ARN do secret da senha no Secrets Manager (para ECS e rotação de senha)

### Injeção em ECS

Na task definition do ECS, use `secrets` com `valueFrom` apontando para:

- **Endpoint**: `arn:aws:ssm:REGION:ACCOUNT:parameter/catalogo/documentdb/ENVIRONMENT/endpoint`
- **Porta**: `arn:aws:ssm:REGION:ACCOUNT:parameter/catalogo/documentdb/ENVIRONMENT/port`
- **Usuário**: `arn:aws:ssm:REGION:ACCOUNT:parameter/catalogo/documentdb/ENVIRONMENT/username`
- **Senha**: ARN do secret (output `secretsmanager_password_arn`)

A senha fica no Secrets Manager para permitir **rotação** sem alterar o Terraform; após rotacionar, atualize o valor do secret no console ou via CLI.
