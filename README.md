# Overview

This repo is used in PoVs. Terraform can be used to stand up 6 Vault nodes in AWS using integrated storage as the backend. The `PoV_Scripts` folder contains some common test cases. You can configure Vault to run TLS if you provide the certs and private key ahead of time and configure the Terraform template `userdata-vault-server.tpl` inside of the `Terraform -> templates` folder.