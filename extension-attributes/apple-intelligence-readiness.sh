#!/bin/bash

###
### Jamf Extension Attribute: Apple Intelligence Readiness Check
###
### Description:
###   Checks if a Mac is capable of running Apple Intelligence features
###   by verifying chip type (Apple Silicon) and RAM requirements.
###
### Requirements:
###   - Apple Silicon (M1 or newer)
###   - 8GB+ Unified Memory (configurable)
###
### Output:
###   - "Ready" - Device meets all requirements
###   - "Not Supported (Intel)" - Device has Intel processor
###   - "Not Supported (Low RAM)" - Apple Silicon but insufficient RAM
###
### Author: Jamf Admin
### Created: 2025-12-13
### Version: 1.0.0
###

# Configurable RAM threshold in GB (8 or 16 recommended)
RAM_THRESHOLD_GB=8

# Function to get chip type
get_chip_type() {
    sysctl -n machdep.cpu.brand_string 2>/dev/null
}

# Function to get total RAM in GB
get_ram_gb() {
    # Get memory in bytes and convert to GB
    local mem_bytes
    mem_bytes=$(sysctl -n hw.memsize 2>/dev/null)

    if [[ -n "$mem_bytes" && "$mem_bytes" -gt 0 ]]; then
        # Convert bytes to GB (divide by 1073741824)
        echo "$((mem_bytes / 1073741824))"
    else
        echo "0"
    fi
}

# Main logic
main() {
    local chip_type
    local ram_gb
    local result

    # Get chip information
    chip_type=$(get_chip_type)

    # Check if it's Apple Silicon
    if [[ "$chip_type" =~ "Apple M" ]]; then
        # It's Apple Silicon, now check RAM
        ram_gb=$(get_ram_gb)

        if [[ "$ram_gb" -ge "$RAM_THRESHOLD_GB" ]]; then
            result="Ready"
        else
            result="Not Supported (Low RAM)"
        fi
    else
        # Intel or unrecognized processor
        result="Not Supported (Intel)"
    fi

    # Output in Jamf-compatible format
    echo "<result>$result</result>"
}

# Execute main function
main

exit 0
