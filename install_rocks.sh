#!/bin/bash -ex

# TODO: Add argument validation

lines="$(echo -n "$1" | tr -s "\n" ";")"
IFS=";"
read -ra rocks <<<"$lines"

for rock in "${rocks[@]}"; do
  # TODO: Add version
  tarantoolctl rocks install $rock
done

echo "$PWD/.rocks/bin" >> $GITHUB_PATH