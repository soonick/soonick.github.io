#!/usr/bin/env bash

set -e

./_scripts/tag-generator.py

changes=$(git status --short | wc -l)

if [[ $changes > 0 ]]
then
  echo "There are tag pages that are not committed"
  exit 1
fi

echo "All good"
