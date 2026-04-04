#!/bin/zsh

###
### Jamf Extension Attribute: Pending macOS Software Updates
###
### Description:
###   Reports the number and names of pending Apple software updates
###   by running `softwareupdate -l`.
###
### Output:
###   - "N updates pending: name1, name2, ..." - Updates available
###   - "0 updates pending"                    - No updates available
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.9.0
###

update_list=$(softwareupdate -l 2>&1)

if echo "$update_list" | grep -qi "no new software available"; then
    echo "0 updates pending"
    exit 0
fi

# Extract update titles (lines starting with "* Label:" or "* <name>")
names=()
while IFS= read -r line; do
    # softwareupdate -l marks available updates with a leading asterisk line
    if [[ "$line" =~ ^\*[[:space:]] ]]; then
        name=$(echo "$line" | sed 's/^\*[[:space:]]*//' | sed 's/-[0-9].*$//' | xargs)
        if [[ -n "$name" ]]; then
            names+=("$name")
        fi
    fi
done <<< "$update_list"

count=${#names[@]}

if [[ $count -eq 0 ]]; then
    echo "0 updates pending"
else
    joined=$(IFS=", "; echo "${names[*]}")
    echo "${count} update(s) pending: ${joined}"
fi

exit 0
