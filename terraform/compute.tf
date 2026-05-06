# Compute resources for the dolt server instance.

locals {
  # Render the cloud-init template, substituting the dolt DB password.
  # The rendered YAML is base64-encoded and passed as user_data to the instance.
  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
    dolt_db_password = var.dolt_db_password
  })
}

# -------------------------------------------------------------------
# Data source — latest Oracle Linux 8 aarch64 platform image.
# Using sort_by = TIMECREATED + sort_order = DESC ensures images[0]
# is the most recently published image for the given shape/OS combo.
# -------------------------------------------------------------------
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# -------------------------------------------------------------------
# Compute instance — VM.Standard.A1.Flex (always-free ARM shape).
#
# Free-tier limits: 4 OCPUs and 24 GB RAM total across all A1
# instances in a tenancy. This instance uses 1 OCPU / 6 GB RAM.
#
# Capacity note: `terraform apply` may fail with:
#   "InternalError: Out of host capacity."
# This is an OCI supply constraint, not a Terraform bug. See the
# bx4.6 README for remediation steps (retry, different AD, etc.).
# -------------------------------------------------------------------
resource "oci_core_instance" "dolt" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = "${var.prefix}-dolt-server"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
    display_name     = "${var.prefix}-vnic"
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.instance.public_key_openssh
    user_data           = base64encode(local.user_data)
  }
}
