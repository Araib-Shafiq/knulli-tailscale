#!/bin/bash

tailscale_ver="1.98.4"

echo "......"
sleep 1
echo "............."
sleep 1
arch=""
echo "Running Tailscale install script for subnet route and exit node..........."
sleep 5
if [[ "$(uname -m)" == "x86_64" ]]; then
        arch="386"
fi
if [[ "$(uname -m)" == "aarch64" ]]; then
        arch="arm64"
fi
if [[ "$(uname -m)" == "aarch32" ]]; then
        arch="arm"
fi
if [[ "$(uname -m)" == "amd64" ]]; then
        arch="amd64"
fi
if [[ "$(uname -m)" == "riscv64" ]]; then
        arch="riscv64"
fi
if [[ "$(uname -m)" == "x86" ]]; then
        arch="386"
fi
if [[ "$(uname -m)" == "armv7l" ]]; then
        arch="arm"
fi

sleep 2
# Finding Architecture.

case ${arch} in
  386)
    arch="386"
    echo "supported tailscale zip $arch"
    ;;
  arm64)
    arch="arm64"
    echo "supported tailscale zip $arch"
    ;;
  arm)
    arch="arm"
    echo "supported tailscale zip $arch"
    ;;
  amd64)
    arch="amd64"
    echo "supported tailscale zip $arch"
    ;;
  riscv64)
    arch="riscv64"
    echo "supported tailscale zip $arch"
    ;;
  386)
    arch="386"
    echo "supported tailscale zip $arch"
    ;;
esac
sleep 5
knulli-services stop tailscale
echo "Stopping existing tailscale......."
sleep 5
knulli-services disable tailscale
echo "Disabling existing tailscale......"
sleep 5


# Creating temp files
echo "Creating temp files......."
rm -rf /userdata/temp
mkdir -p /userdata/temp
cd /userdata/temp || exit 1
sleep 5
# Dowload tailscale zip as per architecture
echo "Downloading tailscale for your system........"
wget -q https://pkgs.tailscale.com/stable/tailscale_${tailscale_ver}_$arch.tgz
sleep 8
# Exctrating Zip Files
echo "Extracting Files and Creating Tailscale Folders......."
tar -xf tailscale_${tailscale_ver}_$arch.tgz
cd tailscale_${tailscale_ver}_$arch || exit 1
rm -rf /userdata/tailscale
mkdir /userdata/tailscale
mv systemd /userdata/tailscale/systemd
mv tailscale /userdata/tailscale/tailscale
mv tailscaled /userdata/tailscale/tailscaled
cd /userdata || exit 1
rm -rf /userdata/temp
sleep 5
echo "Configuring Tailscale service......"
mkdir -p /userdata/system/services
sleep 5
rm -rf /userdata/system/services/tailscale
cat << 'EOF' > /userdata/system/services/tailscale
#!/bin/bash
sleep 60
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
    echo "Error: Interface $INTERFACE does not exist." >&2
    exit 1
fi

CIDDR=$(ip -o -f inet addr show "$INTERFACE" | awk '{print $4}')

if [ -z "$CIDDR" ]; then
    echo "Error: No IP address found for interface $INTERFACE." >&2
    exit 1
fi

IP=$(echo "$CIDDR" | cut -d'/' -f1)
PREFIX=$(echo "$CIDDR" | cut -d'/' -f2)

MASK=$(( 0xFFFFFFFF << (32 - PREFIX) & 0xFFFFFFFF ))
MASK_OCTETS=$(printf "%d.%d.%d.%d" $(( (MASK >> 24) & 0xFF )) \
                                  $(( (MASK >> 16) & 0xFF )) \
                                  $(( (MASK >> 8) & 0xFF )) \
                                  $(( MASK & 0xFF )))

IFS=. read -r o1 o2 o3 o4 <<< "$IP"
IFS=. read -r m1 m2 m3 m4 <<< "$MASK_OCTETS"
NETWORK=$(printf "%d.%d.%d.%d" $(( o1 & m1 )) \
                              $(( o2 & m2 )) \
                              $(( o3 & m3 )) \
                              $(( o4 & m4 )))

