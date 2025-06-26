# VPN Ad Blocker

A self-hosted WireGuard VPN combined with AdGuard Home for ad-blocking on all connected devices.

```
       +-------------+
       |  Internet   |
       +------+------+ 
              |
       Public IP (VPS)
              |
         +----v----+
         |   VPS   |
         | Ubuntu  |
         +----+----+
              |
   +----------+-----------+
   | WireGuard VPN Server |
   |  AdGuard Home DNS    |
   +----------+-----------+
              |
      +-------+-------+
      |               |
  +---v---+       +---v---+
  | Client|       | Client|
  |Device |       |Device |
  |(Laptop|       |(Phone)|
  | or    |       | or    |
  |Phone) |       |Laptop)|
  +-------+       +-------+
(VPN Tunnel)     (VPN Tunnel)
```

## So Far...
- Provisioned VPS on Hetzner CX21, Ubuntu 24.04
- Installed & configured WireGuard for secure VPN access
- Installed & configured AdGuard Home for DNS-level ad blocking
- Configured UFW to secure server and allow necessary traffic
- Set up VPN client config for easy connection from devices

## Scripts
This repo includes helper scripts to speed up provisioning and client setup.

### `setup.sh`

Installs and configures WireGuard and AdGuard Home.  
Run this on your VPS:

```bash
curl -O https://raw.githubusercontent.com/navillasa/vpn-ad-blocker/main/setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

### `add-client.sh`

Generates a new WireGuard config for an additional client device (e.g. laptop or phone).

If `qrencode` is installed, it also prints a QR code to scan from the WireGuard mobile app.

```bash
chmod +x add-client.sh
sudo ./add-client.sh clientname
```
The config will be in ./clients/clientname.conf, and you can scan the QR code directly into the WireGuard mobile app:

1. Open the WireGuard app
2. Tap +
3. Choose "Scan from QR code"

## Takeaways
- Refreshed knowledge of Linux server security, ufw configuration, and SSH hardening
- Practiced setting up secure VPN access with WireGuard
- Learned to manage DNS-level ad blocking using AdGuard Home
- Practiced troubleshooting networking and port conflicts
- Remembered how important it is to lock things down early 😅
