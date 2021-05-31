# Description
# Force an automatic failover to a standby node
# Setup A number of Vault nodes should be configured with RAFT for integrated storage
# Hands On
# https://learn.hashicorp.com/tutorials/vault/raft-storage?in=vault/raft

# The vault status command in the active node should return an output similar to the one below:
vault status
# Sealed: false
# Key Shares: 5
# Key Threshold: 3
# Unseal Progress: 0
# Unseal Nonce:
# Version: 0.7.3
# Cluster Name: vault-cluster-71598649
# Cluster ID: e4830363-52d9-78ab-623b-dfa41cadb1ca

# High-Availability Enabled: true
# 	Mode: active
# 	Leader: https://192.168.0.244:8200

# The vault status command in the standby node should return an output similar to the one below:

vault status

# Sealed: false
# Key Shares: 5
# Key Threshold: 3
# Unseal Progress: 0
# Unseal Nonce:
# Version: 0.7.3
# Cluster Name: vault-cluster-71598649
# Cluster ID: e4830363-52d9-78ab-623b-dfa41cadb1ca

# High-Availability Enabled: true
# 	Mode: standby
# 	Leader: https://192.168.0.244:8200

# The cluster name between the nodes should match.
# Next, simulate a failure in the active node (through shutting down the node, or stopping the service)

sudo systemctl stop vault

# The vault status command in one of the standby nodes should return an output similar to the one below:

vault status

# Sealed: false
# Key Shares: 5
# Key Threshold: 3
# Unseal Progress: 0
# Unseal Nonce:
# Version: 0.7.3
# Cluster Name: vault-cluster-71598649
# Cluster ID: e4830363-52d9-78ab-623b-dfa41cadb1ca

# High-Availability Enabled: true
# 	Mode: active
# 	Leader: https://192.168.0.245:8200

# The leader URL should match the IP Address of the former standby host, now promoted to active.




