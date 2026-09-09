output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_cluster_arn" { value = module.eks.cluster_arn }
output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}
output "ecr_repository_urls" { value = module.ecr.repository_urls }
output "cluster_role_arn" { value = module.iam.cluster_role_arn }
output "node_role_arn" { value = module.iam.node_role_arn }
output "ebs_csi_role_arn" { value = module.eks.ebs_csi_role_arn }
output "jenkins_role_arn" { value = module.iam.jenkins_role_arn }
