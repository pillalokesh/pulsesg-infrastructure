terraform {
  backend "s3" {
    bucket       = "pulsesg-terraform-state-dev"
    key          = "pulsesg/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
