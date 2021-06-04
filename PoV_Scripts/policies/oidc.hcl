path "sys/*" {
  capabilities = ["deny"]
}
path "kv/*" {
  capabilities = ["list","create","read","update","delete"]
}