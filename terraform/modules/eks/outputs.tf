output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_arn" { value = aws_eks_cluster.this.arn }
output "cluster_endpoint" {
  value     = aws_eks_cluster.this.endpoint
  sensitive = true
}
output "oidc_provider_arn" { value = aws_iam_openid_connect_provider.this.arn }
output "ebs_csi_role_arn" { value = aws_iam_role.ebs_csi.arn }
output "load_balancer_controller_role_arn" { value = try(aws_iam_role.load_balancer_controller[0].arn, null) }
output "node_role_arn" { value = var.node_role_arn }
output "cluster_security_group_id" { value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id }
