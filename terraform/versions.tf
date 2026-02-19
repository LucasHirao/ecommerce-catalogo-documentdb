terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # State remoto no bucket do ecommerce-infra-common (mesma conta).
  # Bucket: <account_id>-stage-terraform (criado no repositório ecommerce-infra-common).
  # Forneça o bucket em init: terraform init -backend-config="bucket=<account_id>-stage-terraform"
  backend "s3" {
    key    = "catalogo-documentdb/terraform.tfstate"
    region = "us-east-1"
    # bucket = obrigatório via -backend-config (ex.: 123456789012-stage-terraform)
  }
}
