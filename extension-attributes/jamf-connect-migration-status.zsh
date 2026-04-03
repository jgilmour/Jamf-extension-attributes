#!/bin/zsh

###
### Jamf Extension Attribute: Jamf Connect Migration Status
###
### Description:
###   Checks whether Jamf Connect is installed and whether the login window
###   auth chain has been configured to use it.
###
### Output:
###   - "Migrated"                   - Jamf Connect installed and in auth chain
###   - "Not Migrated"               - Jamf Connect installed but not in auth chain
###   - "Jamf Connect Not Installed" - app not found
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.3.0
###

jc_app="/Applications/Jamf Connect.app"

if [[ ! -d "$jc_app" ]]; then
    echo "Jamf Connect Not Installed"
    exit 0
fi

# Try authchanger in common locations
authchanger=""
for path in /usr/local/bin/authchanger /usr/bin/authchanger; do
    if [[ -x "$path" ]]; then
        authchanger="$path"
        break
    fi
done

if [[ -z "$authchanger" ]]; then
    echo "Not Migrated"
    exit 0
fi

auth_output=$("$authchanger" -print 2>&1)

if echo "$auth_output" | grep -qi "JamfConnect"; then
    echo "Migrated"
else
    echo "Not Migrated"
fi

exit 0
