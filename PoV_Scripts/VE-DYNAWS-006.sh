# Description
# Use Vault Enterprise’s AWS secrets engine to issue dynamic AWS credentials.
# Setup
# You'll need valid AWS credentials with enough privilege to generate other IAM credentials.

# Enable the AWS secrets engine:
vault secrets enable aws

# Configure the credentials that Vault uses to communicate with AWS to generate the IAM credentials:
vault write aws/config/root \
    access_key=AKIAJWVN5Z4FOFT7NLNA \
    secret_key=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 \
    region=eu-west-1

# Configure a role that maps a name in Vault to a policy or policy file in AWS. When users generate credentials, they are generated against this role:

vault write aws/roles/my-role \
    policy=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOF

# Generate a new credential by reading from the /creds endpoint with the name of the role:
vault read aws/creds/my-role

# Expected Results
# AWS IAM credentials successfully generated and issued by Vault Enterprise with an output similar to the one below.

# Key                Value
# ---                -----
# lease_id           aws/creds/my-role/f3e92392-7d9c-09c8-c921-575d62fe80d8
# lease_duration     768h
# lease_renewable    true
# access_key         AKIAIOWQXTLW36DV7IEA
# secret_key         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
# security_token     <nil>
