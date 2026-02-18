locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# VPC e subnets para DocumentDB (melhores práticas: subnets privadas)
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "private" {
  count             = min(3, length(data.aws_availability_zones.available.names))
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${count.index + 1}"
  })
}

resource "aws_db_subnet_group" "documentdb" {
  name       = "${local.name_prefix}-documentdb"
  subnet_ids = aws_subnet.private[*].id

  tags = local.common_tags
}

resource "aws_security_group" "documentdb" {
  name_prefix = "${local.name_prefix}-documentdb-"
  description = "Security group para cluster DocumentDB (catálogo)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "DocumentDB MongoDB port"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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
  master_username                 = var.documentdb_username
  master_password                 = var.documentdb_password
  db_subnet_group_name            = aws_db_subnet_group.documentdb.name
  vpc_security_group_ids          = [aws_security_group.documentdb.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.catalogo.name
  storage_encrypted               = true
  skip_final_snapshot       = var.environment == "sandbox"
  final_snapshot_identifier = var.environment == "sandbox" ? null : "${local.name_prefix}-final"

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
