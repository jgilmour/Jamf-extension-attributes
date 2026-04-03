#!/bin/zsh

###
### Jamf Extension Attribute: Local Admin Account Audit
###
### Description:
###   Returns a comma-separated list of unexpected local admin accounts,
###   or "Clean" if only expected accounts have admin privileges.
###
### Output:
###   - "Clean" - Only expected accounts have admin privileges
###   - "rogue_user, tempaccount" - Comma-separated unexpected admins
###   - "No Admin Group Found" - admin group could not be read
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 1.7.0
###

# Define allowlisted admin accounts (edit to match your environment)
EXPECTED_ADMINS=("root" "managedadmin" "admin" "jamfadmin")

# Get admin group members
admin_group_output=$(dscl . -read /Groups/admin GroupMembership 2>/dev/null)

if [[ -z "$admin_group_output" ]]; then
    echo "No Admin Group Found"
    exit 0
fi

# Parse members — output format: "GroupMembership: root admin user1 user2"
members_raw=$(echo "$admin_group_output" | sed 's/^GroupMembership: //')
members=("${(@s/ /)members_raw}")

unexpected=()

for member in "${members[@]}"; do
    [[ -z "$member" ]] && continue

    # Skip system accounts (UID < 500)
    uid=$(dscl . -read /Users/"$member" UniqueID 2>/dev/null | awk '{print $2}')
    if [[ -n "$uid" && "$uid" =~ ^[0-9]+$ && "$uid" -lt 500 ]]; then
        continue
    fi

    # Check if account actually exists in dscl
    dscl . -read /Users/"$member" &>/dev/null || continue

    # Check against allowlist
    allowed=0
    for expected in "${EXPECTED_ADMINS[@]}"; do
        if [[ "$member" == "$expected" ]]; then
            allowed=1
            break
        fi
    done

    if [[ "$allowed" -eq 0 ]]; then
        unexpected+=("$member")
    fi
done

if [[ "${#unexpected[@]}" -eq 0 ]]; then
    echo "Clean"
else
    echo "${(j:, :)unexpected}"
fi

exit 0
