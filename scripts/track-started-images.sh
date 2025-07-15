#! /usr/bin/env bash

# Directory to keep track of started images
mkdir -p "/root/.docker-lru/images"

# Log container start events with the current unix timestamp and the image name
docker events --filter event=start --format '{{.Time }} {{.Actor.Attributes.image}}' | while read -r log; do
    if [[ "$log" != *":"* ]]; then
        # Append :latest tag if no tag is specified
        log="${log}:latest"
    fi
    echo "$log"
done | while read -r current_time image; do
    echo "Image $image started at timestamp $current_time."
    if [[ ! -f "/root/.docker-lru/images/$image" ]]; then
        # File doesn't exist, which means the image has never been started before
        echo "Image $image has never been started before. Initializing at /root/.docker-lru/images/$image ..."
        echo "$current_time" > "/root/.docker-lru/images/$image"
    else
        # File exists, which means the image has been started before
        echo "Image $image has been started before."
        last_use=$(<"/root/.docker-lru/images/$image")

        # Check if the last used timestamp needs to be updated
        if (( current_time > last_use )); then
            echo "This is the most recent start of $image. Updating /root/.docker-lru/images/$image ..."
            echo "$current_time" > "/root/.docker-lru/images/$image"
        else
            echo "This is not the most recent start of $image. Skipping..."
        fi
    fi
done

