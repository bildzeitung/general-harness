# Outputs populated across bx4.2–bx4.5.

# bx4.2: SSH public key — consumed by the compute instance resource in bx4.5.
# Referenced as: output.ssh_public_key
output "ssh_public_key" {
  description = "OpenSSH public key for the generated instance key pair."
  value       = tls_private_key.instance.public_key_openssh
}

# bx4.5: Instance public IP.
output "instance_public_ip" {
  description = "Public IP address assigned to the dolt server instance."
  value       = oci_core_instance.dolt.public_ip
}

# bx4.5: Convenience SSH command.
# abspath() ensures the path to oci_instance.pem is correct regardless of
# the directory from which the command is run.
output "ssh_command" {
  description = "SSH command to connect to the dolt server instance."
  value       = "ssh -i ${abspath("${path.module}/oci_instance.pem")} opc@${oci_core_instance.dolt.public_ip}"
}
