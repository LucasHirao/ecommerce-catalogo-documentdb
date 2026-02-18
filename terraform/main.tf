module "catalog_documentdb" {
  source = "./modules/catalog_documentdb"

  aws_region                = var.aws_region
  environment               = var.environment
  project_name              = var.project_name
  use_existing_vpc          = var.use_existing_vpc
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  vpc_cidr                  = var.vpc_cidr
  documentdb_instance_class = var.documentdb_instance_class
  documentdb_cluster_size   = var.documentdb_cluster_size
  documentdb_username       = var.documentdb_username
  documentdb_password       = var.documentdb_password
}
