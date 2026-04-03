#!/bin/zsh

###
### Jamf Extension Attribute: XProtect Version and Currency
###
### Description:
###   Reports the locally installed XProtect version and compares it against
###   the latest published version from the SOFA feed to determine currency.
###
### Output:
###   - "Version: 5267 | Status: Current"
###   - "Version: 5267 | Status: Outdated (Latest: 5280)"
###   - "Version: 5267 | Status: Unknown (No Internet)"
###   - "XProtect Not Found"
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.7.0
###

xprotect_plist="/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Resources/XProtect.meta.plist"

if [[ ! -f "$xprotect_plist" ]]; then
    echo "XProtect Not Found"
    exit 0
fi

local_version=$(/usr/libexec/PlistBuddy -c "Print :XProtectVersion" "$xprotect_plist" 2>/dev/null)
if [[ -z "$local_version" ]]; then
    local_version=$(defaults read "$xprotect_plist" XProtectVersion 2>/dev/null)
fi

if [[ -z "$local_version" ]]; then
    echo "XProtect Not Found"
    exit 0
fi

# Fetch latest version from SOFA feed with short timeout
sofa_url="https://sofafeed.macadmins.io/v1/xprotect_data.json"
sofa_response=$(curl -sf --max-time 5 "$sofa_url" 2>/dev/null)

if [[ -z "$sofa_response" ]]; then
    echo "Version: ${local_version} | Status: Unknown (No Internet)"
    exit 0
fi

# Extract latest XProtect version from SOFA JSON
latest_version=$(echo "$sofa_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # SOFA feed: XProtectPayloads contains bundle-id -> version mappings
    payloads = data.get('XProtectPayloads', {})
    version = payloads.get('com.apple.XProtect', '')
    if version:
        print(version)
        sys.exit(0)
    # Fallback: XProtectPlistConfigData
    config = data.get('XProtectPlistConfigData', {})
    version = config.get('com.apple.XProtect', '')
    if version:
        print(version)
except Exception:
    pass
" 2>/dev/null)

if [[ -z "$latest_version" ]]; then
    echo "Version: ${local_version} | Status: Unknown (Feed Parse Error)"
    exit 0
fi

if [[ "$local_version" == "$latest_version" ]]; then
    echo "Version: ${local_version} | Status: Current"
else
    echo "Version: ${local_version} | Status: Outdated (Latest: ${latest_version})"
fi

exit 0
