variable "aws_region" { type = string }
variable "environment" { type = string }
variable "project_name" { type = string }
variable "cluster_name" { type = string }
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "kubernetes_version" { type = string }
variable "cluster_api_allowed_cidrs" { type = list(string) }
variable "node_groups" { type = map(object({ instance_types = list(string), desired_size = number, min_size = number, max_size = number, disk_size = number, labels = map(string) })) }
variable "ecr_repository_names" { type = set(string) }
variable "ecr_force_delete" {
  type    = bool
  default = false
}
variable "create_jenkins_role" {
  type    = bool
  default = false
}
variable "jenkins_trusted_principal_arns" {
  type    = list(string)
  default = []
}
variable "jenkins_role_arn" {
  type    = string
  default = null
}