CIDR=$(printf $NETWORK/$PREFIX)
rm -rf /dev/net
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
cp /etc/sysctl.conf /etc/sysctl.conf.bak
rm -rf /etc/sysctl.conf
touch /etc/sysctl.conf
cat <<EOL > "/etc/sysctl.conf"
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOL
sysctl -p /etc/sysctl.conf
ethtool -K $INTERFACE rx-udp-gro-forwarding on rx-gro-list off
ethtool -K $INTERFACE gro off
iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
knulli-save-overlay
if [[ "$1" != "start" ]]; then
  exit 0
fi
/userdata/tailscale/tailscaled -state /userdata/tailscale/state > /userdata/tailscale/tailscaled.log 2>&1 &/userdata/tailscale/tailscale up --advertise-routes=$CIDR --snat-subnet-routes=false --accept-routes --advertise-exit-node --accept-dns=true

EOF
echo "Creating tun, forwarding ip and saving knulli-overlay....."
rm -rf /dev/net
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
cp /etc/sysctl.conf /etc/sysctl.conf.bak
rm -rf /etc/sysctl.conf
touch /etc/sysctl.conf
cat <<EOL > "/etc/sysctl.conf"
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOL
sleep 4
sysctl -p /etc/sysctl.conf
echo "IP Forwarded......."
sleep 4
knulli-save-overlay
echo "Knulli Overlay Saved......"
sleep 4

# Start Tailscale daemon
echo "Starting Tailscale......"
sleep 5
echo "Login to tailscale using given link and approve the machine"
sleep 5
/userdata/tailscale/tailscaled -state /userdata/tailscale/state > /userdata/tailscale/tailscaled.log 2>&1 &/userdata/tailscale/tailscale up

echo "Working on it........DONE"
sleep 2
knulli-services enable tailscale
echo "Knulli services of tailscale enabled."
sleep 5
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
    echo "Error: Interface $INTERFACE does not exist." >&2
    exit 1
fi

CIDDR=$(ip -o -f inet addr show "$INTERFACE" | awk '{print $4}')

if [ -z "$CIDDR" ]; then
    echo "Error: No IP address found for interface $INTERFACE." >&2
    exit 1
fi

IP=$(echo "$CIDDR" | cut -d'/' -f1)
PREFIX=$(echo "$CIDDR" | cut -d'/' -f2)

MASK=$(( 0xFFFFFFFF << (32 - PREFIX) & 0xFFFFFFFF ))
MASK_OCTETS=$(printf "%d.%d.%d.%d" $(( (MASK >> 24) & 0xFF )) \
                                  $(( (MASK >> 16) & 0xFF )) \
                                  $(( (MASK >> 8) & 0xFF )) \
                                  $(( MASK & 0xFF )))

IFS=. read -r o1 o2 o3 o4 <<< "$IP"
IFS=. read -r m1 m2 m3 m4 <<< "$MASK_OCTETS"
NETWORK=$(printf "%d.%d.%d.%d" $(( o1 & m1 )) \
                              $(( o2 & m2 )) \
                              $(( o3 & m3 )) \
                              $(( o4 & m4 )))

CIDR=$(printf $NETWORK/$PREFIX)
echo "Your Interface is $INTERFACE"
sleep 3
echo "Your CIDR is $CIDR"
sleep 3
ethtool -K $INTERFACE rx-udp-gro-forwarding on rx-gro-list off
ethtool -K $INTERFACE gro off
echo "starting tailscale with 'CIDR: $CIDR' and 'Exit Node'"
/userdata/tailscale/tailscaled -state /userdata/tailscale/state > /userdata/tailscale/tailscaled.log 2>&1 &/userdata/tailscale/tailscale up --advertise-routes=$CIDR --snat-subnet-routes=false --accept-routes --advertise-exit-node --accept-dns=true
echo "Knulli Started Successfully."
sleep 5
iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
echo "Check Tailscale interface and connected ip using command 'ip a'."
sleep 5
echo "Running 'ip a' command for you...."
sleep 5
ip a
echo "....."
echo ".........."
sleep 2
echo "Above you will see tailscale interface (example: 'tailscale0' below '$INTERFACE') and 'tailscale ip'"
sleep 10
echo "if 'Yes' then you have successfully configured tailscale in your knulli machine."
sleep 5
echo "if 'No' then reboot your machine and run the script again."
sleep 5
echo "Go back to tailscale admin console page and click on your newly added knulli machine and you'll find 'subnets' and 'exit node' options waiting to be approved."
sleep 5
echo "Approve them, Disable Key Expiry' and you are done."
sleep 3
echo "Your Welcome....."
sleep 3
