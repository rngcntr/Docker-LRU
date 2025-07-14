#! /usr/bin/env bash

mkdir -p "$HOME/.docker-history/images"

find "$HOME/.docker-history/images/" -maxdepth 1 -type f | while read -r image; do
    timestamp=$(<"$image")
    echo "$timestamp $(basename "$image")"
done | sort -nk 1 | awk '{print $2}'
