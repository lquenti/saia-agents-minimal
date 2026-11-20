# Extra Goodies

Optional add-ons. None of them are wired into the main setup, so pick what you
need and follow its instructions.

## eduvpn-bypass.sh: Keep the Agent out of eduVPN

While you are connected to eduVPN, the agent can reach everything behind it,
like your institution's internal network. With this, the agent's traffic
bypasses eduVPN and uses your normal internet connection instead, as if eduVPN
were off. Traffic that would still go through eduVPN (or any other VPN
interface: `tun*`, `wg*`) is dropped. For how and why this works, with links
to the eduVPN, NetworkManager and kernel sources, see
[eduvpn-bypass.md](eduvpn-bypass.md).

Requires `nftables` (`sudo apt install nftables` / `sudo dnf install nftables`).

Turn it on (rules are gone after a reboot, so rerun it after every boot):

```bash
sudo ./extra/eduvpn-bypass.sh on
```

Then add these lines to the `docker run` in `run.sh`. The DNS is needed
because eduVPN's DNS servers are not reachable from outside eduVPN:

```bash
    --network lquenti-saia-agents-eduvpn \
    --dns 9.9.9.9 \
```

Turn it off:

```bash
sudo ./extra/eduvpn-bypass.sh off
```

To check it, connect eduVPN, start the agent and run `curl -s https://ifconfig.co`
inside the container. It should print your home IP, not the eduVPN one.

### The agent has no internet while eduVPN is on

The bypass only works for eduVPN connections using WireGuard (the default). If
your eduVPN profile uses OpenVPN, the agent's traffic is blocked instead, so
disconnect eduVPN while using the agent.

With WireGuard, make sure `sysctl net.ipv4.conf.all.rp_filter` is not `1`
(strict). Debian, Fedora and Ubuntu default to `2`.
