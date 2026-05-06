# Harness Code Review Agent

## Goal

Create cloud infrastructure as code (Terraform) to stand up an instance that runs **dolt** server.

## Design

- Terraform should stand up VCN, instance, and port access for SSH and the dolt server
- An SSH key must be created and used in instance creation so that SSH access is available
- Terraform can save state locally
- instance readiness includes dolt server installation and validation that it is running

## Constraints

- uses Oracle Cloud Infrastructure terraform provider
- uses local OCI account and tenancy
- uses only free resource types (that is, free instance shapes only)

