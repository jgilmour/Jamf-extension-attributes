#!/bin/zsh

###
### Jamf Extension Attribute: Wi-Fi SSID and Security Protocol
###
### Description:
###   Returns the connected Wi-Fi SSID and security protocol.
###
### Output:
###   - "SSID: Corp-WiFi | Security: WPA3 Personal"
###   - "Not Connected"
###   - "Wi-Fi Off"
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 1.8.0
###

# Find all Wi-Fi interfaces (typically en0, en1)
wifi_interfaces=()
while IFS= read -r iface; do
    wifi_interfaces+=("$iface")
done < <(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{found=1} found && /Device:/{print $2; found=0}')

if [[ "${#wifi_interfaces[@]}" -eq 0 ]]; then
    echo "Wi-Fi Off"
    exit 0
fi

ssid=""
iface_found=""

for iface in "${wifi_interfaces[@]}"; do
    # Check if interface is powered on
    power_state=$(networksetup -getairportpower "$iface" 2>/dev/null | awk '{print $NF}')
    if [[ "$power_state" == "Off" ]]; then
        continue
    fi

    raw=$(networksetup -getairportnetwork "$iface" 2>/dev/null)
    if echo "$raw" | grep -q "You are not associated"; then
        continue
    fi
    if echo "$raw" | grep -q "^Current Wi-Fi Network:"; then
        ssid=$(echo "$raw" | sed 's/^Current Wi-Fi Network: //')
        iface_found="$iface"
        break
    fi
done

# All interfaces are off
if [[ -z "$iface_found" ]]; then
    # Check if any interface returned power state Off
    all_off=1
    for iface in "${wifi_interfaces[@]}"; do
        power_state=$(networksetup -getairportpower "$iface" 2>/dev/null | awk '{print $NF}')
        if [[ "$power_state" != "Off" ]]; then
            all_off=0
            break
        fi
    done
    if [[ "$all_off" -eq 1 ]]; then
        echo "Wi-Fi Off"
    else
        echo "Not Connected"
    fi
    exit 0
fi

# Parse security from system_profiler
security="Unknown"
profiler_output=$(system_profiler SPAirPortDataType 2>/dev/null)

# Look for the current network block and extract Security Mode
# system_profiler output groups current network under "Current Network Information:"
security=$(echo "$profiler_output" | awk '
    /Current Network Information:/ { in_current=1 }
    in_current && /Security:/ {
        sub(/.*Security: /, "")
        print
        exit
    }
')

if [[ -z "$security" ]]; then
    security="Unknown"
fi

echo "SSID: ${ssid} | Security: ${security}"
exit 0
