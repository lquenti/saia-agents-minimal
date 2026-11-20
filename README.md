# YOUR Personal SAIA Environment

Rather than having yet another convoluted everything-container, this one is meant to be edited by you, depending on what you need, without anything more.

The main features are
- Automatic [SAIA](https://saia.gwdg.de/) support, even with auto-generated models list
- Isolates the environment, only mounts in your current working directory

## Requirements

Debian-based (Ubuntu, Mint, PopOS):

```bash
sudo apt update
sudo apt install docker.io git python3 curl
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

RHEL-based (Fedora):

```bash
sudo dnf install moby-engine docker-cli git python3 curl
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

Log out and back in after `usermod` (or run `newgrp docker`).

## Setup and Build

```bash
cp .env.example .env
$EDITOR .env

./build.sh

# Extra args go to docker build:
# ./build.sh --no-cache
# ./build.sh --build-arg OPENCODE_VERSION=2.3.2

# Add it as an alias:
echo 'alias agent="/path/to/repo/run.sh"' >> ~/.bashrc
```

## Add Features

Just change the `./docker/Dockerfile` and rerun `./build.sh`!

## Debug

### My models are outdated

run.sh writes `.opencode/opencode.json` in the repo directory from `.env` on
first run. The model list is read from `OPENAI_BASE_URL/models.` To
regenerate:

```bash
rm .opencode/opencode.json
./run.sh
```

### The build takes forever on the GWDG Openstack

The MTU is most likely too big. Set it to 1450 in your docker config
```bash
$ cat /etc/docker/daemon.json
{
  "mtu": 1450
}
```

## File Overview

```
build.sh              build the image
run.sh                start the container
gen-config.py         generate .opencode/opencode.json
docker/Dockerfile     image definition
```
