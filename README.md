# Docker-LRU

**Docker-LRU** is a set of Bash scripts and a systemd service for managing cached Docker images on a host using a Least Recently Used (LRU) eviction policy.
Its purpose is to track image usage and remove old or unused images to keep disk usage at a predefined level.

## How It Works

1. **Tracking Usage:**  
   The `track-started-images.sh` script listens to Docker events and records the last start time of each image in `~/.docker-lru/images/`.

2. **Listing Images:**  
   The `list-recent-images.sh` script outputs all images sorted by their last usage timestamp, beginning with the least recent one.

3. **Removing Old Images:**  
   The `remove-old-images.sh` script:
   - Removes images not recently used.
   - Continues removing the least recently used images until total Docker image disk usage falls below a specified threshold.

## Installation (as root)

### 1. Clone the Repository

```sh
cd /root/
git clone https://github.com/rngcntr/Docker-LRU.git .docker-lru
```

### 2. Set Up the Tracker Service

Copy the systemd service file and enable it:

```sh
cp .docker-lru/services/docker-lru-tracker.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now docker-lru-tracker.service
```

> **Note:**  
> The service runs as `root` and expects the scripts in `/root/.docker-lru/scripts/`.  
> Adjust the `ExecStart` path in `docker-lru-tracker.service` if you use a different location.

## Usage

### 1. Track Image Usage

The systemd service will automatically start tracking image usage.  
Alternatively, you can run the tracker manually:

```sh
bash scripts/track-started-images.sh
```

### 2. List Images by Recent Usage

```sh
bash scripts/list-recent-images.sh
```

### 3. Remove Old Images

```sh
bash scripts/remove-old-images.sh <TARGET_BYTES>
```

- `<TARGET_BYTES>`: The maximum allowed disk usage for Docker images (e.g., `5000000000` for 5GB).

## Automating Cleanup with Cron

To run the cleanup every 5 minutes, add this to your crontab (`crontab -e`):

```
*/5 * * * * /root/.docker-lru/scripts/remove-old-images.sh <TARGET_BYTES> >> /var/log/remove-old-images.log 2>&1
```

Replace `<TARGET_BYTES>` with your desired limit.

## Requirements

- Bash
- Docker CLI
- `jq` (for JSON parsing)
- Systemd (for persistent tracking)

## Disclaimer

Use at your own risk. This tool will remove Docker images from your system.