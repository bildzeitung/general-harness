# Harness-based project

## Pre-requisites

### On your machine

* [beads](https://gastownhall.github.io/beads/)
* [dolt](https://docs.dolthub.com/introduction/installation)
* [direnv](https://direnv.net/)
* [terraform](https://developer.hashicorp.com/terraform/install)

### Remotely

* terraform for Dolt server run; you have IP, port, user, and password for dolt

## Architecture

```text

App repo <--> Remote Hosted Beads Server
                        ^
                        |
Harness  <--------------+

```

## Creating a new product

* `mkdir product && cd product`

* Create `.envrc` file with `export VAR=VALUE`, as below:

| Variable | Value |
| --- | --- |
| BEADS_DOLT_SERVER_HOST | IP of server |
| BEADS_DOLT_SERVER_PORT | 3306 |
| BEADS_DOLT_USER | root |
| BEADS_DOLT_PASSWORD | **redacted** |

* `direnv allow .`

* Run: `bd init --server --external` Note that the ticket prefix is the product name.
