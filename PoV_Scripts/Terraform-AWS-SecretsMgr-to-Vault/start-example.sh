#!/usr/bin/bash
export VAULT_ADDR=https://
export VAULT_TOKEN=
export VAULT_CACERT="../../certs/ca.pem"
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=
terraform apply --auto-approve