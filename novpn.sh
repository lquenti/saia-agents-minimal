#!/bin/bash
# Make the agent container ignore VPNs on the host. Run with sudo after every boot.
#
# eduVPN/Let's Connect (WireGuard) puts all VPN routes into routing table 51860
# and selects it with "not fwmark 51860 lookup 51860". Marking the agent's
# connections with 51860 makes them use the normal routes instead, just like
# eduVPN's own packets. Anything that would still leave through a VPN
# interface (eduVPN via OpenVPN, wg-quick, ...) is dropped.
#
# Undo: sudo ./novpn-undo.sh
set -e

[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }

# must match BRIDGE in run.sh
BRIDGE=br-saia-agent
# eduVPN default, change if you set EDUVPN_WG_FWMARK
FWMARK=51860

nft -f - <<EOF
table inet saia_novpn
delete table inet saia_novpn
table inet saia_novpn {
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
