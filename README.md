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

- **CI** (`ci.yml`): em todo **push** em `develop` e em **pull requests** para `develop`/`main`  
  - `terraform fmt -check`, `terraform init`, `terraform validate`.

- **CD** (`cd.yml`):  
  - **Deploy manual**: Actions → CD → “Run workflow” (escolha o ambiente: sandbox/dev/prod).  
  - **Deploy automático**: push/merge em `main` que altere `terraform/**` ou o próprio workflow CD.

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

O repositório segue **Git Flow**:

- **`main`** – produção (deploys via CD para o ambiente escolhido).
- **`develop`** – integração; CI roda a cada push.
- **`feature/*`** – novas funcionalidades a partir de `develop`; merge em `develop` via PR.
- **`release/*`** – preparação de release a partir de `develop`; merge em `main` e em `develop`.
- **`hotfix/*`** – correções urgentes a partir de `main`; merge em `main` e em `develop`.

Fluxo resumido:

1. Trabalho diário em `feature/nome` a partir de `develop`.
2. PR de `feature/nome` → `develop` (CI deve passar).
3. Quando for release: branch `release/x.y` a partir de `develop`; após testes, PR para `main` e merge de volta em `develop`.
4. Deploy: merge em `main` ou execução manual do workflow CD.

Ver [docs/GITFLOW.md](docs/GITFLOW.md) para detalhes e comandos.

## Licença

Uso interno / projeto pessoal.
