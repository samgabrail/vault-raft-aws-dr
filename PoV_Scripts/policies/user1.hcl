path "sys/*" {
  capabilities = ["deny"]
}
path "kv/user1" {
  capabilities = ["create","read","update","delete"]
}