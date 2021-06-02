path "sys/*" {
  capabilities = ["deny"]
}
path "kv/*" {
  capabilities = ["create","read","update","delete"]
}