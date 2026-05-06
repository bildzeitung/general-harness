# JFDI Pipeline support

## Goal

- application supports a series of operations between the CSV load and FHIR output
- these operations form a data validation and enrichment pipeline
- the set of operations should be configurable, both in terms of which operations are applied and their order
- each operation is in its own Python module, but has the same contract (see below)

## Operation contract

- an operation accepts a CSV header record
- an operation accepts a single CSV record
- an operation returns a single CSV record
- an operation throws an exception if it fails

## Constraints

- operations have a unique name
- on startup, the app examines itself and determines all available operations a user may access

## Done criteria

- the --help flag lists the available operations
- there is a way to specify on the CLI what operations run, and in what order
- there should be a CLI option to specify a configuration file
- the CLI option to specify a configuration file should have a default option
- there should be a documented procedure on how to add new operations
