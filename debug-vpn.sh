#!/bin/bash
# VPN Debug Script for 62.60.232.241
# Usage: scp debug-vpn.sh root@62.60.232.241:/tmp/ && ssh root@62.60.232.241 'bash /tmp/debug-vpn.sh'

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

section() { echo -e "\n${YELLOW}=== $1 ===${NC}"; }
ok()      { echo -e "${GREEN}[OK]${NC} $1"; }
fail()    { echo -e "${RED}[FAIL]${NC} $1"; }
info()    { echo -e "  $1"; }

echo "============================================"
echo "  VPN Diagnostic Report"
echo "  Server: $(hostname) ($(hostname -I 2>/dev/null | awk '{print $1}'))"
echo "  Date:   $(date)"
echo "============================================"

# 1. System info
section "System Info"
info "Uptime: $(uptime -p 2>/dev/null || uptime)"
info "Kernel: $(uname -r)"
info "RAM free: $(free -h | awk '/Mem:/{print $4}') / $(free -h | awk '/Mem:/{print $2}')"
info "Disk: $(df -h / | awk 'NR==2{print $4 " free of " $2}')"

# 2. Detect VPN type
section "VPN Service Detection"
VPN_TYPE="none"

if systemctl list-unit-files 2>/dev/null | grep -q "wg-quick"; then
    VPN_TYPE="wireguard"
    info "Detected: WireGuard"
elif systemctl list-unit-files 2>/dev/null | grep -q "openvpn"; then
    VPN_TYPE="openvpn"
    info "Detected: OpenVPN"
elif command -v outline-ss-server &>/dev/null || systemctl list-unit-files 2>/dev/null | grep -q "outline"; then
    VPN_TYPE="outline"
    info "Detected: Outline VPN (Shadowsocks)"
elif command -v xray &>/dev/null || command -v v2ray &>/dev/null; then
    VPN_TYPE="xray"
    info "Detected: XRay/V2Ray"
elif systemctl list-unit-files 2>/dev/null | grep -q "3x-ui\|x-ui"; then
    VPN_TYPE="3x-ui"
    info "Detected: 3X-UI Panel"
elif command -v ocserv &>/dev/null; then
    VPN_TYPE="openconnect"
    info "Detected: OpenConnect (ocserv)"
elif command -v ipsec &>/dev/null || command -v strongswan &>/dev/null; then
    VPN_TYPE="ipsec"
    info "Detected: IPsec/StrongSwan"
fi

if [ "$VPN_TYPE" = "none" ]; then
    fail "No known VPN service detected!"
    info "Checking all running services for clues..."
    systemctl list-units --type=service --state=running 2>/dev/null | grep -iE "vpn|wireguard|wg|openvpn|outline|shadow|xray|v2ray|x-ui|ocserv|ipsec|strongswan|sing-box|hysteria|trojan" || info "No VPN-related services found running"
    echo ""
    info "Checking Docker containers..."
    docker ps 2>/dev/null || info "Docker not available"
fi

