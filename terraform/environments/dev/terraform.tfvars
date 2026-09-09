aws_region                = "ap-south-1"
environment               = "dev"
project_name              = "pulsesg"
cluster_name              = "pulsesg-dev-eks"
vpc_cidr                  = "10.20.0.0/16"
availability_zones        = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs       = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
private_subnet_cidrs      = ["10.20.64.0/20", "10.20.80.0/20", "10.20.96.0/20"]
kubernetes_version        = "1.31"
cluster_api_allowed_cidrs = ["0.0.0.0/0"]
node_groups = {
  general = { instance_types = ["t3.medium"], desired_size = 2, min_size = 1, max_size = 4, disk_size = 50, labels = { workload = "general" } }
}
ecr_repository_names           = ["app1", "app2", "app3"]
ecr_force_delete               = false
create_jenkins_role            = false
jenkins_trusted_principal_arns = []
jenkins_role_arn               = null
