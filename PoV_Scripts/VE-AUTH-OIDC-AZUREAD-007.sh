# Description
# Use Vault Enterprise OIDC authentication method with Azure AD to authenticate a user to Vault and retrieve a secret. Relevant Vault documentation can be found at the following website: https://www.vaultproject.io/docs/auth/jwt.html
# Setup
# Within Azure administration: 
# Register or select an AAD application. Visit Overview page.
# Configure Redirect URIs ("Web" type).
# Record "Application (client) ID".
# Under "Endpoints", copy the OpenID Connect metadata document URL, omitting the /well-known... portion.
# Switch to Certificates & Secrets. Create a new client secret and record the generated value as it will not be accessible after you leave the page.
# Enable the OIDC auth method
vault auth enable oidc

# Configure the OIDC method
vault write auth/oidc/config oidc_discovery_url="https://login.microsoftonline.com/{tenant}/v2.0/" oidc_client_id="CLIENT-ID" oidc_client_secret="CLIENT-SECRET" default_role="demo"

# Create a role in the method
vault write auth/oidc/role/demo bound_audiences="CLIENT-ID" allowed_redirect_uris="https://VAULT_ADDR:8200/ui/vault/auth/oidc/oidc/callback" allowed_redirect_uris="http://localhost:8250/oidc/callback" user_claim="sub" policies="oidcdemo"

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



