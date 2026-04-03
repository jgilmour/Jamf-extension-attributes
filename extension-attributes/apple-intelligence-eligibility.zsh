#!/bin/zsh

###
### Jamf Extension Attribute: Apple Intelligence Eligibility and Status
###
### Description:
###   Checks whether the device is eligible for Apple Intelligence and,
###   if so, whether it has been enabled at the user level.
###
### Output:
###   - "Eligible: Yes | Enabled: Yes"
###   - "Eligible: Yes | Enabled: No"
###   - "Eligible: No | Reason: Intel Mac"
###   - "Eligible: No | Reason: macOS below 15.1"
###   - "Eligible: No | Reason: MDM Restricted"
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.4.0
###

# Must be Apple Silicon
arch=$(uname -m)
if [[ "$arch" != "arm64" ]]; then
    echo "Eligible: No | Reason: Intel Mac"
    exit 0
fi

# Must be macOS 15.1+
os_version=$(sw_vers -productVersion)
os_major=$(echo "$os_version" | cut -d. -f1)
os_minor=$(echo "$os_version" | cut -d. -f2)

if (( os_major < 15 )) || { (( os_major == 15 )) && (( os_minor < 1 )); }; then
    echo "Eligible: No | Reason: macOS below 15.1"
    exit 0
fi

# Check MDM restriction — Jamf/MDM can restrict AI features via applicationaccess
ai_restricted=0
restrict_output=$(defaults read /Library/Preferences/com.apple.applicationaccess 2>/dev/null)
if echo "$restrict_output" | grep -qE 'allowAppleIntelligence\s*=\s*0|allowWritingTools\s*=\s*0'; then
    ai_restricted=1
fi

if [[ "$ai_restricted" -eq 1 ]]; then
    echo "Eligible: No | Reason: MDM Restricted"
    exit 0
fi

# Check user-level enablement
# The preference is stored in the user's domain - run as the console user
console_user=$(stat -f "%Su" /dev/console 2>/dev/null)
enabled="No"

if [[ -n "$console_user" && "$console_user" != "root" ]]; then
    user_home=$(dscl . -read /Users/"$console_user" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
    pref_file="${user_home}/Library/Preferences/com.apple.CloudSubscriptionFeatures.plist"
    if [[ -f "$pref_file" ]]; then
        opt_in=$(defaults read "$pref_file" "optIn" 2>/dev/null)
        if [[ "$opt_in" == "1" ]]; then
            enabled="Yes"
        fi
    fi
fi

echo "Eligible: Yes | Enabled: ${enabled}"
exit 0
