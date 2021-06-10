terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.42.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "2.20.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "vault" {
  # Configuration options
}

module "bucket" {
  for_each = toset(var.secret_names)
  source   = "./modules"
  name     = each.value
}
