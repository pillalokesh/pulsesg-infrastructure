locals {
  common_tags = { Project = var.project_name, Environment = var.environment, ManagedBy = "Terraform" }
  jenkins_access_entries = var.jenkins_role_arn == null ? {} : {
    jenkins = {
      principal_arn     = var.jenkins_role_arn
      kubernetes_groups = []
      policy_arns       = ["arn:aws:iam::aws:policy/AmazonEKSClusterAdminPolicy"]
    }
  }
}
module "vpc" {
  source               = "../../modules/vpc"
  name                 = "${var.project_name}-${var.environment}"
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
module "iam" {
  source                         = "../../modules/iam"
  name                           = "${var.project_name}-${var.environment}"
  ecr_repository_arns            = values(module.ecr.repository_arns)
  create_jenkins_role            = var.create_jenkins_role
  jenkins_trusted_principal_arns = var.jenkins_trusted_principal_arns
  tags                           = local.common_tags
}
module "eks" {
  source                    = "../../modules/eks"
  name                      = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  subnet_ids                = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security.cluster_security_group_id
  node_security_group_id    = module.security.node_security_group_id
  cluster_role_arn          = module.iam.cluster_role_arn
  node_role_arn             = module.iam.node_role_arn
  public_access_cidrs       = var.cluster_api_allowed_cidrs
  node_groups               = var.node_groups
  access_entries            = local.jenkins_access_entries
  tags                      = local.common_tags
}
