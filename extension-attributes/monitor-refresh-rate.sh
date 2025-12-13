#!/bin/bash

###
### Jamf Extension Attribute: Current Monitor Refresh Rate
###
### Description:
###   Reports the current refresh rate of the main display. Helps ensure
###   ProMotion-capable MacBook Pros (120Hz) aren't accidentally locked to
###   60Hz, and that external displays are running at optimal settings.
###
### Requirements:
###   - macOS with system_profiler command
###   - Display connected
###
### Output:
###   - "120 Hertz" - ProMotion/high refresh rate active
###   - "60 Hertz" - Standard refresh rate
###   - "XX Hertz" - Other refresh rate detected
###   - "Unable to Detect" - Cannot determine refresh rate
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2025-12-13
### Version: 1.0.0
###

# Function to get display information
get_display_info() {
    system_profiler SPDisplaysDataType 2>/dev/null
}

# Function to extract refresh rate from display info
get_refresh_rate() {
    local display_info="$1"
    local refresh_rate

    # Look for "Refresh Rate" or "UI Looks like" which contains refresh rate info
    # Format is typically: "Refresh Rate: 120 Hz" or similar
    refresh_rate=$(echo "$display_info" | grep -i "refresh rate:" | head -n 1 | awk -F': ' '{print $2}' | awk '{print $1}')

    # Alternative: Check for refresh rate in resolution string
    # Some displays show it as part of the resolution like "@ 120 Hz"
    if [[ -z "$refresh_rate" ]]; then
        refresh_rate=$(echo "$display_info" | grep -i "@ [0-9]* Hz" | head -n 1 | grep -oE "[0-9]+ Hz" | awk '{print $1}')
    fi

    # Alternative: Check for "Framebuffer Depth" section which may contain refresh info
    if [[ -z "$refresh_rate" ]]; then
        refresh_rate=$(echo "$display_info" | grep -A 10 "Resolution:" | grep -i "hz" | head -n 1 | grep -oE "[0-9]+" | head -n 1)
    fi

    echo "$refresh_rate"
}

# Main logic
main() {
    local display_info
    local refresh_rate
    local result

    # Get display information
    display_info=$(get_display_info)

    if [[ -z "$display_info" ]]; then
        echo "<result>Unable to Detect</result>"
        exit 0
    fi

    # Get refresh rate
    refresh_rate=$(get_refresh_rate "$display_info")

    # Validate refresh rate is a number
    if [[ -z "$refresh_rate" ]] || ! [[ "$refresh_rate" =~ ^[0-9]+$ ]]; then
        echo "<result>Unable to Detect</result>"
        exit 0
    fi

    # Format output
    result="${refresh_rate} Hertz"

    # Output in Jamf-compatible format
    echo "<result>$result</result>"
}

# Execute main function
main

exit 0
