#!/bin/bash

###
### Jamf Extension Attribute: Default Web Browser
###
### Description:
###   Identifies which web browser is set as the default system-wide handler
###   for HTTP/HTTPS URLs. Useful for application compatibility planning,
###   security policy enforcement, and software standardization tracking.
###
### Requirements:
###   - macOS with LaunchServices framework
###   - Python 3 (built into macOS)
###
### Output:
###   - "Safari" - Apple Safari browser
###   - "Chrome" - Google Chrome
###   - "Firefox" - Mozilla Firefox
###   - "Edge" - Microsoft Edge
###   - "Brave" - Brave Browser
###   - "Arc" - Arc Browser
###   - "[BrowserName]" - Other recognized browsers
###   - "Unknown" - Unrecognized browser or no default set
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2025-12-13
### Version: 1.0.0
###

# Function to convert bundle ID to browser name
bundle_id_to_name() {
    local bundle_id="$1"

    case "$bundle_id" in
        com.apple.Safari)
            echo "Safari"
            ;;
        com.google.Chrome)
            echo "Chrome"
            ;;
        org.mozilla.firefox)
            echo "Firefox"
            ;;
        com.microsoft.edgemac)
            echo "Edge"
            ;;
        com.brave.Browser)
            echo "Brave"
            ;;
        company.thebrowser.Browser)
            echo "Arc"
            ;;
        com.operasoftware.Opera)
            echo "Opera"
            ;;
        com.vivaldi.Vivaldi)
            echo "Vivaldi"
            ;;
        org.chromium.Chromium)
            echo "Chromium"
            ;;
        com.apple.Safari.Technology.Preview)
            echo "Safari Technology Preview"
            ;;
        com.google.Chrome.canary)
            echo "Chrome Canary"
            ;;
        org.mozilla.firefoxdeveloperedition)
            echo "Firefox Developer Edition"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# Function to get default browser using Python (most reliable method)
get_default_browser_python() {
    local bundle_id

    # Use Python with PyObjC to query LaunchServices
    bundle_id=$(python3 -c '
import sys
try:
    from Foundation import NSWorkspace, NSURL
    workspace = NSWorkspace.sharedWorkspace()
    url = NSURL.URLWithString_("http://www.apple.com")
    app_url = workspace.URLForApplicationToOpenURL_(url)
    if app_url:
        from AppKit import NSBundle
        bundle = NSBundle.bundleWithURL_(app_url)
        if bundle:
            bundle_id = bundle.bundleIdentifier()
            if bundle_id:
                print(bundle_id)
                sys.exit(0)
except Exception:
    pass
sys.exit(1)
' 2>/dev/null)

    if [[ -n "$bundle_id" ]]; then
        echo "$bundle_id"
        return 0
    else
        return 1
    fi
}

# Function to get default browser using defaults command (fallback method)
get_default_browser_defaults() {
    local bundle_id
    local plist_file="$HOME/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"

    # Try to read from LaunchServices preferences
    if [[ -f "$plist_file" ]]; then
        bundle_id=$(/usr/libexec/PlistBuddy -c "Print :LSHandlers" "$plist_file" 2>/dev/null | \
            grep -A 4 "LSHandlerURLScheme = http" | \
            grep "LSHandlerRoleAll" | \
            awk -F' = ' '{print $2}' | \
            head -n 1)
    fi

    if [[ -n "$bundle_id" ]]; then
        echo "$bundle_id"
        return 0
    else
        return 1
    fi
}

# Main logic
main() {
    local bundle_id
    local browser_name
    local result

    # Try Python method first (most reliable)
    bundle_id=$(get_default_browser_python)

    # If Python method fails, try defaults command
    if [[ -z "$bundle_id" ]]; then
        bundle_id=$(get_default_browser_defaults)
    fi

    # Convert bundle ID to browser name
    if [[ -n "$bundle_id" ]]; then
        browser_name=$(bundle_id_to_name "$bundle_id")
        result="$browser_name"
    else
        result="Unknown"
    fi

    # Output in Jamf-compatible format
    echo "<result>$result</result>"
}

# Execute main function
main

exit 0