# 3. Service status
section "VPN Service Status"
case "$VPN_TYPE" in
    wireguard)
        SERVICES=$(systemctl list-units --type=service --state=loaded 2>/dev/null | grep -o 'wg-quick@[^ ]*' || true)
        if [ -z "$SERVICES" ]; then SERVICES="wg-quick@wg0"; fi
        for svc in $SERVICES; do
            if systemctl is-active "$svc" &>/dev/null; then
                ok "$svc is running"
            else
                fail "$svc is NOT running"
                info "Status:"
                systemctl status "$svc" --no-pager 2>&1 | head -20
            fi
        done
        echo ""
        info "WireGuard interfaces:"
        wg show 2>&1 || fail "wg show failed"
        ;;
    openvpn)
        SERVICES=$(systemctl list-units --type=service --state=loaded 2>/dev/null | grep -o 'openvpn[^ ]*' || true)
        if [ -z "$SERVICES" ]; then SERVICES="openvpn openvpn-server@server"; fi
        for svc in $SERVICES; do
            if systemctl is-active "$svc" &>/dev/null; then
                ok "$svc is running"
            else
                fail "$svc is NOT running"
                systemctl status "$svc" --no-pager 2>&1 | head -20
            fi
        done
        ;;
    3x-ui|xray)
        for svc in x-ui 3x-ui xray v2ray; do
            if systemctl is-active "$svc" &>/dev/null; then
                ok "$svc is running"
            elif systemctl list-unit-files 2>/dev/null | grep -q "$svc"; then
                fail "$svc is NOT running"
                systemctl status "$svc" --no-pager 2>&1 | head -20
            fi
        done
        ;;
    *)
        info "Checking common VPN services..."
        for svc in openvpn wg-quick@wg0 x-ui 3x-ui xray v2ray outline-ss-server ocserv strongswan sing-box hysteria; do
            if systemctl is-active "$svc" &>/dev/null; then
                ok "$svc is running"
            elif systemctl list-unit-files 2>/dev/null | grep -q "^${svc}"; then
                fail "$svc exists but NOT running"
            fi
        done
        ;;
esac

# 4. Logs
section "Recent VPN Logs (last 50 lines)"
case "$VPN_TYPE" in
    wireguard)
        journalctl -u 'wg-quick@*' --since "2 hours ago" --no-pager -n 50 2>/dev/null || info "No journal logs"
        ;;
    openvpn)
        journalctl -u 'openvpn*' --since "2 hours ago" --no-pager -n 50 2>/dev/null || info "No journal logs"
        if [ -f /var/log/openvpn.log ]; then tail -50 /var/log/openvpn.log; fi
        ;;
    3x-ui|xray)
        journalctl -u 'x-ui' -u '3x-ui' -u 'xray' --since "2 hours ago" --no-pager -n 50 2>/dev/null || info "No journal logs"
        ;;
    *)
        journalctl --since "2 hours ago" --no-pager -n 50 2>/dev/null | grep -iE "vpn|wireguard|openvpn|xray|v2ray|outline|ocserv" || info "No VPN-related logs found"
        ;;
esac

# 5. Network / Firewall
section "Listening Ports (VPN-related)"
ss -tulnp 2>/dev/null | head -1
ss -tulnp 2>/dev/null | grep -iE "openvpn|wireguard|wg|xray|v2ray|outline|ocserv|ipsec|:1194|:51820|:443|:8443|:1080|:8388|:2053|:2083|:2096" || info "No VPN-related ports listening"

section "Firewall Rules"
if command -v ufw &>/dev/null; then
    info "UFW status:"
    ufw status 2>&1
fi
if command -v iptables &>/dev/null; then
    info "iptables INPUT chain:"
    iptables -L INPUT -n --line-numbers 2>&1 | head -30
    echo ""
    info "iptables NAT/POSTROUTING:"
    iptables -t nat -L POSTROUTING -n 2>&1 | head -10
fi

# 6. IP forwarding
section "IP Forwarding"
IPV4_FWD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$IPV4_FWD" = "1" ]; then
    ok "IPv4 forwarding is enabled"
else
    fail "IPv4 forwarding is DISABLED (VPN clients won't have internet)"
    info "Fix: sysctl -w net.ipv4.ip_forward=1"
fi

# 7. Network interfaces
section "Network Interfaces"
ip -brief addr 2>/dev/null || ifconfig 2>/dev/null

# 8. Summary
section "Quick Summary"
echo ""
if [ "$VPN_TYPE" = "none" ]; then
    fail "Could not detect any VPN service on this server"
    info "Possible reasons:"
    info "  - VPN was never installed"
    info "  - VPN runs in Docker (check: docker ps)"
    info "  - Non-standard VPN setup"
else
    info "VPN Type: $VPN_TYPE"
fi
echo ""
echo "============================================"
echo "  Copy the output above and share for analysis"
echo "============================================"
