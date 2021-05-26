# Description
# Verify single Vault cluster installation, perform initialization, unseal, and apply license.
# Hands On
# https://www.vaultproject.io/intro/getting-started/deploy.html#initializing-the-vault

# This use case is to deploy a Vault server using the Integrated Storage option aka RAFT. Once deployed, initialized, unsealed, and licensed the server is ready for use.

# If setting up a Vault HA cluster and/or disaster replication or performance replication clusters, these steps will be repeated on additional Vault server nodes.

# Ensure you have received your PoV license file from your HashiCorp sales staff before proceeding. Once the Vault server is started, it will remain active for 6 hours and the license file needs to be added within this time window. If the time window expires without adding the license, it will be necessary to stop and restart the server and re-execute the subsequent commands.

# Run the following instructions for both the Primary and DR clusters (apply the same license to both)

# 1.  SSH into **vault_1**.

    
    ssh -l ubuntu <public_ip> -i <path/to/key.pem>
    
    # Initialize the Vault node and retain the unseal keys and the initial root token, these are incredibly important. For the purpose of the PoV, store this information together. In a real deployment, you would never save these keys together.
    
    vault operator init \
    -key-shares=1 \
    -key-threshold=1
    
    # Unseal the Vault. Repeat this step multiple times (3) using a different key each time until the sealed key value changes to false.
    
    vault operator unseal
     
    # Authenticate and login to Vault:

    vault login <ROOT TOKEN>
    
    # Login to the GUI using the <ROOT TOKEN>. Direct your browser to the public IP and port 8200 on one of your nodes running Vault Server to explore the UI.

    # Ensure you have a license file structured as JSON. The contents should appear as:
    # {
    #   "Text": "01ABCDEFG"
    # }

    # Apply the license with the command below or inside the GUI:
    curl --header "X-Vault-Token: <ROOT TOKEN>" \
    --request PUT \
    --data @<LICENSE FILE> \
    http://<VAULT DNS NAME OR IP ADDRESS>:8200/v1/sys/license

    # Get Vault status
    vault status
    
    # Output:

    # Key                     Value
    # ---                     -----
    # Seal Type               shamir
    # Initialized             true
    # Sealed                  false
    # Total Shares            5
    # Threshold               3
    # Version                 1.7.1+ent
    # Cluster Name            vault-cluster-9cc097d1
    # Cluster ID              2ff41eee-b1ae-efdc-b0e8-bde4b6734edc
    # HA Enabled              true
    # HA Cluster              https://127.0.0.1:8201
    # HA Mode                 active
    # Raft Committed Index    161
    # Raft Applied Index      161
    # Last WAL                20

# 2.  Check the current number of servers in the HA Cluster.

    
    vault operator raft list-peers

    # Output
    # Node       Address             State     Voter
    # ----       -------             -----     -----
    # vault_1    10.0.101.22:8201    leader    true
    

# 3.  Open a new terminal, SSH into **vault_2**.

    
    ssh -l ubuntu <public_ip> -i <path/to/key.pem>
    

# 4.  Join **vault_2** to the HA cluster started by **vault_1**.

    
    vault operator raft join http://vault_1:8200   #!!!!!!FOR DR: vault operator raft join http://vault_1_DR:8200
    
    # Unseal the Vault node
    
    vault operator unseal <use_the_unseal_keys_of_vault_1>
     
# 5.  Open a new terminal and SSH into **vault_3**

    
    ssh -l ubuntu <public_ip> -i <path/to/key.pem>
    

# 6.  Join **vault_3** to the HA cluster started by **vault_1**.

    
    vault operator raft join http://vault_1:8200   #!!!!!!FOR DR: vault operator raft join http://vault_1_DR:8200
    
    # Unseal the Vault node
    
    vault operator unseal <use_the_unseal_keys_of_vault_1>
     

# 7.  Return to the **vault_1** terminal and check the current number of servers in the HA Cluster.

    
    vault operator raft list-peers

    # Output:

    # Node       Address             State       Voter
    # ----       -------             -----       -----
    # vault_1    10.0.101.22:8201    leader      true
    # vault_2    10.0.101.23:8201    follower    true
    # vault_3    10.0.101.24:8201    follower    true
    

    # You should see **vault_1**, **vault_2**, and **vault_3** in the cluster.

# **NOTE:** Using the same root token, you can log into **vault_2** and **vault_3** as well.

