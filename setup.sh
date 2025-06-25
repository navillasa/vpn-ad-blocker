#!/bin/bash
set -e

echo "Starting VPN AdBlocker setup..."

# Update & install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y wireguard ufw curl

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# Setup UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 51820/udp  # WireGuard port
sudo ufw enable

# Generate WireGuard keys (server)
SERVER_PRIV_KEY=$(wg genkey)
SERVER_PUB_KEY=$(echo "$SERVER_PRIV_KEY" | wg pubkey)

# Save keys to /etc/wireguard
sudo mkdir -p /etc/wireguard
echo "$SERVER_PRIV_KEY" | sudo tee /etc/wireguard/server_private.key > /dev/null
echo "$SERVER_PUB_KEY" | sudo tee /etc/wireguard/server_public.key > /dev/null

# Create WireGuard config file
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIV_KEY
PostUp = ufw route allow in on wg0 out on eth0; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = ufw route delete allow in on wg0 out on eth0; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

# Start WireGuard interface
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Download & install AdGuard Home
curl -s -L https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz -o AdGuardHome.tar.gz
tar -xzf AdGuardHome.tar.gz
sudo ./AdGuardHome/AdGuardHome -s install
rm -rf AdGuardHome AdGuardHome.tar.gz

echo "Done with setup! AdGuard Home UI at http://VPS_IP:3000"

