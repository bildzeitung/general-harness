variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy."
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user used for API authentication."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the OCI API signing key."
  type        = string
}

variable "private_key_path" {
  description = "Path on disk to the OCI API signing key PEM file."
  type        = string
}

variable "region" {
  description = "OCI region identifier (e.g. \"us-ashburn-1\")."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the OCI compartment in which resources will be created."
  type        = string
}

variable "availability_domain" {
  description = <<-EOT
    OCI availability domain name (e.g. "ABC:US-ASHBURN-AD-1").
    Find yours with:
      oci iam availability-domain list --tenancy-id <tenancy_ocid>
  EOT
  type        = string
}

variable "prefix" {
  description = "Short prefix applied to all resource names (e.g. \"dolt\")."
  type        = string
  default     = "dolt"
}

variable "dolt_db_password" {
  description = "Password for the dolt root SQL user."
  type        = string
  sensitive   = true
}

variable "dolt_ingress_cidr" {
  description = <<-EOT
    CIDR block allowed to reach the dolt server on port 3306.
    Defaults to 0.0.0.0/0 (open to the internet). Restrict to your
    public IP or office CIDR to harden the deployment, e.g. "203.0.113.5/32".
  EOT
  type        = string
  default     = "0.0.0.0/0"
}
