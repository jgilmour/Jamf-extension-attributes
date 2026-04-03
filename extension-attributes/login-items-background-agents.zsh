#!/bin/zsh

###
### Jamf Extension Attribute: Login Items / Background Launch Agents (macOS 13+)
###
### Description:
###   Lists non-Apple background login items. On macOS 13+ uses sfltool dumpbtm.
###   On macOS 12 and earlier falls back to scanning LaunchAgents directories.
###
### Output:
###   - Newline-delimited list of non-Apple background items
###   - "None Found"                             - no non-Apple items detected
###   - "macOS 12 or earlier - Legacy scan"      - fallback used, list appended
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.2.0
###

os_major=$(sw_vers -productVersion | cut -d. -f1)

results=()

if (( os_major >= 13 )); then
    # macOS 13+ — use Background Task Manager
    if ! command -v sfltool &>/dev/null; then
        echo "sfltool not available"
        exit 0
    fi

    btm_output=$(sfltool dumpbtm 2>/dev/null)
    if [[ -z "$btm_output" ]]; then
        echo "None Found"
        exit 0
    fi

    # Each entry block contains lines like:
    #   name       : Some App
    #   url        : file:///Applications/SomeApp.app/...
    #   bundle-id  : com.company.someapp
    # Filter out Apple bundle IDs (com.apple.*)
    while IFS= read -r line; do
        if [[ "$line" =~ "bundle-id" ]]; then
            bundle_id=$(echo "$line" | awk -F': ' '{print $2}' | xargs)
            if [[ -n "$bundle_id" && "$bundle_id" != com.apple.* ]]; then
                results+=("$bundle_id")
            fi
        fi
    done <<< "$btm_output"

else
    # macOS 12 and earlier — scan LaunchAgents directories
    launch_agent_dirs=(
        "/Library/LaunchAgents"
        "/Library/LaunchDaemons"
    )
    for user_home in /Users/*/; do
        launch_agent_dirs+=("${user_home}Library/LaunchAgents")
    done

    for dir in "${launch_agent_dirs[@]}"; do
        [[ -d "$dir" ]] || continue
        for plist in "$dir"/*.plist; do
            [[ -f "$plist" ]] || continue
            label=$(defaults read "$plist" Label 2>/dev/null)
            [[ -z "$label" ]] && continue
            [[ "$label" == com.apple.* ]] && continue
            results+=("$label")
        done
    done

    if [[ "${#results[@]}" -eq 0 ]]; then
        echo "macOS 12 or earlier - Legacy scan: None Found"
        exit 0
    else
        echo "macOS 12 or earlier - Legacy scan:"
        printf '%s\n' "${results[@]}" | sort -u
        exit 0
    fi
fi

if [[ "${#results[@]}" -eq 0 ]]; then
    echo "None Found"
else
    printf '%s\n' "${results[@]}" | sort -u
fi

exit 0
