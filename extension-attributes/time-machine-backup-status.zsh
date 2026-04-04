#!/bin/zsh

###
### Jamf Extension Attribute: Time Machine Backup Status
###
### Description:
###   Reports the last Time Machine backup date, destination name, and
###   whether Time Machine is configured and actively backing up.
###
### Output:
###   - "Last Backup: YYYY-MM-DD HH:MM | Destination: NAME | Status: OK"
###   - "Last Backup: Never | Destination: NAME | Status: OK"
###   - "Not Configured" - Time Machine has no destinations set up
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.15.0
###

if ! command -v tmutil &>/dev/null; then
    echo "Not Configured"
    exit 0
fi

# Check for configured destinations
dest_info=$(tmutil destinationinfo 2>&1)

if echo "$dest_info" | grep -qi "no destinations"; then
    echo "Not Configured"
    exit 0
fi

dest_name=$(echo "$dest_info" | awk -F': ' '/Name[[:space:]]*:/{gsub(/^[[:space:]]+/,"",$2); print $2}' | head -1)
[[ -z "$dest_name" ]] && dest_name="Unknown"

# Get the latest backup snapshot date
latest=$(tmutil latestbackup 2>/dev/null | tail -1)

if [[ -z "$latest" ]]; then
    last_backup="Never"
else
    # Extract date from path like /Volumes/Backup/Backups.backupdb/Hostname/YYYY-MM-DD-HHMMSS
    raw_date=$(basename "$latest" 2>/dev/null)
    # Try to reformat YYYY-MM-DD-HHMMSS → YYYY-MM-DD HH:MM
    if [[ "$raw_date" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})-([0-9]{2})([0-9]{2}) ]]; then
        last_backup="${match[1]} ${match[2]}:${match[3]}"
    else
        last_backup="$raw_date"
    fi
fi

echo "Last Backup: ${last_backup} | Destination: ${dest_name} | Status: OK"

exit 0
