variable "name" { type = string }
variable "ecr_repository_arns" {
  type    = list(string)
  default = []
}
variable "create_jenkins_role" {
  type    = bool
  default = false
}
variable "jenkins_trusted_principal_arns" {
  type    = list(string)
  default = []
  validation {
    condition     = !var.create_jenkins_role || length(var.jenkins_trusted_principal_arns) > 0
    error_message = "Trusted principal ARNs are required for the Jenkins role."
  }
}
variable "tags" {
  type    = map(string)
  default = {}
}
