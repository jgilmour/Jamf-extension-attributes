#!/bin/zsh

###
### Jamf Extension Attribute: XProtect Version and Currency
###
### Description:
###   Reports the installed XProtect version and whether it is current
###   by comparing against the SOFA macOS data feed.
###
### Output:
###   - "Version: X | Status: Current"   - XProtect is up to date
###   - "Version: X | Status: Outdated"  - A newer version is available
###   - "Version: X | Status: Unknown"   - Could not reach SOFA feed to compare
###   - "Not Found"                      - XProtect meta plist is missing
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.7.0
###

XPROTECT_PLIST="/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Resources/XProtect.meta.plist"

if [[ ! -f "$XPROTECT_PLIST" ]]; then
    echo "Not Found"
    exit 0
fi

local_version=$(defaults read "$XPROTECT_PLIST" Version 2>/dev/null)

if [[ -z "$local_version" ]]; then
    echo "Not Found"
    exit 0
fi

# Fetch latest XProtect version from SOFA feed
sofa_json=$(curl -sf --max-time 10 "https://sofafeed.macadmins.io/v1/macos_data_feed.json" 2>/dev/null)

if [[ -z "$sofa_json" ]]; then
    echo "Version: ${local_version} | Status: Unknown"
    exit 0
fi

latest_version=$(echo "$sofa_json" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    xp = data.get('XProtectPayloads', {})
    version = xp.get('com.apple.XProtect', '')
    if not version:
        # Try alternate key
        for k, v in xp.items():
            if isinstance(v, str):
                version = v
                break
    print(version)
except Exception:
    print('')
" 2>/dev/null)

if [[ -z "$latest_version" ]]; then
    echo "Version: ${local_version} | Status: Unknown"
    exit 0
fi

if [[ "$local_version" == "$latest_version" ]]; then
    echo "Version: ${local_version} | Status: Current"
else
    echo "Version: ${local_version} | Status: Outdated"
fi

exit 0
