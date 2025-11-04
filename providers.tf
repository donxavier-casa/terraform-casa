terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# cloudfront + cert must be in us-east-1 for ACM
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
