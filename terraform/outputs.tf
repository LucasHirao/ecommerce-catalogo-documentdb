output "documentdb_cluster_endpoint" {
  description = "Endpoint do cluster DocumentDB (catálogo)."
  value       = module.catalog_documentdb.documentdb_cluster_endpoint
}

output "documentdb_cluster_reader_endpoint" {
  description = "Endpoint de leitura (replicas)."
  value       = module.catalog_documentdb.documentdb_cluster_reader_endpoint
}

output "documentdb_port" {
  description = "Porta do DocumentDB."
  value       = module.catalog_documentdb.documentdb_port
}

output "vpc_id" {
  description = "ID da VPC (existente ou criada)."
  value       = module.catalog_documentdb.vpc_id
}

output "documentdb_security_group_id" {
  description = "ID do security group do DocumentDB."
  value       = module.catalog_documentdb.documentdb_security_group_id
}

# Parameter Store e Secrets Manager (para injeção em ECS)
output "ssm_parameter_endpoint" {
  description = "Nome do parâmetro SSM com o endpoint do DocumentDB (para ECS)."
  value       = module.catalog_documentdb.ssm_parameter_endpoint
}

output "ssm_parameter_port" {
  description = "Nome do parâmetro SSM com a porta do DocumentDB (para ECS)."
  value       = module.catalog_documentdb.ssm_parameter_port
}

output "ssm_parameter_username" {
  description = "Nome do parâmetro SSM com o usuário master (para ECS)."
  value       = module.catalog_documentdb.ssm_parameter_username
}

output "secretsmanager_password_arn" {
  description = "ARN do secret no Secrets Manager com a senha master (para ECS e rotação)."
  value       = module.catalog_documentdb.secretsmanager_password_arn
}
