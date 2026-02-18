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

variable "use_existing_vpc" {
  description = "Se true, usa VPC e subnets já existentes na conta (use vpc_id e subnet_ids)."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID da VPC existente (obrigatório se use_existing_vpc = true)."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "IDs das subnets existentes para o DocumentDB (obrigatório se use_existing_vpc = true; mínimo 2 em AZs diferentes)."
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR da VPC (usado apenas quando use_existing_vpc = false, para criar nova VPC)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "documentdb_instance_class" {
  description = "Classe da instância DocumentDB (ex: docdb.t3.medium)."
  type        = string
  default     = "db.t3.medium"
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
