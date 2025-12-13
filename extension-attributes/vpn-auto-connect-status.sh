#!/bin/bash

###
### Jamf Extension Attribute: VPN Client Auto-Connect Status
###
### Description:
###   Checks if enterprise VPN clients are configured to auto-connect on startup.
###   Ensures remote workers maintain security posture by automatically connecting
###   to corporate VPN. Supports top 10 enterprise VPN clients.
###
### Requirements:
###   - macOS with VPN client(s) installed
###   - Read permissions for user preferences and application support directories
###
### Output:
###   - "Not Installed" - No supported VPN clients found
###   - "[VPN Name]: Enabled" - Auto-connect is enabled
###   - "[VPN Name]: Disabled" - Auto-connect is disabled
###   - "[VPN Name]: Unknown" - VPN installed but auto-connect status unclear
###   - Multiple VPNs: "Cisco AnyConnect: Enabled, GlobalProtect: Disabled"
###
### Supported VPN Clients:
###   - Cisco AnyConnect
###   - Palo Alto GlobalProtect
###   - Fortinet FortiClient
###   - Zscaler
###   - Pulse Secure
###   - OpenVPN/Tunnelblick
###   - Sophos Connect
###   - SonicWall NetExtender
###   - Check Point VPN
###   - Cloudflare WARP
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2025-12-13
### Version: 1.0.0
###

# Function to check Cisco AnyConnect
check_cisco_anyconnect() {
    local app_path="/Applications/Cisco/Cisco AnyConnect Secure Mobility Client.app"
    local alt_app_path="/Applications/Cisco AnyConnect Secure Mobility Client.app"

    if [[ -d "$app_path" ]] || [[ -d "$alt_app_path" ]]; then
        # Check preferences for auto-connect
        local pref_file="$HOME/Library/Preferences/com.cisco.anyconnect.gui.plist"

        if [[ -f "$pref_file" ]]; then
            local auto_connect
            auto_connect=$(defaults read com.cisco.anyconnect.gui AutoConnectOnStart 2>/dev/null)

            if [[ "$auto_connect" == "1" ]] || [[ "$auto_connect" == "true" ]]; then
                echo "Cisco AnyConnect: Enabled"
            elif [[ "$auto_connect" == "0" ]] || [[ "$auto_connect" == "false" ]]; then
                echo "Cisco AnyConnect: Disabled"
            else
                echo "Cisco AnyConnect: Unknown"
            fi
        else
            echo "Cisco AnyConnect: Unknown"
        fi
    fi
}

# Function to check Palo Alto GlobalProtect
check_globalprotect() {
    local app_path="/Applications/GlobalProtect.app"

    if [[ -d "$app_path" ]]; then
        # Check system-level preferences first
        local sys_pref="/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist"
        local user_pref="$HOME/Library/Preferences/com.paloaltonetworks.GlobalProtect.settings.plist"

        local connect_on_demand=""

        if [[ -f "$sys_pref" ]]; then
            connect_on_demand=$(defaults read /Library/Preferences/com.paloaltonetworks.GlobalProtect.settings Palo\ Alto\ Networks.GlobalProtect.ConnectOnDemand 2>/dev/null)
        fi

        if [[ -z "$connect_on_demand" ]] && [[ -f "$user_pref" ]]; then
            connect_on_demand=$(defaults read "$user_pref" ConnectOnDemand 2>/dev/null)
        fi

        if [[ "$connect_on_demand" == "1" ]] || [[ "$connect_on_demand" == "yes" ]]; then
            echo "GlobalProtect: Enabled"
        elif [[ "$connect_on_demand" == "0" ]] || [[ "$connect_on_demand" == "no" ]]; then
            echo "GlobalProtect: Disabled"
        else
            echo "GlobalProtect: Unknown"
        fi
    fi
}

# Function to check Fortinet FortiClient
check_forticlient() {
    local app_path="/Applications/FortiClient.app"

    if [[ -d "$app_path" ]]; then
        # Check configuration files
        local config_dir="$HOME/Library/Application Support/Fortinet/FortiClient"
        local pref_file="$HOME/Library/Preferences/com.fortinet.FortiClient.plist"

        if [[ -f "$pref_file" ]]; then
            local auto_connect
            auto_connect=$(defaults read com.fortinet.FortiClient AutoConnect 2>/dev/null)

            if [[ "$auto_connect" == "1" ]] || [[ "$auto_connect" == "true" ]]; then
                echo "FortiClient: Enabled"
            elif [[ "$auto_connect" == "0" ]] || [[ "$auto_connect" == "false" ]]; then
                echo "FortiClient: Disabled"
            else
                echo "FortiClient: Unknown"
            fi
        else
            echo "FortiClient: Unknown"
        fi
    fi
}

# Function to check Zscaler
check_zscaler() {
    local app_path="/Applications/Zscaler/Zscaler.app"

    if [[ -d "$app_path" ]]; then
        # Zscaler typically auto-connects by default if tunnel is configured
        local pref_file="$HOME/Library/Preferences/com.zscaler.Zscaler.plist"

        if [[ -f "$pref_file" ]]; then
            # Check if tunnel is enabled
            local tunnel_enabled
            tunnel_enabled=$(defaults read com.zscaler.Zscaler tunnel_enabled 2>/dev/null)

            if [[ "$tunnel_enabled" == "1" ]] || [[ "$tunnel_enabled" == "true" ]]; then
                echo "Zscaler: Enabled"
            elif [[ "$tunnel_enabled" == "0" ]] || [[ "$tunnel_enabled" == "false" ]]; then
                echo "Zscaler: Disabled"
            else
                echo "Zscaler: Unknown"
            fi
        else
            echo "Zscaler: Unknown"
        fi
    fi
}

