#!/usr/bin/env bash

set -e

current_tag_pages=$(ls -ld tag-pages/* | wc -l)
new_tag_pages=$(./_scripts/tag-generator.py | awk '{print $NF}')

if [ $current_tag_pages -ne $new_tag_pages ]
then
  echo "There are tag pages that are not committed"
  exit 1
fi

echo "All good"
