data "tls_certificate" "oidc" { url = aws_eks_cluster.this.identity[0].oidc[0].issuer }

data "aws_iam_policy_document" "ebs_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}
resource "aws_eks_cluster" "this" {
  name                      = var.name
  role_arn                  = var.cluster_role_arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_log_types
  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.cluster_security_group_id, var.node_security_group_id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }
  access_config { authentication_mode = "API_AND_CONFIG_MAP" }
  tags = var.tags
}
resource "aws_eks_node_group" "this" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = each.value.instance_types
  disk_size       = each.value.disk_size
  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }
  labels = each.value.labels
  update_config { max_unavailable = 1 }
  tags       = merge(var.tags, { Name = "${var.name}-${each.key}" })
  depends_on = [aws_eks_cluster.this]
}
resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  tags            = var.tags
}
resource "aws_iam_role" "ebs_csi" {
  name               = "${var.name}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.ebs_assume.json
  tags               = var.tags
}
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
resource "aws_eks_addon" "this" {
  for_each = {
    vpc_cni    = { name = "vpc-cni", role_arn = null }
    kube_proxy = { name = "kube-proxy", role_arn = null }
    coredns    = { name = "coredns", role_arn = null }
    ebs_csi    = { name = "aws-ebs-csi-driver", role_arn = aws_iam_role.ebs_csi.arn }
  }
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value.name
  service_account_role_arn    = each.value.role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on                  = [aws_eks_node_group.this]
}
resource "aws_eks_access_entry" "this" {
  for_each          = var.access_entries
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.kubernetes_groups
  type              = "STANDARD"
}
locals {
  access_policies = flatten([for entry_key, entry in var.access_entries : [for policy_arn in entry.policy_arns : { key = "${entry_key}-${policy_arn}", entry_key = entry_key, policy_arn = policy_arn }]])
}
resource "aws_eks_access_policy_association" "this" {
  for_each      = { for item in local.access_policies : item.key => item }
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.access_entries[each.value.entry_key].principal_arn
  policy_arn    = each.value.policy_arn
  access_scope { type = "cluster" }
}
