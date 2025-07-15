#! /usr/bin/env bash

# Directory to keep track of started images
mkdir -p "$HOME/.docker-lru/images"

find "$HOME/.docker-lru/images/" -maxdepth 1 -type f | while read -r image; do
    timestamp=$(<"$image")
    echo "$timestamp $(basename "$image")"
# Sort by most recent usage, beginning with the oldest image
done | sort -nk 1 | awk '{print $2}'
