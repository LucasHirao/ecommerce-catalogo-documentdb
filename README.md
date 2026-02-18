# E-commerce Catálogo – DocumentDB

Infraestrutura e pipeline CI/CD para o **catálogo** do projeto e-commerce, usando **Amazon DocumentDB** (compatível MongoDB). A modelagem do catálogo está descrita em [ecommerce-docs](https://github.com/LucasHirao/ecommerce-docs) (requisitos, modelagem e arquitetura).

## Conteúdo do repositório

| Caminho              | Descrição                                                     |
| -------------------- | ------------------------------------------------------------- |
| `terraform/`         | Infraestrutura como código (VPC, DocumentDB, security groups) |
| `.github/workflows/` | Pipeline CI/CD (GitHub Actions)                               |
| `docs/`              | Documentação do fluxo (Git Flow, deploy)                      |

## Pré-requisitos

- **Deploy na AWS**: credenciais configuradas como **GitHub Secrets** (em conta sandbox, atualize-as antes de cada deploy).
- **Terraform** >= 1.5 (local ou via CI).

## Pipeline CI/CD (GitHub Actions)

- **CI** (`ci.yml`): em todo **push** em qualquer branch e em **pull requests** para `sandbox`.  
  - `terraform fmt -check`, `terraform init`, `terraform validate`.  
  - Ao final do CI (em push), abre automaticamente um **PR da sua branch para `sandbox`** (se ainda não existir). Aprove e faça merge para disparar o deploy.

- **CD** (`cd.yml`):  
  - **Deploy automático**: ao fazer **merge na branch `sandbox`** (alterações em `terraform/**` ou no workflow CD).  
  - **Deploy manual**: Actions → CD → “Run workflow” (escolha o ambiente: sandbox/dev/prod).

A branch **`sandbox`** deve existir no repositório (crie uma vez a partir de `main` ou `develop` e faça push).

### Secrets necessários no repositório

Configure em **Settings → Secrets and variables → Actions**:

| Secret                  | Descrição                                                                                                                               |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Access key da conta AWS (sandbox ou não)                                                                                                |
| `AWS_SECRET_ACCESS_KEY` | Secret key                                                                                                                              |
| `AWS_REGION`            | Região (ex.: `us-east-1`)                                                                                                               |
| `DOCUMENTDB_USERNAME`   | Usuário master do DocumentDB |
| `DOCUMENTDB_PASSWORD`   | Senha master do DocumentDB   |

Em conta **sandbox**, atualize esses secrets sempre que for fazer um deploy.

## Uso local do Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edite e preencha (ou use TF_VAR_*)
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Detalhes e variáveis: [terraform/README.md](terraform/README.md).

## Git Flow

O repositório segue **Git Flow** com branch **`sandbox`** para deploy em ambiente sandbox:

- **`main`** – produção.
- **`sandbox`** – branch de deploy para ambiente sandbox; **merge aqui dispara o CD** (terraform apply).
- **`develop`** – integração.
- **`feature/*`** – trabalho diário; CI roda a cada push; ao final o CI abre um PR para `sandbox`.

Fluxo resumido:

1. Trabalhe em `feature/nome` (a partir de `develop` ou `sandbox`).
2. Commit e push → **CI roda** (fmt, validate).
3. O CI **abre um PR** da sua branch para `sandbox` (se ainda não existir).
4. Aprove o PR e faça **merge em `sandbox`** → **CD roda** (deploy na AWS).
5. Deploy manual: Actions → CD → Run workflow (quando precisar).

Ver [docs/GITFLOW.md](docs/GITFLOW.md) para detalhes e comandos.

## Licença

Uso interno / projeto pessoal.
