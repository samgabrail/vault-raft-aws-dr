# AWS region and AZs in which to deploy
variable "aws_region" {
  default = "us-east-1"
}

variable "secret_names" {
  description = "Migrate these secrets from AWS secrets manager to Vault"
  type        = list(string)
  default     = ["samg-migration-vault", "samg-migration-vault2"]
}
