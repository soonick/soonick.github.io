#!/usr/bin/env python

import glob
import os
from sets import Set

post_dir = '_posts/'
tag_dir = 'tag-pages/'

filenames = glob.glob(post_dir + '*md')

all_tags = Set()
for filename in filenames:
    f = open(filename, 'r')

    in_front_matter = False
    in_tags = False
    for line in f:
        if in_tags:
            stripped_line = line.strip().split()
            if stripped_line[0] == '-':
                all_tags.add(stripped_line[1])
            else:
                # We already processed the last tag, finish working on this file
                break

        if line.strip() == '---':
            if in_front_matter:
                # This is the end of the front matter, we are done for this file
                break
            else:
                in_front_matter = True

        if in_front_matter:
            stripped_line = line.strip().split()
            if stripped_line[0] == 'tags:':
                in_tags = True
    f.close()


all_tags = set(all_tags)

old_tags = glob.glob(tag_dir + '*.md')
for tag in old_tags:
    os.remove(tag)

if not os.path.exists(tag_dir):
    os.makedirs(tag_dir)

for tag in all_tags:
    tag_filename = tag_dir + tag + '.md'
    f = open(tag_filename, 'a')
    write_str = '---\nlayout: tag-page\ntitle: \"Tag: ' + tag + '\"\ntag: ' + tag + '\npermalink: /tag/' + tag + '\nrobots: noindex\n---\n'
    f.write(write_str)
    f.close()

print("Tags pages generated:", all_tags.__len__())
