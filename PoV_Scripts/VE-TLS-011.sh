# Description
# Enable TLS in Vault
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

