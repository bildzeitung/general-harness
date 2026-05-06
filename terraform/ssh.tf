# SSH key pair generated entirely within Terraform — no external key material required.
#
# Security note: the private key is stored in plaintext inside terraform.tfstate.
# The .gitignore already excludes terraform.tfstate* from version control.
# After every `terraform apply`, run: chmod 600 terraform/terraform.tfstate

resource "tls_private_key" "instance" {
  algorithm = "RSA"
  rsa_bits  = 4096

  lifecycle {
    # Prevent accidental key regeneration after the instance has been provisioned.
    # Recreating this key would cause oci_instance.pem to diverge from the
    # instance's authorized_keys, permanently breaking SSH access.
    prevent_destroy = true
  }
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.instance.private_key_pem
  filename        = "${path.module}/oci_instance.pem"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content  = tls_private_key.instance.public_key_openssh
  filename = "${path.module}/oci_instance.pub"
}
