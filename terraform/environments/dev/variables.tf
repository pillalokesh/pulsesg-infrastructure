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
variable "jenkins_principal_arn" {
  type    = string
  default = null
}
variable "jenkins_kubernetes_access_policy_arns" {
  type    = set(string)
  default = ["arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"]
}
variable "jenkins_kubernetes_access_scope" {
  type = object({
    type       = string
    namespaces = set(string)
  })
  default = {
    type       = "namespace"
    namespaces = ["pulsesg-dev"]
  }
}
variable "load_balancer_controller_enabled" {
  type    = bool
  default = true
}
variable "rds_identifier" { type = string }
variable "rds_engine_version" { type = string }
variable "rds_instance_class" { type = string }
variable "rds_allocated_storage" { type = number }
variable "rds_database_name" { type = string }
variable "rds_master_username" { type = string }
variable "rds_port" { type = number }
variable "rds_backup_retention_period" { type = number }
variable "rds_deletion_protection" { type = bool }
variable "rds_skip_final_snapshot" { type = bool }
