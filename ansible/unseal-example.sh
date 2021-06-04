# #!/usr/bin/bash
# # To use: ./sendCertsAndBounce.sh <fqdn/ip>
# scp -r certs/ ubuntu@$1:/tmp

# ansible-playbook -i inventory certsPlaybook.yaml
# # SSH into each of the VMs and move the certs folder to /etc/vault.d and fix ownership
# sudo mv /tmp/certs /etc/vault.d/
# sudo chown -R vault:vault /etc/vault.d/certs

# # Then bounce the Vault process:
# sudo systemctl restart vault
# systemctl status vault

# Unseal Vault
export VAULT_ADDR=https://localhost:8200
# vault status
vault operator unseal <unseal_key>
