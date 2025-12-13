#!/bin/bash

###
### Jamf Extension Attribute: Orphaned Home Directory Detector
###
### Description:
###   Identifies home directories in /Users/ that no longer have corresponding
###   user accounts. Helps administrators locate and reclaim disk space from
###   deleted or reassigned accounts.
###
### Requirements:
###   - macOS with standard /Users/ directory structure
###   - Read permissions for /Users/
###
### Output:
###   - "None" - No orphaned directories found
###   - "username1, username2, ..." - Comma-separated list of orphaned directories
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2025-12-13
### Version: 1.0.0
###

# Directories to exclude from checking
EXCLUDE_DIRS=("Shared" "Guest" ".localized")

# Function to check if a user account exists
user_exists() {
    local username="$1"

    # Use id command to check if user exists
    # Redirect stderr to /dev/null to suppress "no such user" messages
    if id -u "$username" &>/dev/null; then
        return 0  # User exists
    else
        return 1  # User does not exist
    fi
}

# Function to check if directory should be excluded
should_exclude() {
    local dirname="$1"

    for exclude in "${EXCLUDE_DIRS[@]}"; do
        if [[ "$dirname" == "$exclude" ]]; then
            return 0  # Should be excluded
        fi
    done

    # Exclude hidden directories (starting with .)
    if [[ "$dirname" == .* ]]; then
        return 0  # Should be excluded
    fi

    return 1  # Should not be excluded
}

# Main logic
main() {
    local users_dir="/Users"
    local orphaned_dirs=()

    # Check if /Users directory exists
    if [[ ! -d "$users_dir" ]]; then
        echo "<result>Error: /Users directory not found</result>"
        exit 1
    fi

    # Loop through directories in /Users
    while IFS= read -r user_dir; do
        # Get just the directory name
        local dirname
        dirname=$(basename "$user_dir")

        # Skip if directory should be excluded
        if should_exclude "$dirname"; then
            continue
        fi

        # Check if user account exists
        if ! user_exists "$dirname"; then
            orphaned_dirs+=("$dirname")
        fi
    done < <(find "$users_dir" -mindepth 1 -maxdepth 1 -type d)

    # Prepare output
    if [[ ${#orphaned_dirs[@]} -eq 0 ]]; then
        echo "<result>None</result>"
    else
        # Sort alphabetically and join with comma-space
        local sorted_dirs
        IFS=$'\n' sorted_dirs=($(sort <<<"${orphaned_dirs[*]}"))
        unset IFS

        # Join array elements with ", "
        local result
        result=$(printf "%s, " "${sorted_dirs[@]}")
        result="${result%, }"  # Remove trailing comma and space

        echo "<result>$result</result>"
    fi
}

# Execute main function
main

exit 0
