output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.task_tracker_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.task_tracker_instance.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.task_tracker_sg.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.task_tracker_vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.task_tracker_public_subnet.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.task_tracker_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.task_tracker_bucket.arn
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.task_tracker_key.key_name
}

output "api_endpoint" {
  description = "API endpoint URL"
  value       = "http://${aws_instance.task_tracker_instance.public_ip}:8000"
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i ~/.ssh/task-tracker-key ubuntu@${aws_instance.task_tracker_instance.public_ip}"
}
