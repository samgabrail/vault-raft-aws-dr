# Description
# Use namespaces to create isolated environments within a multi-tenant Vault install. Relevant Vault documentation can be found at the following sites:

# https://www.vaultproject.io/guides/operations/multi-tenant.html 

# This demonstration shows how nested namespaces share visibility of authentication.  Parent entities can view child namespaces but not vice-versa.

# Create namespaces

# To create a new namespace, run: vault namespace create <namespace_name>
# Create a namespace dedicated to the education organizations.

vault namespace create education

# Create child namespaces called training under the education namespace.

vault namespace create -namespace=education training

# Create child namespaces called certification under the education namespace.

vault namespace create -namespace=education certification

# List the existing namespaces on the root.

vault namespace list
# education/

# List the existing namespace on the education namespace.

vault namespace list -namespace=education
# certification/
# training/

# Write policies
# In this scenario, there is an organization-level administrator who is a superuser within the scope of the education namespace. Also, there is a team-level administrator for training and certification.

# Policy for education admin: policies/edu-admin.hcl
# Policy for training admin: policies/training-admin.hcl

vault policy write -namespace=education edu-admin edu-admin.hcl
vault policy write -namespace=education/training training-admin \
      training-admin.hcl

# Setup entities and groups
# In the education namespace, create an entity, Bob Smith with edu-admin policy attached. Add a userpass user, bob as an entity alias. By default, Bob Smith has no visibility into the education/training namespace since the bob user was defined in the education namespace.

# You are going to create an internal group named, Training Admin in the education/training namespace with training-admin policy attached. To grant the training-admin policy for bob, add the Bob Smith entity to the Training Admin group as a member entity.

# Enable the userpass auth method.
vault auth enable -namespace=education userpass

# Create a user bob under the education namespace.
vault write -namespace=education \
        auth/userpass/users/bob password="training"

# Create an entity for Bob Smith with edu-admin policy attached. Save the generated entity ID in a file named entity_id.txt.
vault write -namespace=education -format=json identity/entity name="Bob Smith" \
        policies="edu-admin" | jq -r ".data.id" > entity_id.txt

# Get the mount accessor for userpass auth method and save it in accessor.txt.
vault auth list -namespace=education -format=json \
        | jq -r '.["userpass/"].accessor' > accessor.txt

# Create an entity alias for Bob Smith to attach bob.
vault write -namespace=education identity/entity-alias name="bob" \
        canonical_id=$(cat entity_id.txt) mount_accessor=$(cat accessor.txt)

# Create a group, "Training Admin" in education/training namespace with Bob Smith entity as its member.
vault write -namespace=education/training identity/group \
        name="Training Admin" policies="training-admin" \
        member_entity_ids=$(cat entity_id.txt)

# Test the Bob Smith entity
# Log in as bob into the education namespace.
vault login -namespace=education -method=userpass \
        username="bob" password="training"

# Key                    Value
# ---                    -----
# token                  s.zLNbFJQFWaMR7R5tgobn6xHg.1Vi61
# token_accessor         xcCNEsRStvQcPEp4AKrkWikk.1Vi61
# token_duration         768h
# token_renewable        true
# token_policies         ["default"]
# identity_policies      ["edu-admin"]
# policies               ["default" "edu-admin"]
# token_meta_username    bob

# Notice that the generated token contains the namespace ID which was created in (e.g. s.zLNbFJQFWaMR7R5tgobn6xHg.1Vi61). User bob only has default policy attached to his token (token_policies); however, he inherited the edu-admin policy from the Bob Smith entity (identity_policies).

# Test to make sure that bob can create a namespace, enable secrets engine, and whatever else that you want to verify against the education namespace.

export VAULT_NAMESPACE="education"

# Verify that you can create a new namespace called web-app.

vault namespace create web-app
# Success! Namespace created at: education/web-app/

# Verify that you can enable key/value v2 secrets engine at edu-secret.

vault secrets enable -path=edu-secret kv-v2
# Success! Enabled the kv-v2 secrets engine at: edu-secret/

# Optionally, you can create new policies to test that bob can perform the operations as expected. When you are done testing, unset the VAULT_NAMESPACE environment variable.

unset VAULT_NAMESPACE

# Test the training admin group
# Stay logged in as bob and look up the token details.

vault token lookup

# Key                            Value
# ---                            -----
#   # ...snip...
# external_namespace_policies    map[ygcTv:[training-admin]]
# id                             s.zLNbFJQFWaMR7R5tgobn6xHg.1Vi61
# identity_policies              [edu-admin]
# issue_time                     2019-09-26T16:29:33.960232-07:00
# meta                           map[username:bob]
# namespace_path                 education/
# num_uses                       0
# orphan                         true
# path                           auth/userpass/login/bob
# policies                       [default]
# renewable                      true
# ttl                            767h53m55s
# type                           service

# Notice that the external_namespace_policies parameter lists training-admin policy. The user bob inherited this policy from the Training Admin group defined in the education/training namespace although bob user was created in the education namespace.

# Verify that bob can perform the operations permitted by the training-admin policy.

# Set the target namespace as an env variable.
export VAULT_NAMESPACE="education/training"

# Create a new namespace called vault-training.
vault namespace create vault-training

# Key     Value
# ---     -----
# id      nQjeG
# path    education/training/vault-training/

# Enable key/value v1 secrets engine at team-secret.
vault secrets enable -path=team-secret -version=1 kv
# Success! Enabled the kv secrets engine at: team-secret/

# When you are done testing, unset the VAULT_NAMESPACE environment variable.

unset VAULT_NAMESPACE

# Summary:
# As this tutorial demonstrated, each namespace you created behaves as an isolated Vault environment. By default, there is no visibility into other namespaces regardless of its hierarchical relationship. In order for Bob to operate in education/training namespace, you can enable an auth method in the education/training namespace so that he can log in. Or, as demonstrated in this tutorial, you can use Vault identity to associate entities and groups defined in different namespaces.

# NOTE: Bob still needs to log into the education namespace since his token is tied to the education namespace and it is invalid to log into the education/training namespace.