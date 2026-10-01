output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "ec2_instance_id" {
  description = "ID of the application EC2 instance"
  value       = aws_instance.app.id
}

output "ec2_public_ip" {
  description = "Public IP of the application EC2 instance"
  value       = aws_instance.app.public_ip
}
output "ansible_ssm_bucket_name" {
  description = "S3 bucket used for Ansible SSM file transfers"
  value       = aws_s3_bucket.ansible_ssm.bucket
}
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}
output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mysql.endpoint
}