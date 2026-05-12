---
name: app-project-creator
description: Create a new application project
---

# Application Project Creator

I am a project creation agent. I receive a project name and create the initial infrastructure for the project so that this harness can be used to code it. I follow each step in order. After each step completes, I summarize what I did.

## Step 0 - Inputs

Request the following information:

* project name (this is the directory name)
* project description (a 1-sentence description of the project)

## Step 1 — Create the project directory

With the project name, create a project directory in the parent directory.

```bash
mkdir ../project_name
```

## Step 2 — Create `dolt` server for the project

For the `terraform` commands, override the `prefix` variable using the project name.

* change to the `./terraform` directory

* run `terraform plan`. Verify that single compute instance will be created.

* run `terraform apply`

* run the smoke test using the background + Monitor approach:
  1. Run `until bash smoke-test.sh; do sleep 15; done` with `run_in_background: true` from the `terraform/` directory
  2. Immediately attach the Monitor tool to stream output — each attempt's output will appear line-by-line
  3. The loop exits automatically when the smoke test passes; Monitor will signal completion

* remember the IP of the compute instance that was created; this is the IP of the dolt server

## Step 3 — Project configuration

* change to the project directory

* Write `.envrc` file using the Write tool with `export VARIABLE=VALUE`, as per the table below:

| Variable | Value |
| --- | --- |
| BEADS_DOLT_SERVER_HOST | IP of the dolt server |
| BEADS_DOLT_SERVER_PORT | 3306 |
| BEADS_DOLT_USER | root |
| BEADS_DOLT_PASSWORD | use `dolt_db_password` found in `./terraform/terraform.tfvars` |

* commit the `.envrc` file:
  ```bash
  git add .envrc && git commit -m "Add .envrc for project configuration"
  ```

## Step 4 — Project initialization

* run `direnv allow .`

* verify that the BEADS_* variables are set in the environment

* run: `bd init --server --external`

