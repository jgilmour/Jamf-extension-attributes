#!/bin/zsh

###
### Jamf Extension Attribute: Chrome Extension Audit (All Profiles)
###
### Description:
###   Lists all installed Chrome extensions across all user profiles
###   on the device, deduplicated by extension ID.
###
### Output:
###   - Newline-delimited "ExtensionName (ID)" for all extensions found
###   - "Chrome Not Installed" - Google Chrome is not present
###   - "No Extensions Found" - Chrome installed but no extensions
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 1.9.0
###

chrome_base="/Applications/Google Chrome.app"

if [[ ! -d "$chrome_base" ]]; then
    echo "Chrome Not Installed"
    exit 0
fi

typeset -A seen_ids
results=()

for user_home in /Users/*/; do
    [[ -d "$user_home" ]] || continue
    chrome_profile_base="${user_home}Library/Application Support/Google/Chrome"
    [[ -d "$chrome_profile_base" ]] || continue

    for profile_dir in "$chrome_profile_base"/*/; do
        [[ -d "${profile_dir}Extensions" ]] || continue

        for ext_dir in "${profile_dir}Extensions"/*/; do
            ext_id=$(basename "$ext_dir")
            [[ -n "${seen_ids[$ext_id]}" ]] && continue

            manifest=$(find "$ext_dir" -maxdepth 2 -name "manifest.json" 2>/dev/null | head -1)
            [[ -z "$manifest" ]] && continue

            ext_name=$(/usr/bin/python3 - "$manifest" <<'PYEOF' 2>/dev/null
import json, sys
path = sys.argv[1]
try:
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        data = json.load(f)
    name = data.get('name', '')
    if not name or name.startswith('__MSG_'):
        sys.exit(0)
    if data.get('theme') is not None:
        sys.exit(0)
    print(name)
except Exception:
    sys.exit(0)
PYEOF
)

            [[ -z "$ext_name" ]] && continue

            seen_ids[$ext_id]=1
            results+=("${ext_name} (${ext_id})")
        done
    done
done

if [[ "${#results[@]}" -eq 0 ]]; then
    echo "No Extensions Found"
else
    printf '%s\n' "${results[@]}" | sort -u
fi

exit 0
