variable "aws_region" {
  description = "AWS region for the deployment."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name prefix used for AWS resources."
  type        = string
  default     = "example"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t4g.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Availability zone for the public subnet."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR block for the public subnet."
  type        = string
  default     = "10.42.1.0/24"
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed to reach Caddy on port 8443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_ipv6_cidrs" {
  description = "IPv6 CIDR blocks allowed to reach Caddy on port 8443."
  type        = list(string)
  default     = ["::/0"]
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for example.net."
  type        = string
  default     = "Z08479271XFDSBHEXAMPLE"
}

variable "domain_name" {
  description = "Website domain name."
  type        = string
  default     = "example.net"
}

variable "site_name" {
  description = "Short site name used for the deployment directory under /srv."
  type        = string
  default     = "example"
}

variable "site_repo_url" {
  description = "Git repository URL for the website content."
  type        = string
  default     = "https://github.com/nikiigo/example.git"
}

variable "site_repo_branch" {
  description = "Branch to clone for the website deployment."
  type        = string
  default     = "main"
}
