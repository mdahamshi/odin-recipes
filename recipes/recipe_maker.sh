#!/bin/bash

# Usage check
if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <template_file> <list_file> [--force]"
  exit 1
fi

template="$1"
list="$2"
force="$3"

# Validate template and list
if [[ ! -f "$template" ]]; then
  echo "Template file '$template' not found!"
  exit 1
fi

if [[ ! -f "$list" ]]; then
  echo "List file '$list' not found!"
  exit 1
fi

# Helper to convert semicolon-separated string to HTML list
to_html_list() {
  local input="$1"
  local tag="$2"
  local result="<${tag} class=\"sb-padding-20px\">"
  IFS=';' read -ra items <<< "$input"
  for item in "${items[@]}"; do
    item="$(echo "$item" | xargs)"  # trim
    [[ -n "$item" ]] && result+="<li>$item</li>"
  done
  result+="</${tag}>"
  echo "$result"
}

# Process each line
while IFS='|' read -r name description integration steps || [[ -n "$name" ]]; do
  [[ -z "$name" ]] && continue

  filename="${name}.html"
  if [[ -f "$filename" && "$force" != "--force" ]]; then
    echo "Skipping existing file: $filename (use --force to overwrite)"
    continue
  fi

  capitalized="$(tr '[:lower:]' '[:upper:]' <<< "${name:0:1}")${name:1}"
  image="${name}.webp"

  integration_html="$(to_html_list "$integration" "ul")"
  steps_html="$(to_html_list "$steps" "ol")"

  # Escape ampersands
  description="${description//&/\\&}"
  integration_html="${integration_html//&/\\&}"
  steps_html="${steps_html//&/\\&}"
  image="${image//&/\\&}"

  # Generate content
  output=$(<"$template")
  output="${output//\{\{title\}\}/$capitalized}"
  output="${output//\{\{head1\}\}/$capitalized}"
  output="${output//\{\{description\}\}/$description}"
  output="${output//\{\{integration\}\}/$integration_html}"
  output="${output//\{\{steps\}\}/$steps_html}"
  output="${output//\{\{image\}\}/$image}"

  echo "$output" > "$filename"
  echo "Created: $filename"

done < "$list"
