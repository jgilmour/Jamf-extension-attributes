#!/bin/zsh

###
### Jamf Extension Attribute: Local User Password Age
###
### Description:
###   Reports the number of days since each local user (UID >= 500) last
###   changed their password, using dscl to read passwordLastSetTime.
###
### Output:
###   - "user1: N days | user2: N days" - Per-user password age in days
###   - "No Local Users Found"          - No standard local accounts present
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.10.0
###

now=$(date +%s)
results=()

while IFS= read -r username; do
    uid=$(dscl . -read "/Users/${username}" UniqueID 2>/dev/null | awk '{print $2}')
    [[ -z "$uid" ]] && continue
    [[ "$uid" -lt 500 ]] && continue

    # passwordLastSetTime is stored as seconds since 2001-01-01 (Apple epoch)
    raw=$(dscl . -read "/Users/${username}" passwordLastSetTime 2>/dev/null | awk '{print $2}')
    [[ -z "$raw" || "$raw" == "0" ]] && continue

    # Convert from Apple Core Data epoch (2001-01-01) to Unix epoch (1970-01-01)
    # Difference is 978307200 seconds
    apple_epoch_offset=978307200
    # raw may be a float; strip decimal
    raw_int=$(echo "$raw" | sed 's/\..*//')
    unix_ts=$(( raw_int + apple_epoch_offset ))
    age_days=$(( (now - unix_ts) / 86400 ))

    results+=("${username}: ${age_days} days")
done < <(dscl . -list /Users 2>/dev/null)

if [[ ${#results[@]} -eq 0 ]]; then
    echo "No Local Users Found"
else
    echo "${(j: | :)results}"
fi

exit 0
