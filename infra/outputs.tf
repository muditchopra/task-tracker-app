output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.infra.instance_public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = module.infra.instance_public_dns
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.infra.vpc_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.infra.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.infra.s3_bucket_arn
}

output "api_endpoint" {
  description = "API endpoint URL"
  value       = "http://${module.infra.instance_public_ip}:8000"
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i ~/.ssh/task-tracker-key ubuntu@${module.infra.instance_public_ip}"
}
