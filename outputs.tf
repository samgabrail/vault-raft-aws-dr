// output "endpoints" {
//   value = <<EOF

//       for instance in aws_instance.vault-server:
//         instance.name => "public: ${instance.public_ip} | private: ${instance.private_ip}"
//         "$ ssh -l ubuntu ${instance.public_ip} -i ${var.key_name}.pem"

 
// EOF
// }


output "endpoints" {
  value = {

      for instance in aws_instance.vault-server:
        instance.tags.instance_name => "public: ${instance.public_ip} | private: ${instance.private_ip} | ssh -l ubuntu ${instance.public_ip} -i ${var.key_name}.pem"
  }
 
}