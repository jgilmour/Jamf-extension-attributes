#!/bin/zsh

###
### Jamf Extension Attribute: Homebrew Package Audit
###
### Description:
###   Lists all Homebrew formulae installed for the current console user.
###   Runs `brew list --formula` as the logged-in user to enumerate packages.
###
### Output:
###   - Newline-separated list of installed formula names
###   - "Homebrew Not Installed" if Homebrew is not found for the console user
###   - "No User Logged In" if no console session is active
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.8.0
###

console_user=$(stat -f "%Su" /dev/console 2>/dev/null)

if [[ -z "$console_user" || "$console_user" == "root" ]]; then
    echo "No User Logged In"
    exit 0
fi

# Common Homebrew prefix locations
brew_bin=""
for candidate in \
    "/opt/homebrew/bin/brew" \
    "/usr/local/bin/brew" \
    "/home/linuxbrew/.linuxbrew/bin/brew"; do
    if [[ -x "$candidate" ]]; then
        brew_bin="$candidate"
        break
    fi
done

if [[ -z "$brew_bin" ]]; then
    echo "Homebrew Not Installed"
    exit 0
fi

packages=$(sudo -u "$console_user" "$brew_bin" list --formula 2>/dev/null)

if [[ -z "$packages" ]]; then
    echo "No Formulae Installed"
else
    echo "$packages"
fi

exit 0
