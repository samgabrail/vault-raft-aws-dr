# Description
# Enable TLS in Vault

# Important note: if you need to include a CA's cert then concatenate it with the primary cert. The primary cert has to come in first as per https://www.vaultproject.io/docs/configuration/listener/tcp#tls_cert_file
# It will look like this below (some lines are ommitted)
# Good docs on using ELB for loadbalancing with Vault
# https://registry.terraform.io/modules/hashicorp/vault/aws/latest/submodules/vault-elb#how-is-the-elb-configured

# -----BEGIN CERTIFICATE-----
# MIIEpDCCA4ygAwIBAgIUQH7/TloKpVrsd4qmzAyqobVPRdUwDQYJKoZIhvcNAQEL
# BQAwgYsxCzAJBgNVBAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTQw
# FeNMyGTziOqe7EE9sdPYK7f07KKI5jo3S2UJW8mWEK48XW69LO61mUDWxJ5gJrQp
# jbvjHYOWCvIjmjKgOym28rFo9i9j/2VKcA5H8JI55MYew/IxqS7Uip8Svs/2kazX
# iStpaQguD/JmRoD92V9/8dVMaTbXgJwqHqi4MkuZbMGf4WybIjOxezG3jAfd6glq
# JfXVBx+xWl8SbeKASQxv+FfG90hNNIQtX+YVWQFd/z1idgrYhLXOoQ==
# -----END CERTIFICATE-----
# -----BEGIN CERTIFICATE-----
# MIIEADCCAuigAwIBAgIID+rOSdTGfGcwDQYJKoZIhvcNAQELBQAwgYsxCzAJBgNV
# BAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTQwMgYDVQQLEytDbG91
# ZEZsYXJlIE9yaWdpbiBTU0wgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MRYwFAYDVQQH
# hhurjcoacvRNhnjtDRM0dPeiCJ50CP3wEYuvUzDHUaowOsnLCjQIkWbR7Ni6KEIk
# MOz2U0OBSif3FTkhCgZWQKOOLo1P42jHC3ssUZAtVNXrCk3fw9/E15k8NPkBazZ6
# 0iykLhH1trywrKRMVw67F44IE8Y=
# -----END CERTIFICATE-----

# You'll need to repeat the steps below on all members of the primary cluster including the DR cluster
# SCP the cert and private key over to the VMs
scp -r certs/ ubuntu@52.205.8.7:/tmp

# Update the configuration file on each of the nodes which is found to include the following:
sudo vim /etc/vault.d/vault.hcl

# under the listener stanza remove:
# tls_disable = true

# and add:
# tls_cert_file = "/etc/vault.d/certs/crt.pem"
# tls_key_file  = "/etc/vault.d/certs/private_key.pem"

# to look like this:
# listener "tcp" {
#   address     = "0.0.0.0:8200"
#   cluster_address     = "0.0.0.0:8201"
#   tls_cert_file = "/etc/vault.d/certs/crt.pem"
#   tls_key_file  = "/etc/vault.d/certs/private_key.pem"
# }

# You can leverage ansible for the steps below this is found in the ansible folder
# SSH into each of the VMs and move the certs folder to /etc/vault.d and fix ownership
sudo mv /tmp/certs /etc/vault.d/
sudo chown -R vault:vault /etc/vault.d/certs

# Then bounce the Vault process:
sudo systemctl restart vault
systemctl status vault

# Unseal Vault
export VAULT_ADDR=https://localhost:8200
vault status
vault operator unseal

# Important note
# When accessing Vault from the CLI, make sure to assign the VAULT_CACERT env variable to the ca cert as below
export VAULT_CACERT="certs/ca.pem"
# Otherwise you may get this error:
# x509: certificate signed by unknown authority