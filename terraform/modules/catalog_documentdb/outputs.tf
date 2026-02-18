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

