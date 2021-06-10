// output "secret_id" {
//   value = data.aws_secretsmanager_secret.mysecret.id
// }
// output "secret_value" {
//   sensitive = true
//   value = data.aws_secretsmanager_secret_version.mysecret.secret_string
// }
// output "example" {
//   sensitive = true
//   value = jsondecode(data.aws_secretsmanager_secret_version.mysecret.secret_string)["username"]
// }