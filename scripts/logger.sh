#! /usr/bin/env bash

mkdir -p "~/.docker-history/images"

docker events --filter event=start --format '{{.Time }} {{.Actor.Attributes.image}}' | while read -r log; do
    if [[ "$log" != *":"* ]]; then
        # No colon means no tag, append :latest
        log="${log}:latest"
    fi
    echo "$log"
done | while read -r timestamp image; do
    echo "Image $image startet at timestamp $timestamp."
    # Check if file exists
    if [[ ! -f "$HOME/.docker-history/images/$image" ]]; then
        # File doesn't exist, create it with value a
        echo "Image $image has never been started before. Initializing at $HOME/.docker-history/images/$image..."
        echo "$timestamp" > "$HOME/.docker-history/images/$image"
    else
        # File exists, read its content
        echo "Image $image has been started before."
        current=$(<"$HOME/.docker-history/images/$image")

        # Determine the maximum value
        if (( timestamp > current )); then
            echo "This is the most recent start of $image. Updating $HOME/.docker-history/images/$image..."
            echo "$timestamp" > "$HOME/.docker-history/images/$image"
        else
            echo "This is not the most recent start of $image".
        fi
    fi
done

