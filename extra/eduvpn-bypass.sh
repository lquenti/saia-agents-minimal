#!/bin/bash
# Let the agent's traffic bypass eduVPN on the host. See README.md.
#   sudo ./eduvpn-bypass.sh on     (after every boot)
#   sudo ./eduvpn-bypass.sh off
#
# eduVPN/Let's Connect (WireGuard) puts all VPN routes into routing table 51860
# and selects it with "not fwmark 51860 lookup 51860". Marking the agent's
# connections with 51860 makes them use the normal routes instead, just like
# eduVPN's own packets. Anything that would still leave through a VPN
# interface (eduVPN via OpenVPN, other VPNs) is dropped.
set -e

case "$1" in
    on|off) ;;
    *) echo "usage: sudo $0 on|off" >&2; exit 1 ;;
esac
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }

# must match --network in run.sh
NETWORK=lquenti-saia-agents-eduvpn
BRIDGE=br-saia-eduvpn
# eduVPN default, change if you set EDUVPN_WG_FWMARK
FWMARK=51860

if [ "$1" = off ]; then
    nft delete table inet saia_eduvpn_bypass
    exit 0
fi

# own bridge with a fixed name, so the rules only match the agent
docker network inspect "$NETWORK" >/dev/null 2>&1 \
    || docker network create -o "com.docker.network.bridge.name=$BRIDGE" "$NETWORK" >/dev/null

nft -f - <<EOF
table inet saia_eduvpn_bypass
delete table inet saia_eduvpn_bypass
table inet saia_eduvpn_bypass {
    chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        iifname "$BRIDGE" ct mark set $FWMARK
        ct mark $FWMARK meta mark set $FWMARK
    }
    chain forward {
        type filter hook forward priority mangle; policy accept;
        iifname "$BRIDGE" oifname "eduVPN" drop
        iifname "$BRIDGE" oifname "LetsConnect" drop
        iifname "$BRIDGE" oifname "tun*" drop
        iifname "$BRIDGE" oifname "wg*" drop
    }
}
EOF
