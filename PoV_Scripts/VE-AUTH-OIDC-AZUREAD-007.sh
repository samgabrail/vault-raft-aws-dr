# Description
# Use Vault Enterprise OIDC authentication method with Azure AD to authenticate a user to Vault and retrieve a secret. Relevant Vault documentation can be found at the following website: https://www.vaultproject.io/docs/auth/jwt.html
# Setup
# For Azure specific configuration, follow the instructions in this doc: https://www.vaultproject.io/docs/auth/jwt/oidc_providers#azure-active-directory-aad

# In Vault do the following:
# Enable the OIDC auth method
vault auth enable oidc

# Create an oidc policy to test getting a secret
vault policy write oidc policies/oidc.hcl

# Configure the OIDC method
vault write auth/oidc/config oidc_discovery_url="https://login.microsoftonline.com/{tenant}/v2.0" oidc_client_id="CLIENT-ID" oidc_client_secret="CLIENT-SECRET" default_role="demo"

# Create a role in the method
vault write auth/oidc/role/demo \
   user_claim="email" \
   allowed_redirect_uris="http://localhost:8250/oidc/callback,https://online_version_hostname:port_number/ui/vault/auth/oidc/oidc/callback"  \
   groups_claim="groups" \
   oidc_scopes="https://graph.microsoft.com/.default" \
   policies=default,oidc

vault write auth/oidc/role/demo \
   user_claim="email" \
   allowed_redirect_uris="http://localhost:8250/oidc/callback,https://vault-test.tekanaid.com/ui/vault/auth/oidc/oidc/callback"  \
   groups_claim="groups" \
   oidc_scopes="https://graph.microsoft.com/.default" \
   policies=default,oidc

# Important note
# When accessing Vault from the CLI and when using TLS with Vault, make sure to assign the VAULT_CACERT env variable to the ca cert as below
export VAULT_CACERT="certs/ca.pem"
# Ensure that the VAULT_TOKEN variable is unset. Login using
vault login -method=oidc

# Complete the login to the OIDC provider in the browser.

# Expected Results
# The command should return an output similar to the one below:

# Success! You are now authenticated. The token information displayed below is already stored in the token helper. You do NOT need to run "vault login" again. Future Vault requests will automatically use this token.

# Key                  Value
# ---                  ----- 
# token                s.PvtAMIRX21foXgte4norFDyX
# token_accessor       LA7QsCd3wKxPJOXmJk6F2HU9
# token_duration       768h
# token_renewable      true
# token_policies       ["default" "oidcdemo"]
# identity_policies    []
# policies             ["default" "oidcdemo"]
# token_meta_role      demo

# Test putting and getting a secret
vault kv put kv/test foo=bar
vault kv get kv/test

# Connect AD group with Vault external group

# In Vault, create the external group. Record the group ID as you will need it for the group alias.

# From Vault, retrieve the OIDC accessor ID from the OIDC auth method as you will need it for the group alias's mount_accessor.

# Go to the Azure AD Group you want to attach to Vault's external group. Record the objectId as you will need it as the group alias name in Vault.

# In Vault, create a group alias for the external group and set the objectId as the group alias name.

vault write identity/group-alias \
   name="your_ad_group_object_id" \
   mount_accessor="vault_oidc_accessor_id" \
   canonical_id="vault_external_group_id"
