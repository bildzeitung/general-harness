# JFDI Logging

## Goal

This epic implements logging for the JFDI application and across all operations.

Each data manipulation step must be logged, from opening the file to emitting the
target file. 

Log messages must not contain PHI or PII. All data files contain this, so log
messages must be informative, but not violate privacy and data protection laws.

This epic introduces new elements to the operation contract.

Log messages are logged to a file, but those message must be machine-parsable.

## Research

- determine if Python logging module is the correct choice or whether a 3rd
  party library would be more appropriate

## Contract

- if a data element is changed, a WARN level message is logged
- if an operation cannot complete, an ERROR level message is logged
- if the operation completes, a DEBUG level message is logged

## Design

- A CLI option for setting DEBUG-level logging
- A CLI option for specifying the log file name (with a sensible default)

## Constraints

- log messages are in JSON format

## Dependencies

- Pipeline epic is complete

## Done criteria

- application passes unit tests 
- application can be invoked with --debug
- application sucessfully logs WARN and ERROR messages

