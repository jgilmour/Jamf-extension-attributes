#!/bin/zsh

###
### Jamf Extension Attribute: Bootstrap Token Escrow Status
###
### Description:
###   Reports whether the device's Bootstrap Token has been escrowed
###   with the MDM server. Uses `profiles status -type bootstraptoken`.
###
### Output:
###   - "Escrowed"       - Bootstrap Token has been escrowed with MDM
###   - "Not Escrowed"   - Token exists but has not been sent to MDM
###   - "Not Supported"  - Device or macOS version does not support Bootstrap Token
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.6.0
###

if ! command -v profiles &>/dev/null; then
    echo "Not Supported"
    exit 0
fi

result=$(profiles status -type bootstraptoken 2>&1)

if echo "$result" | grep -qi "escrowed to server: YES"; then
    echo "Escrowed"
elif echo "$result" | grep -qi "escrowed to server: NO"; then
    echo "Not Escrowed"
elif echo "$result" | grep -qi "not supported"; then
    echo "Not Supported"
else
    echo "Not Supported"
fi

exit 0
