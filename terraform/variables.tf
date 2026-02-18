variable "aws_region" {
  description = "Região AWS para os recursos."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (ex: sandbox, dev, prod)."
  type        = string
  default     = "sandbox"
}

variable "project_name" {
  description = "Nome do projeto (prefixo de recursos)."
  type        = string
  default     = "ecommerce-catalogo"
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "documentdb_instance_class" {
  description = "Classe da instância DocumentDB (ex: docdb.t3.medium)."
  type        = string
  default     = "docdb.t3.medium"
}

variable "documentdb_cluster_size" {
  description = "Número de instâncias no cluster DocumentDB."
  type        = number
  default     = 1
}

variable "documentdb_username" {
  description = "Usuário master do DocumentDB."
  type        = string
  sensitive   = true
}

variable "documentdb_password" {
  description = "Senha master do DocumentDB."
  type        = string
  sensitive   = true
}

variable "enable_terraform_backend" {
  description = "Habilita backend S3 para state (false = state local, útil em sandbox)."
  type        = bool
  default     = false
}

variable "terraform_state_bucket" {
  description = "Bucket S3 para Terraform state (usado se enable_terraform_backend = true)."
  type        = string
  default     = ""
}

variable "terraform_state_key" {
  description = "Chave do objeto de state no S3."
  type        = string
  default     = "catalogo-documentdb/terraform.tfstate"
}

variable "terraform_state_dynamodb_table" {
  description = "Tabela DynamoDB para lock do state."
  type        = string
  default     = ""
}
