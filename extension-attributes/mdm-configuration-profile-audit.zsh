#!/bin/zsh

###
### Jamf Extension Attribute: MDM Configuration Profile Audit
###
### Description:
###   Reports the total count and display names of all MDM configuration
###   profiles installed on the device using `profiles list -all`.
###
### Output:
###   - "N profiles installed: name1, name2, ..." - Profiles present
###   - "0 profiles installed"                    - No profiles found
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.12.0
###

if ! command -v profiles &>/dev/null; then
    echo "0 profiles installed"
    exit 0
fi

profile_output=$(profiles list -all 2>/dev/null)

# Profile display names appear after "attribute: profileDisplayName:" lines
names=()
while IFS= read -r line; do
    if [[ "$line" =~ "profileDisplayName:" ]]; then
        name=$(echo "$line" | sed 's/.*profileDisplayName:[[:space:]]*//' | xargs)
        if [[ -n "$name" ]]; then
            names+=("$name")
        fi
    fi
done <<< "$profile_output"

count=${#names[@]}

if [[ $count -eq 0 ]]; then
    echo "0 profiles installed"
else
    joined=$(IFS=", "; echo "${names[*]}")
    echo "${count} profile(s) installed: ${joined}"
fi

exit 0
