# Development Harness

This repo contains a Claude-based application development harness.

## Setup

Make sure you have installed:

* [Claude CLI](https://code.claude.com/docs/en/overview): our AI _de jour_
* [beads](https://github.com/gastownhall/beads): for agent memory and tickets
* [dolt](https://docs.dolthub.com/introduction/installation)
* [gh](https://cli.github.com/): github CLI tool
* [direnv](https://direnv.net/): access to beads server
* [terraform](https://developer.hashicorp.com/terraform/install): stand up beads server

## Creating the application


## Harness Workflow for App Feature Development

1. Author a feature description, in Markdown, in `epics/`
2. Run `add-epic-from-dir.sh`, with a title and path to feature description file
3. In a Claude session, run the planner agent
4. When the ticket breakdown is satisfactory, run the controller agent; iterate with the planner as needed
