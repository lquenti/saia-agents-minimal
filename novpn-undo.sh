#!/bin/bash
# Remove the rules added by novpn.sh. The agent's traffic follows the VPN again.
set -e

[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }

nft delete table inet saia_novpn
