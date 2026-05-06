terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }

    # tls: used to generate the SSH key pair for instance access.
    # IMPORTANT: terraform.tfstate will contain the private key in plaintext.
    # After every `terraform apply`, run: chmod 600 terraform/terraform.tfstate
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    # local: used to write the generated key files to disk.
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  # Backend is local (default); no remote state configuration.
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
