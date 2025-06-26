#!/bin/bash
set -e

# === CONFIGURATION ===
WG_CONF="/etc/wireguard/wg0.conf"
CLIENTS_DIR="./clients"
SERVER_PUBLIC_KEY_FILE="./server_public.key"
WG_PORT=51820
VPN_SUBNET="10.0.0."

# Get VPS IP dynamically
VPS_IP=$(curl -s https://api.ipify.org)
if [ -z "$VPS_IP" ]; then
  echo "❌ Could not determine VPS public IP."
  exit 1
fi

# Parse arguments
SHOW_QR=false
while [[ "$1" != "" ]]; do
  case $1 in
    -q ) SHOW_QR=true ;;
    * )  CLIENT_NAME=$1 ;;
  esac
  shift
done

if [ -z "$CLIENT_NAME" ]; then
  echo "Usage: $0 client_name [-q]"
  exit 1
fi

# Check server public key file
if [ ! -f "$SERVER_PUBLIC_KEY_FILE" ]; then
  echo "❌ Missing $SERVER_PUBLIC_KEY_FILE"
  exit 1
fi
SERVER_PUBLIC_KEY=$(cat "$SERVER_PUBLIC_KEY_FILE")

# Create clients dir
mkdir -p "$CLIENTS_DIR"

# Generate client keys
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)

# Find next available IP
USED_IPS=$(grep AllowedIPs $WG_CONF | cut -d '=' -f2 | tr -d ' ' | cut -d '/' -f1 | sort)
NEXT_IP_LAST_OCTET=2
for ip in $USED_IPS; do
  last_octet=$(echo $ip | awk -F '.' '{print $4}')
  if [ "$last_octet" -ge "$NEXT_IP_LAST_OCTET" ]; then
    NEXT_IP_LAST_OCTET=$((last_octet + 1))
  fi
done
CLIENT_IP="$VPN_SUBNET$NEXT_IP_LAST_OCTET"

CLIENT_CONF="$CLIENTS_DIR/${CLIENT_NAME}.conf"

# Write client config
cat > "$CLIENT_CONF" <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = $CLIENT_IP/32
DNS = 10.0.0.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $VPS_IP:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Append to server config
echo -e "\n[Peer]" | sudo tee -a $WG_CONF > /dev/null
echo "PublicKey = $CLIENT_PUB_KEY" | sudo tee -a $WG_CONF > /dev/null
echo "AllowedIPs = $CLIENT_IP/32" | sudo tee -a $WG_CONF > /dev/null

sudo systemctl restart wg-quick@wg0
echo "✅ Client $CLIENT_NAME added and WireGuard restarted."
echo "📄 Config saved to $CLIENT_CONF"

# Show QR code if requested
if $SHOW_QR; then
  if ! command -v qrencode &> /dev/null; then
    echo "Installing qrencode..."
    sudo apt update && sudo apt install -y qrencode
  fi
  echo "📱 QR code for mobile import:"
  qrencode -t ansiutf8 < "$CLIENT_CONF"
fi

