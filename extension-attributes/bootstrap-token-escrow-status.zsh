#!/bin/zsh

###
### Jamf Extension Attribute: Bootstrap Token Escrow Status
###
### Description:
###   Returns whether a Bootstrap Token has been escrowed to the MDM server.
###   Bootstrap Token requires macOS 10.15+ on Intel or any version on Apple Silicon.
###   On older Intel Macs, returns "Not Supported".
###
### Output:
###   - "Escrowed"      - Bootstrap Token has been escrowed to the MDM server
###   - "Not Escrowed"  - Device supports Bootstrap Token but it is not escrowed
###   - "Not Supported" - Intel Mac on macOS < 10.15, or hardware does not support it
###   - "Unknown"       - profiles command unavailable or output unrecognised
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.6.0
###

arch=$(uname -m)
os_version=$(sw_vers -productVersion)
os_major=$(echo "$os_version" | awk -F. '{print $1}')
os_minor=$(echo "$os_version" | awk -F. '{print $2}')

# Bootstrap Token requires macOS 10.15+ on Intel Macs
if [[ "$arch" != "arm64" ]]; then
    if [[ "$os_major" -lt 10 ]] || { [[ "$os_major" -eq 10 ]] && [[ "$os_minor" -lt 15 ]]; }; then
        echo "Not Supported"
        exit 0
    fi
fi

if ! command -v profiles &>/dev/null; then
    echo "Unknown"
    exit 0
fi

profiles_output=$(profiles status -type bootstraptoken 2>&1)

if echo "$profiles_output" | grep -qi "Bootstrap Token escrowed to server: YES"; then
    echo "Escrowed"
elif echo "$profiles_output" | grep -qi "Bootstrap Token escrowed to server: NO"; then
    echo "Not Escrowed"
elif echo "$profiles_output" | grep -qi "Bootstrap Token supported: NO"; then
    echo "Not Supported"
else
    echo "Unknown"
fi

exit 0
