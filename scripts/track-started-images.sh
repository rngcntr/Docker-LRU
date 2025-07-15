#! /usr/bin/env bash

# Directory to keep track of started images
mkdir -p "/root/.docker-lru/images"

# Log container start events with the current unix timestamp and the image name
docker events --filter event=start --format '{{.Time}} {{.Actor.Attributes.image}}' | while read -r timestamp image; do
    hash=$(docker image inspect --format '{{.ID}}' "$image" | cut -d ':' -f 2)
    echo "$timestamp $image $hash"
done | while read -r current_time image hash; do
    echo "Image $image started at timestamp $current_time."
    if [[ ! -f "/root/.docker-lru/images/$hash" ]]; then
        # File doesn't exist, which means the image has never been started before
        echo "Image $image has never been started before. Initializing at /root/.docker-lru/images/$hash ..."
        echo "$current_time $image" > "/root/.docker-lru/images/$hash"
    else
        # File exists, which means the image has been started before
        echo "Image $image has been started before."
        last_use=$(cat "/root/.docker-lru/images/$hash" | cut -d ' ' -f 1)

        # Check if the last used timestamp needs to be updated
        if (( current_time > last_use )); then
            echo "This is the most recent start of $image. Updating /root/.docker-lru/images/$hash ..."
            echo "$current_time $image" > "/root/.docker-lru/images/$hash"
        else
            echo "This is not the most recent start of $image. Skipping..."
        fi
    fi
done

