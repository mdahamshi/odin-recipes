#!/bin/bash

# Usage check
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <template_file> <list_file> [--force]"
  exit 1
fi

template="$1"
filelist="$2"
force=0

# Check for --force flag
if [[ "$3" == "--force" ]]; then
  force=1
fi

# Check files exist
if [[ ! -f "$template" ]]; then
  echo "Template file '$template' not found!"
  exit 1
fi

if [[ ! -f "$filelist" ]]; then
  echo "List file '$filelist' not found!"
  exit 1
fi

while IFS= read -r name || [[ -n "$name" ]]; do
  # Skip empty lines
  [[ -z "$name" ]] && continue

  capitalized="$(tr '[:lower:]' '[:upper:]' <<< "${name:0:1}")${name:1}"
  output="${name}.html"

  if [[ -f "$output" && $force -eq 0 ]]; then
    echo "Skipping existing file '$output'. Use --force to overwrite."
    continue
  fi
  
  sed -e "s/{{tite}}/$capitalized/g" -e "s/{{head1}}/$capitalized/g" "$template" > "$output"
  echo "Generated '$output'"
done < "$filelist"
