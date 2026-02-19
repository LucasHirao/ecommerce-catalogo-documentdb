# Configuração do backend S3 para o state (bucket do ecommerce-infra-common).
# Cópia como backend.hcl e preencha o bucket com o nome da sua conta:
#   bucket = "<ACCOUNT_ID>-stage-terraform"
#
# Uso:
#   terraform init -backend-config=backend.hcl
#
# O bucket é criado pelo repositório ecommerce-infra-common na mesma conta.

bucket = "<ACCOUNT_ID>-stage-terraform"
# key e region já estão definidos em versions.tf; descomente para sobrescrever:
# key    = "catalogo-documentdb/terraform.tfstate"
# region = "us-east-1"
