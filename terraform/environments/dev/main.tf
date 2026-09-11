locals {
  common_tags = { Project = var.project_name, Environment = var.environment, ManagedBy = "Terraform" }
  jenkins_access_entries = var.jenkins_principal_arn == null ? {} : {
    jenkins = {
      principal_arn     = var.jenkins_principal_arn
      kubernetes_groups = []
      policy_arns       = var.jenkins_kubernetes_access_policy_arns
      access_scope      = var.jenkins_kubernetes_access_scope
    }
  }
}
module "vpc" {
  source               = "../../modules/vpc"
  name                 = "${var.project_name}-${var.environment}"
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}
module "security" {
  source                    = "../../modules/security"
  name                      = "${var.project_name}-${var.environment}"
  vpc_id                    = module.vpc.vpc_id
  cluster_api_allowed_cidrs = var.cluster_api_allowed_cidrs
  tags                      = local.common_tags
}
module "ecr" {
  source           = "../../modules/ecr"
  repository_names = var.ecr_repository_names
  force_delete     = var.ecr_force_delete
  tags             = local.common_tags
}
module "rds" {
  source                        = "../../modules/rds"
  identifier                    = var.rds_identifier
  engine_version                = var.rds_engine_version
  instance_class                = var.rds_instance_class
  allocated_storage             = var.rds_allocated_storage
  database_name                 = var.rds_database_name
  master_username               = var.rds_master_username
  port                          = var.rds_port
  vpc_id                        = module.vpc.vpc_id
  subnet_ids                    = module.vpc.private_subnet_ids
  application_security_group_id = module.eks.cluster_security_group_id
  backup_retention_period       = var.rds_backup_retention_period
  deletion_protection           = var.rds_deletion_protection
  skip_final_snapshot           = var.rds_skip_final_snapshot
  tags                          = local.common_tags
}
module "iam" {
  source                         = "../../modules/iam"
  name                           = "${var.project_name}-${var.environment}"
  ecr_repository_arns            = values(module.ecr.repository_arns)
  create_jenkins_role            = var.create_jenkins_role
  jenkins_trusted_principal_arns = var.jenkins_trusted_principal_arns
  tags                           = local.common_tags
}
module "eks" {
  source                           = "../../modules/eks"
  name                             = var.cluster_name
  kubernetes_version               = var.kubernetes_version
  subnet_ids                       = module.vpc.private_subnet_ids
  cluster_security_group_id        = module.security.cluster_security_group_id
  node_security_group_id           = module.security.node_security_group_id
  cluster_role_arn                 = module.iam.cluster_role_arn
  node_role_arn                    = module.iam.node_role_arn
  public_access_cidrs              = var.cluster_api_allowed_cidrs
  node_groups                      = var.node_groups
  access_entries                   = local.jenkins_access_entries
  load_balancer_controller_enabled = var.load_balancer_controller_enabled
  tags                             = local.common_tags
}
