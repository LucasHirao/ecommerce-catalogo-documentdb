output "documentdb_cluster_endpoint" {
  description = "Endpoint do cluster DocumentDB (catálogo)."
  value       = aws_docdb_cluster.catalogo.endpoint
}

output "documentdb_cluster_reader_endpoint" {
  description = "Endpoint de leitura (replicas)."
  value       = aws_docdb_cluster.catalogo.reader_endpoint
}

output "documentdb_port" {
  description = "Porta do DocumentDB."
  value       = aws_docdb_cluster.catalogo.port
}

output "vpc_id" {
  description = "ID da VPC (existente ou criada)."
  value       = local.vpc_id_in_use
}

output "documentdb_security_group_id" {
  description = "ID do security group do DocumentDB."
  value       = aws_security_group.documentdb.id
}

# Parameter Store e Secrets Manager (para injeção em ECS)
output "ssm_parameter_endpoint" {
  description = "Nome do parâmetro SSM com o endpoint do DocumentDB (para ECS)."
  value       = aws_ssm_parameter.documentdb_endpoint.name
}

output "ssm_parameter_port" {
  description = "Nome do parâmetro SSM com a porta do DocumentDB (para ECS)."
  value       = aws_ssm_parameter.documentdb_port.name
}

output "ssm_parameter_username" {
  description = "Nome do parâmetro SSM com o usuário master (para ECS)."
  value       = aws_ssm_parameter.documentdb_username.name
}

output "secretsmanager_password_arn" {
  description = "ARN do secret no Secrets Manager com a senha master (para ECS e rotação)."
  value       = aws_secretsmanager_secret.documentdb_password.arn
}

