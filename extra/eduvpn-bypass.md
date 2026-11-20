# How the eduVPN Bypass Works

`eduvpn-bypass.sh` makes the agent container ignore eduVPN: its traffic uses
your normal internet connection while the rest of your machine stays in
eduVPN. This document explains why that works and links every claim to the
source code, so you can check it yourself.

All links are pinned to fixed versions so line numbers stay valid:

| Project | Version |
| --- | --- |
| eduVPN Linux client ([linux-app](https://codeberg.org/eduVPN/linux-app), moved from GitHub [`python-eduvpn-client`](https://github.com/eduvpn/python-eduvpn-client)) | commit `df99926` (2026-11-03) |
| NetworkManager | 1.58.1 |
| Linux kernel | v6.12 |
| nftables | v1.1.3 |
| wireguard-tools | v1.0.20250521 |
| Docker (moby) | v28.5.2 |
| systemd | v257 |

## TL;DR

eduVPN puts every VPN route into its own routing table (`51860`) and only
sends packets there that do *not* carry the firewall mark `51860`. eduVPN
itself uses that exception so its encrypted packets don't loop back into the
tunnel. The script stamps the same mark on every connection of the agent
container, so the kernel routes the agent like eduVPN's own packets: past the
VPN, out of your normal network interface.

## 1. How eduVPN Routes Traffic on Linux

The Linux client configures WireGuard through NetworkManager in
`start_wireguard_connection()`.

**The interface is called `eduVPN`** (or `LetsConnect` for the Let's Connect!
variant). The interface name is the variant's `translation_domain`
([nm.py#L566](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L566)),
which is `"eduVPN"`
([variants.py#L62](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/variants.py#L62))
or `"LetsConnect"`
([variants.py#L74](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/variants.py#L74)).

**All VPN routes go into table 51860.** eduVPN turns off NetworkManager's own
default route handling, picks the fwmark `51860` (overridable with
`EDUVPN_WG_FWMARK`), and uses that number both as routing table and as the
WireGuard fwmark
([nm.py#L642-L660](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L642-L660)):

```python
w_con.set_property(NM.SETTING_WIREGUARD_IP4_AUTO_DEFAULT_ROUTE, 0)
...
fwmark = int(os.environ.get("EDUVPN_WG_FWMARK", 51860))
...
s_ip4.set_property(NM.SETTING_IP_CONFIG_ROUTE_TABLE, fwmark)
...
w_con.set_property(NM.DEVICE_WIREGUARD_FWMARK, fwmark)
```

What NetworkManager does with that:

- `ipv4.route-table` puts *all* routes of the connection into that table
  ([nm-setting-ip-config.c#L6805-6824](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/1.58.1/src/libnm-core-impl/nm-setting-ip-config.c#L6805-6824)).
- `wireguard.peer-routes` is on by default and adds a route for each peer's
  AllowedIPs "in the routing tables according to ipv4.route-table"
  ([nm-setting-wireguard.c#L2441-2456](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/1.58.1/src/libnm-core-impl/nm-setting-wireguard.c#L2441-2456)).
  eduVPN passes the server's AllowedIPs straight through
  ([nm.py#L588](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L588)).
  For a full tunnel profile that is `0.0.0.0/0`; for a split tunnel profile,
  it's your institution's internal ranges.
- `wireguard.fwmark` is "a 32-bit fwmark for outgoing packets"
  ([nm-setting-wireguard.c#L2400-2409](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/1.58.1/src/libnm-core-impl/nm-setting-wireguard.c#L2400-2409),
  same in [wg(8)](https://git.zx2c4.com/wireguard-tools/tree/src/man/wg.8?h=v1.0.20250521#n87)):
  every encrypted packet the `eduVPN` interface sends to the VPN server
  carries mark `51860`.

So your main routing table stays exactly as it was without eduVPN. The VPN
only exists in table 51860.

**One rule decides who uses table 51860**
([nm.py#L675-L681](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L675-L681)):

```python
rule = NM.IPRoutingRule.new(family)
rule.set_priority(prios[0])
rule.set_invert(True)
# fwmask 0xffffffff is the default
rule.set_fwmark(fwmark, 0xFFFFFFFF)
rule.set_table(fwmark)
```

That is `ip rule`'s `not fwmark 51860 lookup 51860`: every packet *without*
mark 51860 goes to the VPN table. The encrypted WireGuard packets carry the
mark, skip that rule and leave through your normal network. Otherwise they
would be routed into the tunnel they are building. This is the standard
WireGuard pattern: wg-quick does the same
([linux.bash#n223](https://git.zx2c4.com/wireguard-tools/tree/src/wg-quick/linux.bash?h=v1.0.20250521#n223)),
and NetworkManager documents it as "Improved Rule-based Routing"
([nm-setting-wireguard.c#L2490-2498](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/1.58.1/src/libnm-core-impl/nm-setting-wireguard.c#L2490-2498)).

**"Allow LAN" adds a few more rules.** The setting is on by default
([config.py#L13](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/config.py#L13))
and adds:

- for each private range (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16,
  fc00::/7), a rule "look up the main table, but ignore default routes"
  (`suppress_prefixlength 0`) with a *higher* priority than the VPN rule
  ([nm.py#L493-L500](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L493-L500),
  [nm.py#L711-L716](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L711-L716)).
  These rules set no table, and new NetworkManager rules default to `main`
  ([nm-setting-ip-config.c#L1650-1662](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/1.58.1/src/libnm-core-impl/nm-setting-ip-config.c#L1650-1662)).
- if the VPN's own address range is itself private, an "exclude" rule with
  the highest priority that sends that range to table 51860 regardless of
  marks
  ([nm.py#L516-L522](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L516-L522),
  [nm.py#L699-L710](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L699-L710)).

The priorities come from `get_priorities()`
([nm.py#L462-L473](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L462-L473)).
With the defaults (Allow LAN on, no ProxyGuard), `ip rule` looks roughly like
this (`0xca94` is 51860; `10.42.0.0/24` stands in for the VPN's own range):

```
0:      from all lookup local
1:      from all to 10.42.0.0/24 lookup 51860 suppress_prefixlength 0
2:      from all to 10.0.0.0/8 lookup main suppress_prefixlength 0
2:      from all to 172.16.0.0/12 lookup main suppress_prefixlength 0
2:      from all to 192.168.0.0/16 lookup main suppress_prefixlength 0
3:      not from all fwmark 0xca94 lookup 51860
32766:  from all lookup main
32767:  from all lookup default
```

Rules are tried from the lowest number up. A rule that finds no usable route
(for example because `suppress_prefixlength 0` discarded the default route)
does not match, and the next rule is tried
([ip-rule(8)](https://man7.org/linux/man-pages/man8/ip-rule.8.html)).

**ProxyGuard** (WireGuard over TCP) only changes the WireGuard endpoint to a
local proxy
([nm.py#L575](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L575))
and shifts the priorities. The interface, table and mark stay the same.

**DNS**: eduVPN registers its DNS servers on the VPN connection. For full
tunnel profiles they also get the highest priority and the `~.` routing
domain, so all lookups go to them
([nm.py#L613-L622](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L613-L622)).

## 2. The Kernel Behavior We Rely On

**Rule matching on fwmark.** `fib_rule_match()` compares the packet's mark
with the rule's mark and, for `not` rules, inverts the result
([fib_rules.c#L259-L290](https://github.com/torvalds/linux/blob/v6.12/net/core/fib_rules.c#L259-L290)):

```c
if ((rule->mark ^ fl->flowi_mark) & rule->mark_mask)
	goto out;
...
out:
	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
```

A packet with mark 51860 therefore never matches `not fwmark 51860`.

**Forwarded packets are routed after PREROUTING.** `ip_rcv()` runs the
`PRE_ROUTING` netfilter hook and only then calls `ip_rcv_finish()`
([ip_input.c#L560-L572](https://github.com/torvalds/linux/blob/v6.12/net/ipv4/ip_input.c#L560-L572)),
which does the route lookup
([ip_input.c#L364-L368](https://github.com/torvalds/linux/blob/v6.12/net/ipv4/ip_input.c#L364-L368)).
A mark set in a prerouting chain therefore decides where the packet goes.

**Hook order inside PREROUTING.** Connection tracking runs at -200, mangle at
-150 and destination NAT at -100
([netfilter_ipv4.h#L34-L41](https://github.com/torvalds/linux/blob/v6.12/include/uapi/linux/netfilter_ipv4.h#L34-L41),
[nft.txt#n471](https://git.netfilter.org/nftables/tree/doc/nft.txt?h=v1.1.3#n471)).
In a `priority mangle` chain the connection is already known, so its
conntrack mark can be read and written there.

## 3. What `eduvpn-bypass.sh` Does

**A dedicated bridge.** The script creates a Docker network whose Linux
bridge has a fixed name, `br-saia-eduvpn`, using Docker's
`com.docker.network.bridge.name` option
([labels.go#L4-L5](https://github.com/moby/moby/blob/v28.5.2/libnetwork/drivers/bridge/labels.go#L4-L5)).
Everything the agent sends enters the host through that interface. Other
containers and the host itself are untouched.

**Mark the agent's connections, in both directions:**

```
chain prerouting {
    type filter hook prerouting priority mangle; policy accept;
    iifname "br-saia-eduvpn" ct mark set 51860
    ct mark 51860 meta mark set 51860
}
```

1. A packet coming from the agent's bridge labels its whole connection with
   conntrack mark 51860
   ([statements.txt#n257](https://git.netfilter.org/nftables/tree/doc/statements.txt?h=v1.1.3#n257)).
2. Every packet of such a connection, including the replies arriving on your
   Wi-Fi or Ethernet, gets the packet mark 51860
   ([statements.txt#n333](https://git.netfilter.org/nftables/tree/doc/statements.txt?h=v1.1.3#n333)).
   The packet mark is what routing rules look at.

Copying a mark between conntrack and packets in a mangle chain is the same
trick wg-quick uses for its own packets
([linux.bash#n238](https://git.zx2c4.com/wireguard-tools/tree/src/wg-quick/linux.bash?h=v1.0.20250521#n238),
[linux.bash#n239](https://git.zx2c4.com/wireguard-tools/tree/src/wg-quick/linux.bash?h=v1.0.20250521#n239)).

**Drop anything that would still enter a VPN:**

```
chain forward {
    type filter hook forward priority mangle; policy accept;
    iifname "br-saia-eduvpn" oifname "eduVPN" drop
    iifname "br-saia-eduvpn" oifname "LetsConnect" drop
    iifname "br-saia-eduvpn" oifname "tun*" drop
    iifname "br-saia-eduvpn" oifname "wg*" drop
}
```

The mark can't cover every case (see below), so this is the safety net: if
routing still picks a VPN interface, the packet is dropped instead of sent.
The `*` matches interface name prefixes
([primary-expression.txt#n39](https://git.netfilter.org/nftables/tree/doc/primary-expression.txt?h=v1.1.3#n39)).
A `drop` in any base chain is final, so Docker's own `accept` rules later in
the forward hook can't undo it.

**Rebuild, don't stack.** `table ...; delete table ...; table ... { }` in one
`nft -f` run is atomic, so running `on` twice doesn't duplicate rules, and
`off` removes everything with one `nft delete table`.

## 4. Walking Through It

Examples use a full tunnel profile, the agent at `172.18.0.2` and your
router at `192.168.1.1` on `wlan0`.

**The agent opens `https://1.2.3.4`:**

1. The SYN enters on `br-saia-eduvpn`. Prerouting sets conntrack mark and
   packet mark 51860.
2. Routing: rule 1 and the rule 2 entries don't match a public address. Rule
   3 (`not fwmark 0xca94`) doesn't match a marked packet. Rule 32766 (main)
   matches: `default via 192.168.1.1 dev wlan0`.
3. Docker's masquerading rewrites the source to your machine's LAN address,
   and the packet leaves through `wlan0`, outside of eduVPN.
4. The reply arrives on `wlan0`. Its connection has conntrack mark 51860, so
   it gets packet mark 51860. Docker's NAT rewrites the destination back to
   `172.18.0.2`. Routing again skips rule 3, and main has the route to
   `br-saia-eduvpn`.

Without the mark on the *reply*, step 4 would hit rule 3 when Allow LAN is
off: table 51860 has `0.0.0.0/0 dev eduVPN`, and the reply for the container
would be sent into the tunnel.

**The agent tries an internal address, e.g. `10.20.30.40`:**

1. The packet is marked.
2. The rule 2 entry for `10.0.0.0/8` looks in main without its default
   route. Main has no route for `10.20.30.40` (unless your home network is
   in 10/8), so nothing matches. Rule 3 is skipped because of the mark. Main
   sends it to your home router, and from there into the internet, where
   private addresses are not routed. It never enters the tunnel.

**The agent tries the VPN's own range (e.g. the VPN gateway or its DNS
server):** rule 1 sends it to table 51860 even though it is marked, so
routing picks `eduVPN`. The forward chain drops it.

**Why `--dns 9.9.9.9`:** without it, Docker forwards the container's DNS
queries to the nameservers configured on the host, which include eduVPN's
DNS servers, first in line with a full tunnel profile
([section 1](#1-how-eduvpn-routes-traffic-on-linux)). Those are
typically only reachable inside the VPN, so lookups would hang or fail. With
`--dns`, Docker's embedded resolver dials the upstream server from inside
the container's network namespace
([resolver.go#L499-L525](https://github.com/moby/moby/blob/v28.5.2/libnetwork/resolver.go#L499-L525),
[sandbox_linux.go#L135-L143](https://github.com/moby/moby/blob/v28.5.2/libnetwork/sandbox_linux.go#L135-L143)).
DNS queries therefore leave through the bridge, are marked and bypass
eduVPN like everything else.

## 5. Limitations

- **OpenVPN profiles are blocked, not bypassed.** The OpenVPN path sets no
  routing table
  ([nm.py#L437-L460](https://codeberg.org/eduVPN/linux-app/src/commit/df99926b991f2245c07cfdf4c175b38440d4c3ea/eduvpn/nm.py#L437-L460)),
  so NetworkManager puts its routes into the main table
  ([nm-setting-ip-config.c#L6817-6819](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/1.58.1/src/libnm-core-impl/nm-setting-ip-config.c#L6817-6819)).
  There is no mark-based exception to reuse, so traffic routed via `tun*` is
  dropped and the agent is offline while such a profile is connected.
- **Other VPNs** (`wg*`, `tun*`) are dropped the same way.
- **`EDUVPN_WG_FWMARK`**: if you override eduVPN's mark, set the same value
  as `FWMARK` in the script. Otherwise the agent is blocked, not bypassed.
- **Reboots** clear the rules. Rerun `on` after every boot.
- **Only connections started by the agent** are marked. Connections from the
  host to the container are not, which this setup doesn't need.
- **IPv6**: the `inet` table covers IPv6 as well, and eduVPN uses the same
  mark for it. Docker networks are IPv4-only unless you enable IPv6.
- **Reverse path filtering**: when a packet arrives, the kernel checks that
  the route back to its sender leaves through the same interface. That check
  only considers the packet mark if `src_valid_mark` is set
  ([fib_frontend.c#L369](https://github.com/torvalds/linux/blob/v6.12/net/ipv4/fib_frontend.c#L369),
  [ip-sysctl.rst#L1744-L1773](https://github.com/torvalds/linux/blob/v6.12/Documentation/networking/ip-sysctl.rst#L1744-L1773)).
  With strict mode (`rp_filter=1`) and `src_valid_mark=0`, replies could be
  dropped under a full tunnel. Loose mode (`2`), which systemd sets by
  default
  ([50-default.conf#L25-L27](https://github.com/systemd/systemd/blob/v257/sysctl.d/50-default.conf#L25-L27)),
  is fine. So is `net.ipv4.conf.all.src_valid_mark=1`, which wg-quick sets
  for the same reason
  ([linux.bash#n240](https://git.zx2c4.com/wireguard-tools/tree/src/wg-quick/linux.bash?h=v1.0.20250521#n240)).

## 6. Verify It on Your Machine

With eduVPN connected:

```bash
# eduVPN's rules and its table
ip rule
ip route show table 51860

# the same destination, routed without and with the mark
ip route get 1.1.1.1                  # dev eduVPN (full tunnel)
ip route get 1.1.1.1 mark 51860       # dev wlan0/eth0: the bypass

# the loaded rules
sudo nft list table inet saia_eduvpn_bypass
```

Inside the agent container:

```bash
curl -s https://ifconfig.co           # your home IP, not the eduVPN one
```
