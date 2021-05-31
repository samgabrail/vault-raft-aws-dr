# Description
# Use Vault Enterprise ‘transit’ backend to encrypt and decrypt information via CLI.
# Setup

# First, enable the transit backend
vault secrets enable transit
# Success! Enabled the transit secrets engine at: transit/

# Next, create a transit key ring to be used for encryption and decryption using the CLI
vault write -f transit/keys/orders
# Success! Data written to: transit/keys/orders

# Create a policy named app-orders:
vault policy write app-orders policies/app-orders.hcl
# Success! Uploaded policy: app-orders

# Create a token with app-orders policy attached:
vault token create -policy=app-orders

# Key                  Value
# ---                  -----
# token                s.7eU86tmA7IKKLWCGzB4mFRKT
# token_accessor       2LIRvddCF0D2OximiR8KxFB2
# token_duration       768h
# token_renewable      true
# token_policies       ["app-orders" "default"]
# identity_policies    []
# policies             ["app-orders" "default"]

# Copy/retain the generated token as you will use it to request data encryption and decryption.

# From any host, ensure that the proper environment variables are set:
# VAULT_TOKEN
# VAULT_ADDR (to HTTPS host)

# To encrypt your secret, set VAULT_TOKEN to the token from prior step and use the transit/encrypt endpoint:
VAULT_TOKEN=<TOKEN> vault write transit/encrypt/orders \
plaintext=$(base64 <<< "4111 1111 1111 1111")

# Key            Value
# ---            -----
# ciphertext     vault:v1:VsGb7RMbSieLfg75/sQRDQOT7zyI...
# key_version    1

# To decrypt your secret, set VAULT_TOKEN to the token from prior step and supply the cipher text:
VAULT_TOKEN=<TOKEN> vault write transit/decrypt/orders \
ciphertext="vault:v1:VsGb7RMbSieLfg75/sQRDQOT7zyI…"

# Key          Value
# ---          -----
# plaintext    NDExMSAxMTExIDExMTEgMTExMQo=

# The resulting data is base64-encoded and must be decoded to reveal the plaintext:

base64 --decode <<< "NDExMSAxMTExIDExMTEgMTExMQo="
# 4111 1111 1111 1111

# Expected Results
# Successful encryption and decryption of data using Vault CLI.

