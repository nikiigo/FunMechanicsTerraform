output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Elastic IP attached to the instance."
  value       = aws_eip.web.public_ip
}

output "public_ipv6" {
  description = "Public IPv6 address attached to the instance."
  value       = aws_instance.web.ipv6_addresses[0]
}

output "private_ipv4" {
  description = "Private IPv4 address of the instance."
  value       = aws_instance.web.private_ip
}

output "site_url" {
  description = "Website URL."
  value       = "https://${var.domain_name}:8443/"
}

output "vpc_id" {
  description = "Managed VPC ID."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Managed public subnet ID."
  value       = aws_subnet.public.id
}
