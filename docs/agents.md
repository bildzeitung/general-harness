# Agent Workflow

## Diagram

```
                                      ┌─────────────┐
                                      │  controller │
                                      └──────┬──────┘
          ┌──────────┬─────────────┬──────────┼──────────┬──────────┬────────────┬───────────┐
    epic/      P0/P1 bug      bug P2-P4    test data   medplum    python       review       docs
 needs-plan  needs-plan bug   / task        task        task      project       task         task
          │          │             │             │          │          │          │             │
          ▼          ▼             │             ▼          ▼          ▼          ▼             ▼
     ┌─────────┐ ┌──────────┐     │        ┌─────────┐ ┌───────┐ ┌────────┐ ┌────────┐ ┌──────────┐
     │ planner │ │ debater  │     │        │ synthea │ │medplum│ │python- │ │  code  │ │document- │
     └────┬────┘ │(bug      │     │        │  agent  │ │ agent │ │creator │ │ review │ │   er     │
          │      │ triage)  │     │        └─────────┘ └───────┘ └────────┘ └────────┘ └──────────┘
    first │      └────┬─────┘     │
    pass  │           │           │
          ▼           │           ▼
     ┌─────────┐      └──────►┌─────────────┐◄─ - - - - - - ┐
     │ debater │             │coding-agent │        subtasks via bd ready
     │  (epic  │             └──────┬──────┘   (from planner revision pass)
     │ review) │                    │
     └────┬────┘             ┌──────▼──────┐
          │                  │testing-agent│
    criticisms                └──────┬──────┘
          │                  pass ───┤ fail ──► (new coding task)
          ▼                          ▼
     ┌─────────┐             ┌──────────────┐
     │ planner │             │ merge-agent  │
     │(revision│             └──────┬───────┘
     │  pass)  │                    │
     └─────────┘                    ▼
                                 ✓ done
```

## Agents

| Agent | Description |
|-------|-------------|
| **controller** | Orchestrator that checks the Beads Issue Tracker for ready work and dispatches the appropriate subagent. Use this as the entry point for automated work sessions. |
| **planner** | Decomposes epic or needs-planning tasks into a dependency tree of concrete leaf tasks that coding-agent can implement. Use for epic type issues or issues labelled needs-planning. |
| **debater** | Stress-tests planned tickets after the planner runs, and triages high-priority bugs before the coding-agent implements them. Finds ambiguities, hidden assumptions, and risky fix approaches. Runs once per cycle — never re-invokes itself. |
| **coding-agent** | Expert software developer that implements coding tasks in isolated git worktrees and hands off to testing-agent. Use for any implementation task that touches the application repo. |
| **testing-agent** | Runs quality gates (lint and tests) on a completed worktree branch before integration. Receives handoff from coding-agent, creates a merge-agent task on pass, or flags for human review on fail. Use when a task title starts with 'Test ' and the description contains 'Worktree path:'. |
| **merge-agent** | Integrates completed worktree branches into the application repo's main branch and cleans up. Use when a coding-agent has finished a task and created a merge beads issue. |
| **code-review-agent** | Reviews recently merged code in the app repo against coding guidelines and files bd tickets for any issues found. Does NOT modify code. Use when a task title contains "Review" and type is task. |
| **synthea-agent** | Generates synthetic patient data using Synthea (via Docker), producing CSV files as the primary output. Use when a task requires generating test patient records for integration tests or pipeline validation. |
| **medplum-agent** | Provisions and starts a local Medplum FHIR server via Docker Compose for use as the FHIR backend during integration testing. Handles startup, health-check verification, connection details, and teardown. Invoked by the controller or the testing-agent. |
| **python-project-creator** | Creates a bare Python project scaffold with pyproject.toml, nox, ruff, ty, and Typer. Use when a task involves creating or initializing a new Python project. |
| **documenter** | Updates the ./docs folder to reflect the current state of the harness — agent roster, workflow diagram, and any other documentation. Use when the agent pipeline changes or documentation is explicitly requested. |
