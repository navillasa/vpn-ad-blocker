# VPN Ad Blocker Project

A self-hosted WireGuard VPN combined with AdGuard Home for ad-blocking on all connected devices. Noodling around.

                   +---------------------+
                   |      Internet       |
                   +----------+----------+
                              |
                              | Public IP (VPS)
                        +-----v-----+
                        |   VPS     |
                        |  (Ubuntu) |
                        |           |
                +-------+-----------+-------+
                | WireGuard VPN Server      |
                | AdGuard Home DNS Server   |
                +---------------------------+
                          |
         +----------------+----------------+
         |                                 |
+--------v-------+                 +-------v-------+
| Client Device  |                 | Client Device  |
| (Laptop/Phone) |                 | (Laptop/Phone) |
+----------------+                 +---------------+
   (VPN Tunnel)                       (VPN Tunnel)


## So Far...
- Provisioned VPS on Hetzner CX21, Ubuntu 24.04
- Installed & configured WireGuard for secure VPN access
- Installed & configured AdGuard Home for DNS-level ad blocking
- Configured UFW to secure server and allow necessary traffic
- Set up VPN client config for easy connection from devices

# How to Use (Mostly Reminders for Me)
1. Connect as a VPN client
I imported my WireGuard client config into the desktop UI to set up the tunnel.

2. Set up AdGuard Home
After getting it up and running, go to `http://vps_ip:3000` to manage DNS filtering, blocklists, and settings.

## To-Do
- Write a bash script to install & configure WireGuard, AdGuard Home & UFW firewall
- Add monitoring & alerting with Prometheus and Grafana for service uptime & VPN usage
- Configure fail2ban, tighten ufw, set up logging, etc.
- Maybe containerize AGH and WG for easier upgrades/isolation
- Better instructions for adding new VPN clients and troubleshooting

## Notes
- Handled port conflicts between WG, AGH, and system services
- AdGuard Home's config file can get overwritten by the UI, so managing config through the UI avoids losing manual edits
