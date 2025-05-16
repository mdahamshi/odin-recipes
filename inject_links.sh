#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <list_file> <html_file>"
  exit 1
fi

list="$1"
html="$2"

if [[ ! -f "$list" ]]; then
  echo "List file '$list' not found!"
  exit 1
fi

if [[ ! -f "$html" ]]; then
  echo "HTML file '$html' not found!"
  exit 1
fi

# Generate the <ul> list and store it in a variable
ul_list="<ul>"
while IFS= read -r name || [[ -n "$name" ]]; do
  [[ -z "$name" ]] && continue
  capitalized="$(tr '[:lower:]' '[:upper:]' <<< "${name:0:1}")${name:1}"
  ul_list+="
  <li><a href=\"./recipes/${name}.html\">$capitalized</a></li>"
done < "$list"
ul_list+="
</ul>"

# Replace {{links}} in the HTML file safely using awk
awk -v replacement="$ul_list" '
{
  gsub(/\{\{links\}\}/, replacement)
  print
}' "$html" > "${html}.tmp" && mv "${html}.tmp" "$html"

echo "Injected links into '$html'"
