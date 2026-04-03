#!/bin/zsh

###
### Jamf Extension Attribute: Secure Boot Policy
###
### Description:
###   Reports the current Secure Boot security policy on Apple Silicon and
###   Intel T2 Macs. On Intel Macs without a T2, returns "N/A (Intel Mac)".
###
### Output (Apple Silicon):
###   - "Full Security" - Default; only allows booting Apple-signed, current macOS
###   - "Reduced Security" - Allows older macOS or third-party kernel extensions
###   - "Permissive Security" - Minimal restrictions; all kernel extensions allowed
###   - "Unknown" - bputil returned unexpected output
###
### Output (Intel):
###   - "Full Security (Intel T2)" - T2 Mac with Full security
###   - "Medium Security (Intel T2)" - T2 Mac with Medium security
###   - "No Security (Intel T2)" - T2 Mac with security disabled
###   - "N/A (Intel Mac, No T2)" - Intel Mac without T2 security chip
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.5.0
###

arch=$(uname -m)

if [[ "$arch" != "arm64" ]]; then
    # Intel Mac — check for T2 chip via system_profiler
    t2_present=$(system_profiler SPiBridgeDataType 2>/dev/null | grep -i "Apple T2")
    if [[ -z "$t2_present" ]]; then
        echo "N/A (Intel Mac, No T2)"
        exit 0
    fi

    # T2 Mac — bputil is available on T2 Macs running macOS 11+
    if ! command -v bputil &>/dev/null; then
        echo "N/A (Intel T2, bputil unavailable)"
        exit 0
    fi

    bputil_output=$(bputil -d 2>/dev/null)
    if echo "$bputil_output" | grep -qi "full security"; then
        echo "Full Security (Intel T2)"
    elif echo "$bputil_output" | grep -qi "medium security"; then
        echo "Medium Security (Intel T2)"
    elif echo "$bputil_output" | grep -qi "no security"; then
        echo "No Security (Intel T2)"
    else
        echo "Unknown (Intel T2)"
    fi
    exit 0
fi

# Apple Silicon — bputil is always available
if ! command -v bputil &>/dev/null; then
    echo "Unknown (bputil unavailable)"
    exit 0
fi

bputil_output=$(bputil -d 2>/dev/null)

if echo "$bputil_output" | grep -qi "full security"; then
    echo "Full Security"
elif echo "$bputil_output" | grep -qi "reduced security"; then
    echo "Reduced Security"
elif echo "$bputil_output" | grep -qi "permissive security"; then
    echo "Permissive Security"
else
    echo "Unknown"
fi

exit 0
