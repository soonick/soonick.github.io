#!/usr/bin/env bash

./_scripts/tag-generator.py

changes=$(git status --short | wc -l)

if [[ $changes > 0 ]]
then
  exit 1
fi
