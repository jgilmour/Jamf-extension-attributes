#!/bin/zsh

###
### Jamf Extension Attribute: Homebrew Package Audit
###
### Description:
###   Returns a newline-separated list of installed Homebrew formulae (not casks).
###   Must be run as the console user since Homebrew refuses to run as root.
###
### Output:
###   - Newline-separated list of formula names (e.g. "git\nwget\nnode")
###   - "Homebrew Not Installed" - brew binary not found
###   - "No Packages Installed"  - Homebrew installed but no formulae present
###   - "No Console User"        - No user logged in at the console
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.8.0
###

console_user=$(stat -f "%Su" /dev/console 2>/dev/null)

if [[ -z "$console_user" || "$console_user" == "root" ]]; then
    echo "No Console User"
    exit 0
fi

console_uid=$(id -u "$console_user" 2>/dev/null)

# Find brew binary — Apple Silicon uses /opt/homebrew, Intel uses /usr/local
brew_path=""
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    brew_path="/opt/homebrew/bin/brew"
elif [[ -x "/usr/local/bin/brew" ]]; then
    brew_path="/usr/local/bin/brew"
fi

if [[ -z "$brew_path" ]]; then
    echo "Homebrew Not Installed"
    exit 0
fi

# Run brew as the console user via launchctl asuser to avoid "run as root" error
packages=$(launchctl asuser "$console_uid" sudo -u "$console_user" "$brew_path" list --formula 2>/dev/null)

if [[ -z "$packages" ]]; then
    echo "No Packages Installed"
    exit 0
fi

echo "$packages"
exit 0
