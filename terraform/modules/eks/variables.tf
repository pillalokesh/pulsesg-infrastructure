variable "name" { type = string }
variable "kubernetes_version" { type = string }
variable "subnet_ids" { type = list(string) }
variable "cluster_security_group_id" { type = string }
variable "node_security_group_id" { type = string }
variable "cluster_role_arn" { type = string }
variable "node_role_arn" { type = string }
variable "endpoint_private_access" {
  type    = bool
  default = true
}
variable "endpoint_public_access" {
  type    = bool
  default = true
}
variable "public_access_cidrs" {
  type    = list(string)
  default = []
}
variable "enabled_log_types" {
  type    = set(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
variable "node_groups" {
  type = map(object({ instance_types = list(string), desired_size = number, min_size = number, max_size = number, disk_size = number, labels = map(string) }))
}
variable "access_entries" {
  type    = map(object({ principal_arn = string, kubernetes_groups = list(string), policy_arns = set(string) }))
  default = {}
}
variable "tags" {
  type    = map(string)
  default = {}
}
