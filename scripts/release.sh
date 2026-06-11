#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
strings="$root/resources/strings/strings.xml"
props="$root/resources/customizations/properties.xml"

if [[ ! -f "$strings" ]]; then
  echo "Error: strings file not found: $strings" >&2
  exit 1
fi
if [[ ! -f "$props" ]]; then
  echo "Error: properties file not found: $props" >&2
  exit 1
fi

release_version="$(awk -F'[<>]' '/<string id="AppVersion">/ {print $3; exit}' "$strings")"
if [[ -z "$release_version" ]]; then
  echo "Error: AppVersion not found in $strings" >&2
  exit 1
fi

base_version="${release_version%%-*}"
if [[ -z "$base_version" ]]; then
  echo "Error: Unable to determine base version from '$release_version'" >&2
  exit 1
fi

export BASE_VERSION="$base_version"
perl -pi -e 's{(<string id="AppVersion">)[^<]*(</string>)}{$1.$ENV{BASE_VERSION}.$2}e' "$strings"
perl -pi -e 's{(<property id="apikey" type="string">)[^<]*(</property>)}{$1.$2}e; s{(<property id="sparkyfithost" type="string">)[^<]*(</property>)}{$1.$2}e' "$props"

cd "$root"
git add "$strings" "$props"
if git diff --cached --quiet -- "$strings" "$props"; then
  echo "No staged changes to commit."
  exit 0
fi
git commit -m "Prepare release $base_version"
echo "Committed release $base_version"
