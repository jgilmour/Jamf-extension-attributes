#!/bin/zsh

###
### Jamf Extension Attribute: FileVault SecureToken Status
###
### Description:
###   Lists local user accounts with their SecureToken status.
###   SecureToken is required for FileVault enablement/recovery on Apple Silicon.
###
### Output:
###   - "admin: Enabled | jsmith: Disabled" - pipe-delimited per-user status
###   - "FileVault Not Enabled"              - FileVault is not active on the volume
###   - "No Local Users Found"               - no local accounts (UID >= 500) found
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.1.0
###

# Check if FileVault is enabled
fv_status=$(fdesetup status 2>/dev/null)
if ! echo "$fv_status" | grep -q "FileVault is On"; then
    echo "FileVault Not Enabled"
    exit 0
fi

# Get local human user accounts (UID >= 500, not service accounts starting with _)
user_statuses=()

while IFS= read -r username; do
    [[ -z "$username" ]] && continue
    [[ "$username" == "_"* ]] && continue

    # Get UID
    uid=$(dscl . -read /Users/"$username" UniqueID 2>/dev/null | awk '{print $2}')
    [[ -z "$uid" ]] && continue
    [[ ! "$uid" =~ ^[0-9]+$ ]] && continue
    (( uid < 500 )) && continue

    # Check SecureToken status
    token_output=$(sysadminctl -secureTokenStatus "$username" 2>&1)
    if echo "$token_output" | grep -qi "ENABLED"; then
        user_statuses+=("${username}: Enabled")
    elif echo "$token_output" | grep -qi "DISABLED"; then
        user_statuses+=("${username}: Disabled")
    else
        user_statuses+=("${username}: Unknown")
    fi
done < <(dscl . -list /Users 2>/dev/null)

if [[ "${#user_statuses[@]}" -eq 0 ]]; then
    echo "No Local Users Found"
else
    echo "${(j: | :)user_statuses}"
fi

exit 0
