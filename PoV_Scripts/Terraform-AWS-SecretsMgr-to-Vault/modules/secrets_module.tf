variable "name" {}

data "aws_secretsmanager_secret" "mysecret" {
  name = var.name
}

data "aws_secretsmanager_secret_version" "mysecret" {
  secret_id = data.aws_secretsmanager_secret.mysecret.id
}

resource "vault_generic_secret" "developer_sample_data" {
  path = "kv/${var.name}"

  data_json = data.aws_secretsmanager_secret_version.mysecret.secret_string
}