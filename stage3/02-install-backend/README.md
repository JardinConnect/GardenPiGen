# Install Backend

This stage installs the GardenBack backend from a git submodule.

## Setup

Before building the image, initialize the git submodule:

```bash
git submodule add git@github.com:JardinConnect/GardenBack.git back/GardenBack
git submodule update --init --recursive
```

## What it does

- Installs required packages (Python, lighttpd, mosquitto, etc.)
- Copies GardenBack code from the `back/GardenBack` submodule to `/opt/gardenback`
- Sets up Python virtual environment
- Installs Python dependencies from requirements.txt
- Runs database migrations if alembic is present
- Configures and enables systemd services
- Sets up lighttpd proxy configuration
- Configures mosquitto MQTT broker
