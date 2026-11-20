# YOUR Personal SAIA Environment

Rather than having yet another convoluted everything-container, this one is meant to be edited by you, depending on what you need, without anything more.

The main features are
- Automatic [SAIA](https://saia.gwdg.de/) support, even with auto-generated models list
- Isolates the environment, only mounts in your current working directory

## Requirements

Debian-based (Ubuntu, Mint, PopOS):

```bash
sudo apt update
sudo apt install docker.io git python3 curl nftables
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

RHEL-based (Fedora):

```bash
sudo dnf install moby-engine docker-cli git python3 curl nftables
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

## Ignore VPNs (eduVPN)

By default the agent can reach everything your host can, including networks
behind your eduVPN. To keep it out of them, run once after every boot:

```bash
sudo ./novpn.sh
```

The agent's traffic then bypasses eduVPN (WireGuard) and uses your normal
internet connection. Traffic that would still go through a VPN interface
(`eduVPN`, `LetsConnect`, `tun*`, `wg*`) is dropped. Undo with
`sudo nft delete table inet saia_novpn`.

## Add Features

Just change the `./docker/Dockerfile` and rerun `./build.sh`!

If you need inspiration you can check out [my personal branch](https://github.com/lquenti/saia-agents-minimal/tree/personal-use) as well.

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

### The agent has no internet while my VPN is on

`novpn.sh` can only route around eduVPN's WireGuard connections. Any other VPN
(or eduVPN using OpenVPN) is blocked instead, so disconnect it while using the
agent.

## File Overview

```
build.sh              build the image
run.sh                start the container
novpn.sh              keep the container's traffic out of VPNs (sudo)
gen-config.py         generate .opencode/opencode.json
docker/Dockerfile     image definition
```
