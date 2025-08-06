module "infra" {
  source = "module"

  aws_region         = "ap-south-1"
  project_name       = "task-tracker"
  environment        = "prod"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.10.0.0/24"
  instance_type      = "t3.medium"
}
