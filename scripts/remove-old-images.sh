#! /usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 TARGET_BYTES"
  exit 1
fi

TARGET_BYTES=$1

# Generate list of images to keep using your script
KEEP_LIST=$($HOME/.docker-history/scripts/list-recent-images.sh)

# Convert the list to an array
readarray -t KEEP_ARRAY <<< "$KEEP_LIST"

# Get all local images with their name and ID
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | while read -r line; do
    image_name=$(awk '{print $1}' <<< "$line")
    image_id=$(awk '{print $2}' <<< "$line")

    # Check if image_name is in KEEP_ARRAY
    keep=false
    for keep_image in "${KEEP_ARRAY[@]}"; do
        if [[ "$image_name" == "$keep_image" ]]; then
            keep=true
            break
        fi
    done

    if [[ "$keep" == false ]]; then
        echo "Removing image: $image_name ($image_id)"
        docker rmi "$image_id"
    fi
done

for least_recent_image in "${KEEP_ARRAY[@]}"; do
    current_bytes=$(curl --silent --unix-socket /var/run/docker.sock http://localhost/system/df | jq '[.Images[].Size] | add')

    if (( current_bytes > $TARGET_BYTES )); then
        docker rmi "$least_recent_image"
    fi
done
