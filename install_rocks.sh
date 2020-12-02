#!/bin/bash -ex

# TODO: Add argument validation

lines="$(echo -n "$1" | tr -s "\n" ";")"
IFS=";"
read -ra rocks <<<"$lines"

for rock in "${rocks[@]}"; do
  IFS="="
  set -- $rock
  name="$1"
  version="$2"
  tarantoolctl rocks install "$name $version"
done

echo "$PWD/.rocks/bin" >> "$GITHUB_PATH"
