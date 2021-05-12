# Create a Vault HA cluster on AWS using Terraform

These assets are provided to perform the tasks described in the [Vault HA Cluster with Integrated Storage on AWS](https://learn.hashicorp.com/vault/operations/raft-storage-aws) guide. However, for my purposes, I've removed the Vault node used for auto-unseal. We will use Shamir instead.

---

1.  Set your AWS credentials as environment variables:

    ```plaintext
    $ export AWS_ACCESS_KEY_ID = "<YOUR_AWS_ACCESS_KEY_ID>"
    $ export AWS_SECRET_ACCESS_KEY = "<YOUR_AWS_SECRET_ACCESS_KEY>"
    ```

1.  Use the provided `terraform.tfvars.example` as a base to create a file named
    `terraform.tfvars` and specify the `key_name`. Be sure to set the correct
    [key
    pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
    name created in the AWS region that you are using.

    Example `terrafrom.tfvars`:

    ```shell
    # SSH key name to access EC2 instances (should already exist) on the AWS region
    key_name = "vault-test"

    # If you want to use a different AWS region
    aws_region = "us-west-1"
    availability_zones = "us-west-1a"
    ```

1.  Run Terraform commands to provision your cloud resources:

    ```plaintext
    $ terraform init

    $ terraform plan

    $ terraform apply -auto-approve
    ```

    The Terraform output will display the IP addresses of the provisioned Vault nodes.

```plaintext
NOTE: While Terraform's work is done, these instances need time to complete
        their own installation and configuration. Progress is reported within
        the log file `/var/log/tf-user-data.log` and reports 'Complete' when
        the instance is ready.

  vault_1 (3.85.52.104) | internal: (10.0.101.22)
    - Leader of HA cluster

    $ ssh -l ubuntu 3.85.52.104 -i <path/to/key.pem>

  vault_2 (54.91.74.122) | internal: (10.0.101.23)
    - Started
    - You will join it to cluster started by vault_1

    $ ssh -l ubuntu 54.91.74.122 -i <path/to/key.pem>

  vault_3 (54.157.57.173) | internal: (10.0.101.24)
    - Started
    - You will join it to cluster started by vault_1

    $ ssh -l ubuntu 54.157.57.173 -i <path/to/key.pem>

  vault_1_DR (18.209.1.21) | internal: (10.0.101.25)
    - Leader of HA cluster

    $ ssh -l ubuntu 18.209.1.21 -i <path/to/key.pem>

  vault_2_DR (54.91.74.122) | internal: (10.0.101.26)
    - Started
    - You will join it to cluster started by vault_1

    $ ssh -l ubuntu 54.91.74.122 -i <path/to/key.pem>

  vault_3_DR (54.157.57.173) | internal: (10.0.101.27)
    - Started
    - You will join it to cluster started by vault_1

    $ ssh -l ubuntu 54.157.57.173 -i <path/to/key.pem>    
```

Run the following instructions for both the Primary and DR clusters

1.  SSH into **vault_1**.

    ```sh
    ssh -l ubuntu 13.56.255.200 -i <path/to/key.pem>
    ```
    Initialize the Vault node and save the unseal key and root token somewhere safe.
    ```sh
    vault operator init \
    -key-shares=1 \
    -key-threshold=1
    ```
    Unseal the Vault node
    ```sh
    vault operator unseal
    ``` 

2.  Check the current number of servers in the HA Cluster.

    ```plaintext
    $ VAULT_TOKEN=<root_token> vault operator raft list-peers
    Node       Address             State     Voter
    ----       -------             -----     -----
    vault_1    10.0.101.22:8201    leader    true
    ```

3.  Open a new terminal, SSH into **vault_2**.

    ```plaintext
    $ ssh -l ubuntu 54.183.62.59 -i <path/to/key.pem>
    ```

4.  Join **vault_2** to the HA cluster started by **vault_1**.

    ```plaintext
    $ vault operator raft join http://vault_1:8200
    ```
    Unseal the Vault node
    ```sh
    vault operator unseal <use_the_unseal_key_of_vault_1>
    ``` 
5.  Open a new terminal and SSH into **vault_3**

    ```plaintext
    $ ssh -l ubuntu 13.57.235.28 -i <path/to/key.pem>
    ```

6.  Join **vault_3** to the HA cluster started by **vault_1**.

    ```plaintext
    $ vault operator raft join http://vault_1:8200
    ```
    Unseal the Vault node
    ```sh
    vault operator unseal <use_the_unseal_key_of_vault_1>
    ``` 

7.  Return to the **vault_1** terminal and check the current number of servers in
    the HA Cluster.

    ```plaintext
    $ VAULT_TOKEN=<root_token> vault operator raft list-peers

    Node       Address             State       Voter
    ----       -------             -----       -----
    vault_1    10.0.101.22:8201    leader      true
    vault_2    10.0.101.23:8201    follower    true
    vault_3    10.0.101.24:8201    follower    true
    ```

    You should see **vault_1**, **vault_2**, and **vault_3** in the cluster.

**NOTE:** Using the same root token, you can log into **vault_2** and **vault_3** as well.

Refer to the [Vault HA Cluster with Integrated Storage](https://learn.hashicorp.com/vault/operations/raft-storage-aws) to learn more about [taking a snapshot](https://learn.hashicorp.com/vault/operations/raft-storage-aws#raft-snapshots-for-data-recovery) and [`retry_join` configuration](https://learn.hashicorp.com/vault/operations/raft-storage-aws#retry-join). 


# Clean up the cloud resources

When you are done exploring, execute the `terraform destroy` command to terminal all AWS elements:

```plaintext
$ terraform destroy -auto-approve
```
