output "endpoints" {
  value = <<EOF

  NOTE: While Terraform's work is done, these instances need time to complete
        their own installation and configuration. Progress is reported within
        the log file `/var/log/tf-user-data.log` and reports 'Complete' when
        the instance is ready.

  vault_1 (${aws_instance.vault-server[0].public_ip}) | internal: (${aws_instance.vault-server[0].private_ip})
    - Leader of HA cluster

    $ ssh -l ubuntu ${aws_instance.vault-server[0].public_ip} -i ${var.key_name}.pem

  vault_2 (${aws_instance.vault-server[1].public_ip}) | internal: (${aws_instance.vault-server[1].private_ip})
    - Started
    - You will join it to cluster started by vault_1

    $ ssh -l ubuntu ${aws_instance.vault-server[1].public_ip} -i ${var.key_name}.pem

  vault_3 (${aws_instance.vault-server[2].public_ip}) | internal: (${aws_instance.vault-server[2].private_ip})
    - Started
    - You will join it to cluster started by vault_1

    $ ssh -l ubuntu ${aws_instance.vault-server[2].public_ip} -i ${var.key_name}.pem

  vault_1_DR (${aws_instance.vault-server[3].public_ip}) | internal: (${aws_instance.vault-server[3].private_ip})
    - Leader of DR HA cluster

    $ ssh -l ubuntu ${aws_instance.vault-server[3].public_ip} -i ${var.key_name}.pem

  vault_2_DR (${aws_instance.vault-server[1].public_ip}) | internal: (${aws_instance.vault-server[4].private_ip})
    - Started
    - You will join it to cluster started by vault_1_DR

    $ ssh -l ubuntu ${aws_instance.vault-server[1].public_ip} -i ${var.key_name}.pem

  vault_3_DR (${aws_instance.vault-server[2].public_ip}) | internal: (${aws_instance.vault-server[5].private_ip})
    - Started
    - You will join it to cluster started by vault_1_DR

    $ ssh -l ubuntu ${aws_instance.vault-server[2].public_ip} -i ${var.key_name}.pem    

EOF
}
