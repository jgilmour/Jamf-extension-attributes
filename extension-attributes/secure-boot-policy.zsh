#!/bin/zsh

###
### Jamf Extension Attribute: Secure Boot Policy Level
###
### Description:
###   Returns the Secure Boot policy level on Apple Silicon Macs.
###   Intel Macs are not applicable. Uses bputil -d to inspect the policy.
###
### Output:
###   - "Full Security"       - Highest security: only Apple-signed OS permitted
###   - "Reduced Security"    - Custom kexts or older OS versions allowed
###   - "Permissive Security" - No boot policy enforcement
###   - "Intel Mac (N/A)"     - Intel processor, Secure Boot via different mechanism
###   - "Unknown"             - bputil output unrecognised or tool unavailable
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.5.0
###

arch=$(uname -m)

if [[ "$arch" != "arm64" ]]; then
    echo "Intel Mac (N/A)"
    exit 0
fi

if ! command -v bputil &>/dev/null; then
    echo "Unknown"
    exit 0
fi

bputil_output=$(bputil -d 2>&1)

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
