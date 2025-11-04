variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name (prod/staging)"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "13.7"
}

variable "db_allocated_storage" {
  type    = number
  default = 100
}

variable "route53_zone_id" {
  description = "Optional Route53 hosted zone id for DNS and ACM validation. Leave empty to skip."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Optional domain name to assign to CloudFront distribution (e.g. app.example.com). Requires route53_zone_id."
  type        = string
  default     = ""
}

variable "ecr_tag_retention_count" {
  description = "How many images to keep in ECR lifecycle"
  type        = number
  default     = 30
}

variable "lambda_image_uri" {
  description = "ECR image URI for lambda function (provide after CI builds and pushes). e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:sha"
  type        = string
  default     = ""
}

variable "github_oidc_role_name" {
  description = "Name for IAM role used by GitHub Actions OIDC"
  type        = string
  default     = "github-actions-oidc-role"
}
