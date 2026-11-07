terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
 

  backend "s3" {
    bucket         = "carldev-lab-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true 
    encrypt        = true
  }
}



provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Env       = var.environment
      ManagedBy = "terraform"
      Owner     = "carl"
    }
  }
}
