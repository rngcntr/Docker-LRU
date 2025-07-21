#! /usr/bin/env bash

# Default output: all fields
output="thn"

# Parse command line options
while getopts "o:" opt; do
    case $opt in
        o) output="$OPTARG" ;;
        *) echo "Usage: $0 [-o thn]" >&2; exit 1 ;;
    esac
done

mkdir -p "/root/.docker-lru/images"

find "/root/.docker-lru/images/" -maxdepth 1 -type f | while read -r path; do
    timestamp=$(cut -d ' ' -f 1 "$path")
    image=$(cut -d ' ' -f 2- "$path")
    hashname=$(basename "$path")
    line=""
    [[ $output == *t* ]] && line+="$timestamp "
    [[ $output == *h* ]] && line+="$hashname "
    [[ $output == *n* ]] && line+="$image "
    # Remove trailing whitespace
    echo "$line" | awk '{$1=$1};1'
# Sort by most recent usage, beginning with the oldest image
done | sort -nk 1 | awk 'NF'
