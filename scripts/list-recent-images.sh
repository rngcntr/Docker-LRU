#! /usr/bin/env bash

# Directory to keep track of started images
mkdir -p "/root/.docker-lru/images"

find "/root/.docker-lru/images/" -maxdepth 1 -type f | while read -r hash; do
    timestamp=$(cat "$hash" | cut -d ' ' -f 1)
    image=$(cat "$hash" | cut -d ' ' -f 2)
    echo "$timestamp $image"
# Sort by most recent usage, beginning with the oldest image
done | sort -nk 1 | awk '{print $2}'
