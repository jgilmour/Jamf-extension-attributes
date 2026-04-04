#!/bin/bash

###
### Jamf Extension Attribute: Slow Charging Detection (Wattage Mismatch)
###
### Description:
###   Detects when a Mac is charging with an underpowered adapter that may
###   cause performance issues or battery drain during use. Alerts when users
###   are using USB-C hubs, phone chargers, or other low-wattage adapters.
###
### Requirements:
###   - macOS with system_profiler command
###   - USB-C capable Mac (for power adapter detection)
###
### Output:
###   - "Normal" - Adequate charging wattage or not charging
###   - "Low Wattage Detected (XXW)" - Charging below threshold
###   - "Not Charging" - Device not connected to power
###   - "Unable to Detect" - Cannot determine wattage
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2025-12-13
### Version: 1.0.0
###

# Configurable wattage threshold (watts)
# Typical MacBook chargers: 30W (MacBook Air), 61W-67W (MacBook Pro 13"), 96W-140W (MacBook Pro 14"/16")
WATTAGE_THRESHOLD=45

# Function to get power information
get_power_info() {
    system_profiler SPPowerDataType 2>/dev/null
}

# Function to extract charging status
get_charging_status() {
    local power_info="$1"

    # Check if connected to AC power
    echo "$power_info" | grep -i "Connected:" | head -n 1 | awk '{print $2}'
}

# Function to extract charger wattage
get_charger_wattage() {
    local power_info="$1"

    # Look for "Wattage (W):" in the power data
    # This appears in the AC Charger Information section
    local wattage
    wattage=$(echo "$power_info" | grep -i "Wattage (W):" | head -n 1 | awk '{print $3}' | sed 's/W$//')

    echo "$wattage"
}

# Main logic
main() {
    local power_info
    local charging_status
    local wattage
    local result

    # Get power information
    power_info=$(get_power_info)

    if [[ -z "$power_info" ]]; then
        echo "<result>Unable to Detect</result>"
        exit 0
    fi

    # Get charging status
    charging_status=$(get_charging_status "$power_info")

    # Check if connected to power
    if [[ "$charging_status" != "Yes" ]]; then
        echo "<result>Not Charging</result>"
        exit 0
    fi

    # Get charger wattage
    wattage=$(get_charger_wattage "$power_info")

    # Validate wattage is a number
    if [[ -z "$wattage" ]] || ! [[ "$wattage" =~ ^[0-9]+$ ]]; then
        echo "<result>Unable to Detect</result>"
        exit 0
    fi

    # Compare wattage against threshold
    if [[ "$wattage" -lt "$WATTAGE_THRESHOLD" ]]; then
        result="Low Wattage Detected (${wattage}W)"
    else
        result="Normal"
    fi

    # Output in Jamf-compatible format
    echo "<result>$result</result>"
}

# Execute main function
main

exit 0
