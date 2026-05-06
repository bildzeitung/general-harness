# Terraform: OCI Dolt Server

Provisions a single `VM.Standard.A1.Flex` (ARM, always-free tier) instance on
Oracle Cloud Infrastructure running a [Dolt](https://github.com/dolthub/dolt)
SQL server, accessible over the MySQL protocol on port 3306.

---

## Prerequisites

| Tool | Minimum version | Notes |
|------|-----------------|-------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | 1.5 | `terraform -version` |
| [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) | any recent | needed to look up your availability domain |
| OpenSSH client | any | `ssh`, pre-installed on Linux/macOS |
| MySQL client | any | `mysql`, needed to run `smoke-test.sh` |

You also need:
- An Oracle Cloud (OCI) account with Always Free eligibility.
- An OCI API signing key pair (`~/.oci/oci_api_key.pem` or custom path).
  Generate one via the OCI Console under **User Settings > API Keys** and note
  its fingerprint.

---

## Find your availability domain

Each OCI region has one to three availability domains. You must pass the exact
name (including the opaque prefix that OCI assigns to your tenancy) as
`availability_domain` in `terraform.tfvars`.

```bash
oci iam availability-domain list --tenancy-id <tenancy_ocid>
```

The output looks like:

```json
{
  "data": [
    { "name": "ABC:US-ASHBURN-AD-1", ... },
    { "name": "ABC:US-ASHBURN-AD-2", ... },
    { "name": "ABC:US-ASHBURN-AD-3", ... }
  ]
}
```

Use one of the `"name"` values as `availability_domain`.

---

## Configure terraform.tfvars

Copy the example and fill in your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then edit `terraform.tfvars`:

```hcl
# OCI Authentication
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaNNNN..."
user_ocid        = "ocid1.user.oc1..aaaaaaaaNNNN..."
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"

# Compartment
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaaNNNN..."

# Availability domain (from the command above)
availability_domain = "ABC:US-ASHBURN-AD-1"

# Resource name prefix (optional, default: "dolt")
prefix = "dolt"

# Password for the dolt root SQL user
dolt_db_password = "a-strong-password-here"
```

> **Security:** `terraform.tfvars` and `terraform.tfstate` are git-ignored.
> Never commit them. See the [Secrets warning](#secrets-warning) below.

---

## Apply

```bash
cd terraform/

# Download providers (only needed once, or after provider version changes).
terraform init

# Preview what will be created.
terraform plan

# Provision the instance (~2-3 min for the API calls).
terraform apply
```

After apply, note the outputs:

```
instance_public_ip = "X.X.X.X"
ssh_command        = "ssh -i /path/to/oci_instance.pem opc@X.X.X.X"
ssh_public_key     = "ssh-rsa ..."
```

---

## Verify the dolt server

Cloud-init installs dolt and starts the service after first boot. This takes
roughly 2-5 minutes after the instance reaches `RUNNING` state. Use the smoke
test script to wait and verify automatically:

```bash
# Run from the terraform/ directory.
bash smoke-test.sh
```

The script performs three checks in sequence:

1. **cloud-init** — waits (up to 5 min) for first-boot provisioning to finish.
2. **dolt-server service** — asserts `systemctl is-active dolt-server` returns `active`.
3. **Auth rejection** — connects with no password and asserts the response
   contains `Access denied`, confirming authentication is enforced.

A passing run ends with `All checks passed.`

---

## Connect to the instance

### SSH

Use the `ssh_command` output directly:

```bash
$(terraform output -raw ssh_command)
# or equivalently:
ssh -i ./oci_instance.pem opc@<instance_public_ip>
```

### Dolt SQL (MySQL protocol)

```bash
# Interactive shell (you will be prompted for the password).
mysql -h <instance_public_ip> -P 3306 -u root -p

# Non-interactive (password from env var — avoids shell history exposure).
MYSQL_PWD=<dolt_db_password> mysql -h <instance_public_ip> -P 3306 -u root
```

---

## Out of host capacity

`terraform apply` may fail with:

```
Error: InternalError: Out of host capacity.
```

This is an OCI supply constraint on `VM.Standard.A1.Flex` in the chosen
availability domain — it is **not a Terraform bug**.

Remediation options (in order of least friction):

1. **Retry** — capacity on free-tier shapes is released unpredictably.
   Run `terraform apply` again every 5-15 minutes until it succeeds.

2. **Different availability domain** — change `availability_domain` in
   `terraform.tfvars` to another AD in the same region (e.g. `AD-2` instead
   of `AD-1`) and retry.

3. **Different region** — change both `region` and `availability_domain` to a
   less-congested OCI region (e.g. `ap-osaka-1`, `eu-frankfurt-1`) and retry.

> Do NOT switch to `VM.Standard.E2.1.Micro`. It is an x86 shape with only 1 GB
> RAM and is incompatible with this setup (the cloud-init script targets
> Oracle Linux 8 aarch64).

---

## Restricting port 3306 ingress

By default the security list allows **any host on the internet** to reach the
dolt MySQL-compatible port (3306). For a personal deployment this is
acceptable, but it exposes the password prompt to the entire internet.

To lock it down to your IP (or an office/VPN CIDR), add one line to
`terraform.tfvars`:

```hcl
# Replace with your actual public IP.  Find it with:
#   curl -s https://checkip.amazonaws.com
dolt_ingress_cidr = "203.0.113.5/32"
```

Then re-apply:

```bash
terraform apply
```

Terraform will update the security list in place — no instance rebuild
required.

> If your IP changes (DHCP, travel, etc.) update the value and run
> `terraform apply` again.  SSH (port 22) is intentionally left open to
> `0.0.0.0/0` so you can always reach the instance; tighten that rule the
> same way by editing the SSH ingress block in `network.tf` if needed.

---

## Secrets warning

The following files contain sensitive material. Keep permissions tight and
never commit them to version control.

| File | Contains | Required permissions |
|------|----------|---------------------|
| `terraform.tfstate` | SSH private key in plaintext | `chmod 600` |
| `terraform.tfstate.backup` | Same as above | `chmod 600` |
| `oci_instance.pem` | SSH private key | `chmod 600` (set automatically by Terraform) |
| `terraform.tfvars` | OCI credentials and dolt password | `chmod 600` |

After every `terraform apply`:

```bash
chmod 600 terraform.tfstate terraform.tfstate.backup 2>/dev/null || true
```

All four files are already listed in `.gitignore`.

---

## Destroy

To tear down all provisioned resources:

```bash
terraform destroy
```

This removes the compute instance, VCN, subnets, security list, internet
gateway, and route table. The locally generated key files (`oci_instance.pem`,
`oci_instance.pub`) are also removed by Terraform because they are managed
`local_file` / `local_sensitive_file` resources.

> The `tls_private_key.instance` resource has `prevent_destroy = true` to
> guard against accidental key regeneration while an instance is live. To
> allow destroy, temporarily remove the `lifecycle` block from `ssh.tf` or
> run `terraform state rm tls_private_key.instance` before destroying.
