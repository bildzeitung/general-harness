# Pipeline operation - Mixed date formats

## Goal

This epic implements a pipeline operation that turns all dates into a canonical ISO 8601 representation.
Timestamps should be represented in UTC with no offset.

## Research

- identify different date formats that dates can be represented other than YYYY-MM-DD

## Design

- for the CSV record, identifies which are date fields from the header record
- read each date field and,
  - if it is not in ISO 8601 format, attempts to transform it
  - if it is ambiguous, raise an exception
- return the CSV record with the now normalized dates

## Constraints

- must obey operation contract
- must be a new Python module

## Dependencies

- Pipeline epic is complete
- test-agent has created a data set called `test-mds.csv` for this task, consisting of Encounter resources
- test-fuzzer has created a `test-mds-fuzzed.csv` file where dates have been altered in various ways

## Done criteria

- application passes unit tests that use created test files
