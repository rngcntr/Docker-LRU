#! /usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 TARGET_BYTES"
  exit 1
fi

TARGET_BYTES=$1

# Sorted list of recently started images
SORTED_LIST=$(/root/.docker-lru/scripts/list-recent-images.sh -o h)
readarray -t RECENT_IMAGES <<< "$SORTED_LIST"

# First, we will delete all images that are not in the RECENT_IMAGES
# This ensures that we only keep the images that have been started recently

# Get all local images with their name and ID
docker images --no-trunc --format "{{ .Repository }}:{{ .Tag }} {{ .ID }}" | while read -r line; do
    image_name=$(awk '{print $1}' <<< "$line")
    image_id=$(awk '{print $2}' <<< "$line" | cut -d ':' -f 2)

    # Check if image_name is in RECENT_IMAGES
    keep=false
    for recent_image in "${RECENT_IMAGES[@]}"; do
        if [[ "$image_id" == "$recent_image" ]]; then
            keep=true
            break
        fi
    done

    if [[ "$keep" == false ]]; then
        echo "Removing image: $image_name ($image_id)"
        docker rmi -f "$image_id"
    fi
done

# Now, we will beging deleting more recently used images until we hit the target threshold of used bytes
# We will start from the least recently used image and work our way up

for least_recent_image in "${RECENT_IMAGES[@]}"; do
    total_used_bytes=$(curl --silent --unix-socket /var/run/docker.sock http://localhost/system/df | jq '.LayersSize')

    if (( total_used_bytes > $TARGET_BYTES )); then
        echo "Removing least recently used image: $least_recent_image"
        docker rmi -f "$least_recent_image"
        rm /root/.docker-lru/images/"$least_recent_image"
    fi
done

# Clean up dangling containers, volumes, and networks
docker container prune -f
for vol in $(docker volume ls --filter "dangling=true" --quiet); do docker volume rm "$vol"; done
for net in $(docker network ls --filter "dangling=true" --quiet); do docker network rm "$net"; done

docker system df