# Function to check Pulse Secure
check_pulse_secure() {
    local app_path="/Applications/Pulse Secure.app"

    if [[ -d "$app_path" ]]; then
        local pref_file="$HOME/Library/Preferences/net.pulsesecure.pulsetray.plist"

        if [[ -f "$pref_file" ]]; then
            local auto_launch
            auto_launch=$(defaults read net.pulsesecure.pulsetray AutoLaunch 2>/dev/null)

            if [[ "$auto_launch" == "1" ]] || [[ "$auto_launch" == "true" ]]; then
                echo "Pulse Secure: Enabled"
            elif [[ "$auto_launch" == "0" ]] || [[ "$auto_launch" == "false" ]]; then
                echo "Pulse Secure: Disabled"
            else
                echo "Pulse Secure: Unknown"
            fi
        else
            echo "Pulse Secure: Unknown"
        fi
    fi
}

# Function to check Tunnelblick (OpenVPN)
check_tunnelblick() {
    local app_path="/Applications/Tunnelblick.app"

    if [[ -d "$app_path" ]]; then
        local pref_file="$HOME/Library/Preferences/net.tunnelblick.tunnelblick.plist"

        if [[ -f "$pref_file" ]]; then
            local auto_connect
            auto_connect=$(defaults read net.tunnelblick.tunnelblick launchAtNextLogin 2>/dev/null)

            if [[ "$auto_connect" == "1" ]] || [[ "$auto_connect" == "true" ]]; then
                echo "Tunnelblick: Enabled"
            elif [[ "$auto_connect" == "0" ]] || [[ "$auto_connect" == "false" ]]; then
                echo "Tunnelblick: Disabled"
            else
                echo "Tunnelblick: Unknown"
            fi
        else
            echo "Tunnelblick: Unknown"
        fi
    fi
}

# Function to check Sophos Connect
check_sophos_connect() {
    local app_path="/Applications/Sophos Connect.app"

    if [[ -d "$app_path" ]]; then
        # Sophos Connect configuration
        echo "Sophos Connect: Unknown"
    fi
}

# Function to check SonicWall NetExtender
check_sonicwall() {
    local app_path="/Applications/SonicWall NetExtender.app"

    if [[ -d "$app_path" ]]; then
        echo "SonicWall NetExtender: Unknown"
    fi
}

# Function to check Check Point VPN
check_checkpoint() {
    local app_path="/Applications/CheckPoint VPN.app"
    local alt_app_path="/Applications/Check Point Capsule VPN.app"

    if [[ -d "$app_path" ]] || [[ -d "$alt_app_path" ]]; then
        echo "Check Point VPN: Unknown"
    fi
}

# Function to check Cloudflare WARP
check_cloudflare_warp() {
    local app_path="/Applications/Cloudflare WARP.app"

    if [[ -d "$app_path" ]]; then
        local pref_file="$HOME/Library/Preferences/com.cloudflare.1dot1dot1dot1.macos.plist"

        if [[ -f "$pref_file" ]]; then
            local auto_connect
            auto_connect=$(defaults read com.cloudflare.1dot1dot1dot1.macos autoConnect 2>/dev/null)

            if [[ "$auto_connect" == "1" ]] || [[ "$auto_connect" == "true" ]]; then
                echo "Cloudflare WARP: Enabled"
            elif [[ "$auto_connect" == "0" ]] || [[ "$auto_connect" == "false" ]]; then
                echo "Cloudflare WARP: Disabled"
            else
                echo "Cloudflare WARP: Unknown"
            fi
        else
            echo "Cloudflare WARP: Unknown"
        fi
    fi
}

# Main logic
main() {
    local vpn_statuses=()
    local result

    # Check all VPN clients
    local cisco_status
    cisco_status=$(check_cisco_anyconnect)
    [[ -n "$cisco_status" ]] && vpn_statuses+=("$cisco_status")

    local gp_status
    gp_status=$(check_globalprotect)
    [[ -n "$gp_status" ]] && vpn_statuses+=("$gp_status")

    local forti_status
    forti_status=$(check_forticlient)
    [[ -n "$forti_status" ]] && vpn_statuses+=("$forti_status")

    local zscaler_status
    zscaler_status=$(check_zscaler)
    [[ -n "$zscaler_status" ]] && vpn_statuses+=("$zscaler_status")

    local pulse_status
    pulse_status=$(check_pulse_secure)
    [[ -n "$pulse_status" ]] && vpn_statuses+=("$pulse_status")

    local tunnelblick_status
    tunnelblick_status=$(check_tunnelblick)
    [[ -n "$tunnelblick_status" ]] && vpn_statuses+=("$tunnelblick_status")

    local sophos_status
    sophos_status=$(check_sophos_connect)
    [[ -n "$sophos_status" ]] && vpn_statuses+=("$sophos_status")

    local sonicwall_status
    sonicwall_status=$(check_sonicwall)
    [[ -n "$sonicwall_status" ]] && vpn_statuses+=("$sonicwall_status")

    local checkpoint_status
    checkpoint_status=$(check_checkpoint)
    [[ -n "$checkpoint_status" ]] && vpn_statuses+=("$checkpoint_status")

    local warp_status
    warp_status=$(check_cloudflare_warp)
    [[ -n "$warp_status" ]] && vpn_statuses+=("$warp_status")

    # Format output
    if [[ ${#vpn_statuses[@]} -eq 0 ]]; then
        result="Not Installed"
    else
        # Join array elements with ", "
        result=$(printf "%s, " "${vpn_statuses[@]}")
        result="${result%, }"  # Remove trailing comma and space
    fi

    # Output in Jamf-compatible format
    echo "<result>$result</result>"
}

# Execute main function
main

exit 0
