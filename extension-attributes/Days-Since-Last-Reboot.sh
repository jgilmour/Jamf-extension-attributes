#!/bin/zsh

###
### Jamf Extension Attribute: Days Since Last Reboot
###
### Description:
###   Reports the number of complete days since the Mac last rebooted,
###   calculated from the kernel boot time via sysctl kern.boottime.
###
### Output:
###   - Integer number of days since last reboot (e.g., "3")
###   - "0" if rebooted today or calculation fails
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 1.0.0
###

# Get boot time as epoch seconds from sysctl
# kern.boottime returns: { sec = 1700000000, usec = 123456 } Sat Nov 14 ...
boot_epoch=$(sysctl -n kern.boottime 2>/dev/null | awk -F'[=,]' '{print $2}' | tr -d ' ')

if [[ -z "$boot_epoch" || ! "$boot_epoch" =~ ^[0-9]+$ ]]; then
    echo "<result>0</result>"
    exit 0
fi

now_epoch=$(date +%s)
seconds_up=$(( now_epoch - boot_epoch ))
days_up=$(( seconds_up / 86400 ))

# Ensure non-negative
if [[ "$days_up" -lt 0 ]]; then
    days_up=0
fi

echo "<result>${days_up}</result>"
exit 0
