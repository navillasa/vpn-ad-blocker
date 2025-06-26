#!/bin/bash
set -e

# === CONFIGURE THESE ===
WG_CONF="/etc/wireguard/wg0.conf"
CLIENTS_DIR="./clients"
SERVER_PUBLIC_KEY="YOUR_SERVER_PUBLIC_KEY"
VPS_IP="YOUR_VPS_IP"
WG_PORT=51820
VPN_SUBNET="10.0.0."
# ========================

if [ -z "$1" ]; then
  echo "Usage: $0 client_name"
  exit 1
fi

CLIENT_NAME=$1
mkdir -p "$CLIENTS_DIR"

# Generate client keys
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)

# Find next available IP
USED_IPS=$(grep AllowedIPs "$WG_CONF" | cut -d '=' -f2 | tr -d ' ' | cut -d '/' -f1 | sort)
NEXT_IP_LAST_OCTET=2
for ip in $USED_IPS; do
  last_octet=$(echo "$ip" | awk -F '.' '{print $4}')
  if [ "$last_octet" -ge "$NEXT_IP_LAST_OCTET" ]; then
    NEXT_IP_LAST_OCTET=$((last_octet + 1))
  fi
done
CLIENT_IP="${VPN_SUBNET}${NEXT_IP_LAST_OCTET}"

CLIENT_CONF="$CLIENTS_DIR/${CLIENT_NAME}.conf"

# Generate client config
cat > "$CLIENT_CONF" <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = $CLIENT_IP/32
DNS = $VPS_IP

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $VPS_IP:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo "✅ Client config generated at $CLIENT_CONF"

# Append to server config
{
  echo ""
  echo "[Peer]"
  echo "PublicKey = $CLIENT_PUB_KEY"
  echo "AllowedIPs = $CLIENT_IP/32"
} | sudo tee -a "$WG_CONF" > /dev/null

sudo systemctl restart wg-quick@wg0
echo "🔁 WireGuard restarted"

# Display QR code if available
if command -v qrencode > /dev/null; then
  echo "📱 Scan this QR code in the WireGuard mobile app:"
  qrencode -t ansiutf8 < "$CLIENT_CONF"
else
  echo "⚠️ qrencode not found. Install with: sudo apt install qrencode"
fi

echo "🎉 Done! Client '$CLIENT_NAME' is ready."
