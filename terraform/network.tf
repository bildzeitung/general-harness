# OCI VCN and networking resources for the dolt server instance.
# All display_name values are prefixed with var.prefix for easy identification.

# -------------------------------------------------------------------
# VCN
# dns_label is required for hostname resolution inside the VCN.
# -------------------------------------------------------------------
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "${var.prefix}-vcn"
  dns_label      = "${var.prefix}vcn"
}

# -------------------------------------------------------------------
# Internet Gateway — provides outbound/inbound internet connectivity.
# -------------------------------------------------------------------
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.prefix}-igw"
  enabled        = true
}

# -------------------------------------------------------------------
# Route Table — default route via internet gateway.
# -------------------------------------------------------------------
resource "oci_core_route_table" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.prefix}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

# -------------------------------------------------------------------
# Security List — stateful; permits SSH and dolt ingress, all egress.
# Port 3306 source is controlled by var.dolt_ingress_cidr (default
# 0.0.0.0/0). Restrict it to a specific IP/CIDR in terraform.tfvars
# to limit internet exposure of the dolt MySQL-protocol port.
# -------------------------------------------------------------------
resource "oci_core_security_list" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.prefix}-sl"

  # --- Ingress rules ---

  # SSH
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Dolt server (MySQL-compatible protocol)
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = var.dolt_ingress_cidr
    stateless = false

    tcp_options {
      min = 3306
      max = 3306
    }
  }

  # --- Egress rules ---

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

# -------------------------------------------------------------------
# Public Subnet — instances here receive public IPs automatically.
# dns_label is required; the VCN dns_label above is a prerequisite.
# DHCP options default to VCN-level defaults (acceptable).
# -------------------------------------------------------------------
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "${var.prefix}-subnet"
  dns_label                  = "${var.prefix}subnet"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.main.id
  security_list_ids          = [oci_core_security_list.main.id]
}
