#!/bin/zsh

###
### Jamf Extension Attribute: VPN Connected Status
###
### Description:
###   Checks whether a VPN tunnel is active by inspecting utun interfaces
###   and checks for PanGPS (Palo Alto GlobalProtect) as a secondary indicator.
###   Returns connection state and the tunnel IP address when connected.
###
### Output:
###   - "Connected (10.0.0.42 via utun3)" - VPN tunnel active with IP
###   - "Not Connected" - No active VPN tunnel detected
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.0.0
###

# Collect all active utun interfaces and their IPv4 addresses
# utun0 is used by macOS Continuity/Handoff; we check all and report the first
# with a routable (non-link-local) address which typically indicates a VPN.

connected=0
tunnel_iface=""
tunnel_ip=""

# ifconfig lists all interfaces; grep for utun blocks and extract IPs
while IFS= read -r line; do
    # New interface block
    if [[ "$line" =~ ^(utun[0-9]+): ]]; then
        current_iface="${match[1]}"
        continue
    fi
    # IPv4 address line within current utun block
    if [[ -n "$current_iface" && "$line" =~ ^[[:space:]]+inet[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        ip="${match[1]}"
        # Skip link-local (169.254.x.x) and loopback
        if [[ ! "$ip" =~ ^169\.254\. && "$ip" != "127.0.0.1" ]]; then
            # utun0 is typically used by macOS system features (e.g. Handoff, iCloud Private Relay)
            # We prefer higher-numbered utun interfaces but accept utun0 if nothing else is found
            if [[ "$current_iface" != "utun0" ]] || [[ -z "$tunnel_iface" ]]; then
                tunnel_iface="$current_iface"
                tunnel_ip="$ip"
                connected=1
            fi
        fi
    fi
done < <(ifconfig 2>/dev/null)

# Secondary check: GlobalProtect daemon is running (indicates GP is managing a tunnel)
pangps_running=0
pgrep -x "PanGPS" &>/dev/null && pangps_running=1

if [[ "$connected" -eq 1 ]]; then
    echo "Connected (${tunnel_ip} via ${tunnel_iface})"
elif [[ "$pangps_running" -eq 1 ]]; then
    # GP is running but no routable utun found — connecting or disconnecting
    echo "Connected (GlobalProtect active, IP pending)"
else
    echo "Not Connected"
fi

exit 0
