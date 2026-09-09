variable "name" { type = string }
variable "vpc_id" { type = string }
variable "cluster_api_allowed_cidrs" { type = list(string) }
variable "tags" {
  type    = map(string)
  default = {}
}
