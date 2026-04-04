#!/bin/zsh

###
### Jamf Extension Attribute: Battery Health and Cycle Count
###
### Description:
###   Reports battery condition, cycle count, and maximum capacity percentage
###   using system_profiler SPPowerDataType. Returns a fixed string for
###   desktop Macs that have no battery.
###
### Output:
###   - "Condition: Normal | Cycle Count: N | Max Capacity: N%"
###   - "Condition: Service Recommended | Cycle Count: N | Max Capacity: N%"
###   - "Desktop Mac (No Battery)"
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.14.0
###

power_data=$(system_profiler SPPowerDataType 2>/dev/null)

# Desktop Macs report no battery information
if ! echo "$power_data" | grep -qi "cycle count"; then
    echo "Desktop Mac (No Battery)"
    exit 0
fi

condition=$(echo "$power_data" | awk -F': ' '/Condition:/{gsub(/^[[:space:]]+/,"",$2); print $2}' | head -1)
cycle_count=$(echo "$power_data" | awk -F': ' '/Cycle Count:/{gsub(/^[[:space:]]+/,"",$2); print $2}' | head -1)
max_capacity=$(echo "$power_data" | awk -F': ' '/Maximum Capacity:/{gsub(/^[[:space:]]+/,"",$2); print $2}' | head -1)

[[ -z "$condition" ]]   && condition="Unknown"
[[ -z "$cycle_count" ]] && cycle_count="Unknown"
[[ -z "$max_capacity" ]] && max_capacity="Unknown"

# Normalise Max Capacity — ensure it has a % suffix if it's a number
if [[ "$max_capacity" =~ ^[0-9]+$ ]]; then
    max_capacity="${max_capacity}%"
fi

echo "Condition: ${condition} | Cycle Count: ${cycle_count} | Max Capacity: ${max_capacity}"

exit 0
