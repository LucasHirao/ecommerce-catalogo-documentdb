locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# VPC e subnets: existentes na conta ou criados pelo Terraform
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC e subnets existentes (quando use_existing_vpc = true)
data "aws_vpc" "existing" {
  count = var.use_existing_vpc ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "existing" {
  count = var.use_existing_vpc && length(var.subnet_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Subnets existentes: se subnet_ids for informado, usa; senão usa as descobertas pela VPC
locals {
  existing_subnet_ids = var.use_existing_vpc ? (length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.existing[0].ids) : []
  vpc_cidr_for_sg     = var.use_existing_vpc ? data.aws_vpc.existing[0].cidr_block : var.vpc_cidr
}

# VPC nova (quando use_existing_vpc = false)
resource "aws_vpc" "main" {
  count                = var.use_existing_vpc ? 0 : 1
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "private" {
  count             = var.use_existing_vpc ? 0 : min(3, length(data.aws_availability_zones.available.names))
  vpc_id            = aws_vpc.main[0].id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${count.index + 1}"
  })
}

# ID da VPC e subnets em uso (existente ou criada)
locals {
  vpc_id_in_use     = var.use_existing_vpc ? var.vpc_id : aws_vpc.main[0].id
  subnet_ids_in_use = var.use_existing_vpc ? local.existing_subnet_ids : aws_subnet.private[*].id
}

resource "aws_db_subnet_group" "documentdb" {
  name       = "${local.name_prefix}-documentdb"
  subnet_ids = local.subnet_ids_in_use

  tags = local.common_tags
}

resource "aws_security_group" "documentdb" {
  name_prefix = "${local.name_prefix}-documentdb-"
  description = "Security group for DocumentDB cluster (catalog)"
  vpc_id      = local.vpc_id_in_use

  ingress {
    description = "DocumentDB MongoDB port"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_for_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-documentdb"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# DocumentDB cluster (catálogo - compatível com MongoDB)
# -----------------------------------------------------------------------------
resource "aws_docdb_cluster" "catalogo" {
  cluster_identifier              = "${local.name_prefix}-cluster"
  engine                          = "docdb"
  engine_version                  = "5.0.0"
  master_username                 = var.documentdb_username
  master_password                 = var.documentdb_password
  db_subnet_group_name            = aws_db_subnet_group.documentdb.name
  vpc_security_group_ids          = [aws_security_group.documentdb.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.catalogo.name
  storage_encrypted               = true
  skip_final_snapshot             = var.environment == "sandbox"
  final_snapshot_identifier       = var.environment == "sandbox" ? null : "${local.name_prefix}-final"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cluster"
  })
}

resource "aws_docdb_cluster_parameter_group" "catalogo" {
  family = "docdb5.0"
  name   = "${local.name_prefix}-params"

  parameter {
    name  = "tls"
    value = "enabled"
  }

  tags = local.common_tags
}

resource "aws_docdb_cluster_instance" "catalogo" {
  count              = var.documentdb_cluster_size
  identifier         = "${local.name_prefix}-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.catalogo.id
  instance_class     = var.documentdb_instance_class

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-instance-${count.index + 1}"
  })
}

# -----------------------------------------------------------------------------
# Parameter Store (SSM): endpoint e usuário para injeção em ECS
# -----------------------------------------------------------------------------
locals {
  ssm_prefix = "/catalogo/documentdb/${var.environment}"
}

resource "aws_ssm_parameter" "documentdb_endpoint" {
  name        = "${local.ssm_prefix}/endpoint"
  description = "DocumentDB cluster endpoint for ECS"
  type        = "String"
  value       = aws_docdb_cluster.catalogo.endpoint
  overwrite   = true

  tags = local.common_tags
}

resource "aws_ssm_parameter" "documentdb_port" {
  name        = "${local.ssm_prefix}/port"
  description = "DocumentDB port for ECS"
  type        = "String"
  value       = tostring(aws_docdb_cluster.catalogo.port)
  overwrite   = true

  tags = local.common_tags
}

resource "aws_ssm_parameter" "documentdb_username" {
  name        = "${local.ssm_prefix}/username"
  description = "DocumentDB master username for ECS"
  type        = "String"
  value       = var.documentdb_username
  overwrite   = true

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Secrets Manager: senha master (para rotação e injeção em ECS)
# -----------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "documentdb_password" {
  name                    = "catalogo-documentdb-${var.environment}-master-password"
  description             = "DocumentDB master password - rotation via Secrets Manager"
  recovery_window_in_days = 7

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "documentdb_password" {
  secret_id     = aws_secretsmanager_secret.documentdb_password.id
  secret_string = var.documentdb_password
}

