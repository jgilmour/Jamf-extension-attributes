#!/bin/zsh

###
### Jamf Extension Attribute: TCC Full Disk Access Apps
###
### Description:
###   Lists applications that have been granted Full Disk Access
###   (kTCCServiceSystemPolicyAllFiles) by querying the system TCC database.
###
### Output:
###   - Comma-separated list of bundle identifiers or app paths granted FDA
###   - "None Granted" if no apps have Full Disk Access
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.11.0
###

TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"

if [[ ! -f "$TCC_DB" ]]; then
    echo "None Granted"
    exit 0
fi

# auth_value=2 means "allowed" in TCC
apps=$(sqlite3 "$TCC_DB" \
    "SELECT client FROM access WHERE service='kTCCServiceSystemPolicyAllFiles' AND auth_value=2;" \
    2>/dev/null | sort -u)

if [[ -z "$apps" ]]; then
    echo "None Granted"
else
    # Join newlines into comma-separated list
    echo "$apps" | paste -sd ", " -
fi

exit 0
