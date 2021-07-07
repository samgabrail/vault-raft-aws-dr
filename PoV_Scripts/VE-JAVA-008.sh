# Description
# Consume secrets programmatically using Spring Vault.  An introduction to Spring Cloud Vault can be found at https://cloud.spring.io/spring-cloud-vault/reference/html/.

# A public docker image has been prepared for use here with source code bundled into it at https://hub.docker.com/repository/docker/hashidstover/pov-vault-spring.

# Setup
# The Spring Boot integration will utilize a simple example of injecting an existing secret from Vault into an application during startup along with writing new secrets to Vault through a Spring REST Controller.

# Configure the KV secrets engine in Vault:
vault secrets enable -path=pov-vault-spring kv-v2
# Success! Enabled the kv-v2 secrets engine at: pov-vault-spring/

# Add a secret to the KV secrets engine:
vault kv put pov-vault-spring/demo inject="foo"
# Key              Value
# ---              -----
# created_time     2020-12-31T18:39:21.685107Z
# deletion_time    n/a
# destroyed        false
# version          1

# Create a local policy file named "spring.hcl" for the Spring application that will be imported in Vault. Add the following to it and save the file:
# Enable and manage the kv secrets engine
# path "pov-vault-spring/*" {
#   capabilities = ["create", "read", "update", "delete", "list"]
# }

# Add this policy to Vault:
vault policy write spring policies/spring.hcl
# Success! Uploaded policy: spring

# Create a new Vault token for the Spring application associated with this policy and export the token to an environment variable:
export SPRING_TOKEN=$(vault token create -format=json -policy="spring" | jq -r ".auth.client_token")
echo $SPRING_TOKEN
# s.PiZl5PouwiXdfCihcFYPradt

# The Spring container can use an external VAULT (define an env variable) or a Vault running on localhost. You could run a reverse SSH tunnel to expose a remote Vault locally with the following command:
# ssh -L 8200:localhost:8200 <vault_public_ip>
# You could also use the hostname/IP of the vault node and run docker on the vault node. Make sure you use the correct IP which would be the local IP as used in the vault config file. You may have authn problems using 127.0.0.1.
# Stand up the Spring container:
docker run -d -p 8090:8090 -t \
    --env VAULT_TOKEN=${SPRING_TOKEN} --name pov-vault-spring \
    --env VAULT_HOST="host.docker.internal" \
    hashidstover/pov-vault-spring:latest
# 7dfaa48ae566b491950914c2f992dad8321b8588453ae1852d5bd282cfc7fae6
 
# Follow the Spring logs in a separate terminal and note that the injected secret created above and the Spring Vault token are logged on startup:
docker logs -f pov-vault-spring
# ...
# ----------------------------------------
# Properties
#       Vault token is s.PiZl5PouwiXdfCihcFYPradt
#       Vault injected value is foo
# ----------------------------------------
# ...

# Read the injected secret through a Spring endpoint:
curl --request GET --write-out "\n" http://localhost:8090/secret
# [{"key":"inject","value":"foo"}]

# Validate that nothing exists at the following endpoint in Vault:
vault kv get pov-vault-spring/demo/credential
# No value found at pov-vault-spring/data/demo/credential

# Add a couple of secrets through a Spring endpoint:
curl --header "Content-Type: application/json" --request POST \
       --data '{"username":"xyz","password":"zyx"}' --write-out "\n" \
       http://localhost:8090/secret
# {"username":"xyz","password":"zyx"}

# From any host, ensure that the proper environment variables are set to interact with Vault from the command line including ${VAULT_TOKEN} and ${VAULT_ADDR}.

# Query Vault to validate the new secrets have been added through the Spring endpoint:
vault kv get pov-vault-spring/demo/credential

# Expected Results

# ====== Metadata ======
# Key              Value
# ---              -----
# created_time     2020-12-31T19:14:20.3623568Z
# deletion_time    n/a
# destroyed        false
# version          2

# ====== Data ======
# Key         Value
# ---         -----
# password    zyx
# username    xyz


# Note:
# The following commands will retrieve the source code for the example application covered in this document if you are looking for a deeper look into the Spring code:
# $ mkdir temp && cd temp
# $ docker cp pov-vault-spring:pov-vault-spring.jar .
# $ mkdir pov-vault-spring && tar -xf pov-vault-spring.jar -C pov-vault-spring
# $ cd pov-vault-spring/BOOT-INF/classes/source/
