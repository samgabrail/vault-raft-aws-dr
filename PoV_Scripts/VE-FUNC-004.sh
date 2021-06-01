# Description
# Perform CRUD secret operations. Verify how basic policies manage access to secrets. Vault reference documentation for tokens and policy management can be found here: 
# https://www.vaultproject.io/docs/auth/token.html
# https://www.vaultproject.io/docs/concepts/tokens.html
# https://www.vaultproject.io/docs/concepts/policies.html

# Enable the basic User/Password authentication method:
vault auth enable userpass
# Success! Enabled userpass auth method at: userpass/

# Enable the KV version 2 secrets engine:
vault secrets enable kv
# Success! Enabled the kv-v2 secrets engine at: kv/

# Create two basic policies, in two plain text files:

# Contents of policies/user1.hcl:
# path "sys/*" {
#   capabilities = ["deny"]
# }
# path "kv/user1" {
#   capabilities = ["create","read","update","delete"]
# }


# Contents of policies/user2.hcl
# path "kv/user2" {
#   capabilities = ["create","read"]
# }

# These policies need to be imported into Vault.

vault policy write user1 policies/user1.hcl
# Success! Uploaded policy: user1

vault policy write user2 policies/user2.hcl
# Success! Uploaded policy: user2

# Create accounts for the users and policies
vault write auth/userpass/users/user1 \
password=user1P@SS \
policies=user1
# Success! Data written to: auth/userpass/users/user1

vault write auth/userpass/users/user2 \
password=user2P@SS \
policies=user2
# Success! Data written to: auth/userpass/users/user2

# Create entities for each user account

vault write identity/entity name=user1 policies=user1
# Key     	Value
# ---     	-----
# aliases 	<nil>
# id           ea81fda9-9126-6f30-3190-1dd9d6c456b2
# name         user1

vault write identity/entity name=user2 policies=user2
# Key     	Value
# ---     	-----
# aliases 	<nil>
# id           2d198f96-ffa4-5933-39fb-abdbf012222e
# name         user1

vault auth list
# Path     	Type     	Accessor     	     	Description
# ---     	-----     	--------     	     	-----------
# token/     	token     	auth_token_ed02f550 token based...
# userpass/    userpass     auth_userpass_a09e8295

# Associate user accounts to each entity (values from commands above)
vault write identity/entity-alias \
name=user1 \
canonical_id=ea81fda9-9126-6f30-3190-1dd9d6c456b2 \ 
mount_accessor=auth_userpass_a09e8295

vault write identity/entity-alias \
name=user2 \
canonical_id=2d198f96-ffa4-5933-39fb-abdbf012222e \ 
mount_accessor=auth_userpass_a09e8295

# Using the userpass logins we created, we’re going to perform a set of actions. With each login, we'll receive a token value. In order to identify which user is performing the action, an environment variable will be set to the value and passed at runtime to the vault binary. 

# For simplicity, the actual tokens will be replaced with user-1-aaaa-bbbb and user-2-cccc-dddd in the commands below.. These strings should be replaced with the actual tokens generated in the system.

vault login -method=userpass username=user1
# <enter password>
# … 
# Key          Value
# ---          -----
# token        s.6LJu17AH0fecMQPERRBD4pqf
# ...

# Create a secret using the token associated with the user1 policy:

VAULT_TOKEN="user-1-aaaa-bbbb" vault kv put kv/user1 "password=secret"
# Success! Data written to: secret/user1

# Alternatively via the API:
curl -vv \
  "${VAULT_ADDR}/v1/kv/user1" -H 'Content-Type: application/json' \
  -H "X-Vault-Token: ${VAULT_TOKEN}" --data-binary '{"password":"secret"}'


# Retrieve the secret using the token associated with the user1 policy:

VAULT_TOKEN="user1-aaaa-bbbb" vault read kv/user1
# ==========Data==========
# Key     	      Value
# ---     	      -----
# Refresh_interval   768h
# password	      secret

# Alternatively via the API:
curl -vv \
  "${VAULT_ADDR}/v1/kv/user1" -H "X-Vault-Token: ${VAULT_TOKEN}"


# Update the secret using the token associated with the user1 policy:

VAULT_TOKEN="user1-aaaa-bbbb" vault kv put kv/user1 "password=verysecure"
# Success! Data written to: secret/user1

# Alternatively via the API:
curl -vv \
  "${VAULT_ADDR}/v1/secret/user1" -H 'Content-Type: application/json' \
  -H "X-Vault-Token: ${VAULT_TOKEN}" --data-binary '{"password":"verysecure"}'


# Retrieve the secret using the token associated with the user1 policy:

VAULT_TOKEN="user1-aaaa-bbbb" vault read kv/user1
# ==========Data==========
# Key     	      Value
# ---     	      -----
# Refresh_interval   768h
# password	verysecure

# Login as user2 and attempt to retrieve the secret using the token associated to the user2 policy:

VAULT_TOKEN="user2-cccc-dddd" vault read kv/user1
# Error reading secret/user1: Error making API request.

# URL: GET https://127.0.0.1:8200/v1/kv/user1
# Code: 403. Errors:

# * permission denied

# Delete the secret via the API:
curl -vv -X DELETE \
"${VAULT_ADDR}/v1/kv/user1" -H "X-Vault-Token: ${VAULT_TOKEN}"

# With the usage of policies, access to secrets can be restricted.
# Policies use path based matching to apply rules. A policy may be an exact match, or might be a glob pattern which uses a prefix. Vault operates in a whitelisting mode, so if a path isn't explicitly allowed, Vault will reject access to it. This works well due to Vault's architecture of being like a filesystem: everything has a path associated with it, including the core configuration mechanism under "sys".