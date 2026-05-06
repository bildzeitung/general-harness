#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: $0 <title> <filename>" >&2
    exit 1
}

[[ $# -ne 2 ]] && usage

title="$1"
file="$2"

[[ ! -f "$file" ]] && { echo "Error: file not found: $file" >&2; exit 1; }

bd create \
    --title="$title" \
    --type=epic \
    --priority=1 \
    --body-file="$file"
