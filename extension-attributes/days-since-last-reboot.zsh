#!/bin/zsh

###
### Jamf Extension Attribute: Days Since Last Reboot
###
### Description:
###   Returns the number of whole days since the last system boot.
###   Returns a plain integer suitable for smart group numeric comparisons.
###
### Output:
###   - Integer (e.g. "14") - days since last boot
###   - "Unknown" - if boot time cannot be determined
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 1.6.0
###

# Get raw output from sysctl
boot_time_raw=$(sysctl -n kern.boottime 2>/dev/null)

# kern.boottime returns something like: { sec = 1711234567, usec = 123456 } ...
# Extract the sec= value
boot_epoch=$(echo "$boot_time_raw" | grep -oE 'sec = [0-9]+' | awk '{print $3}')

if [[ -z "$boot_epoch" || ! "$boot_epoch" =~ ^[0-9]+$ ]]; then
    echo "Unknown"
    exit 0
fi

now_epoch=$(date +%s)
elapsed=$(( now_epoch - boot_epoch ))

# Sanity check: elapsed should be positive and less than ~10 years
if [[ "$elapsed" -lt 0 || "$elapsed" -gt 315360000 ]]; then
    echo "Unknown"
    exit 0
fi

days=$(( elapsed / 86400 ))
echo "$days"
exit 0
