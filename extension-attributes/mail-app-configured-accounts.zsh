#!/bin/zsh

###
### Jamf Extension Attribute: Mail App Configured Accounts
###
### Description:
###   Lists email addresses configured in the macOS Mail app for all local
###   users by parsing each user's Mail Accounts plist with python3.
###
### Output:
###   - Comma-separated list of email addresses across all users
###   - "No Accounts Configured" if no Mail accounts are found
###
### Author: Josh Gilmour <josh@joshgilmour.com>
### Created: 2026-04-03
### Version: 2.13.0
###

emails=()

while IFS= read -r username; do
    uid=$(dscl . -read "/Users/${username}" UniqueID 2>/dev/null | awk '{print $2}')
    [[ -z "$uid" ]] && continue
    [[ "$uid" -lt 500 ]] && continue

    home=$(dscl . -read "/Users/${username}" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
    [[ -z "$home" ]] && continue

    accounts_plist="${home}/Library/Mail/V10/MailData/Accounts.plist"

    # Fall back to older Mail data directories
    for candidate in \
        "${home}/Library/Mail/V10/MailData/Accounts.plist" \
        "${home}/Library/Mail/V9/MailData/Accounts.plist" \
        "${home}/Library/Mail/V8/MailData/Accounts.plist" \
        "${home}/Library/Preferences/com.apple.mail.plist"; do
        if [[ -f "$candidate" ]]; then
            accounts_plist="$candidate"
            break
        fi
    done

    [[ ! -f "$accounts_plist" ]] && continue

    # Use python3 to read the plist (handles binary and XML plists)
    found=$(python3 - "$accounts_plist" 2>/dev/null <<'PYEOF'
import sys, plistlib

path = sys.argv[1]
try:
    with open(path, "rb") as f:
        data = plistlib.load(f)
except Exception:
    sys.exit(0)

def find_emails(obj, results):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in ("AccountEmailAddress", "EmailAddress", "username") and isinstance(v, str) and "@" in v:
                results.add(v.lower().strip())
            else:
                find_emails(v, results)
    elif isinstance(obj, list):
        for item in obj:
            find_emails(item, results)

results = set()
find_emails(data, results)
for e in sorted(results):
    print(e)
PYEOF
)
    while IFS= read -r email; do
        [[ -n "$email" ]] && emails+=("$email")
    done <<< "$found"

done < <(dscl . -list /Users 2>/dev/null)

# Deduplicate
unique_emails=($(printf '%s\n' "${emails[@]}" | sort -u))

if [[ ${#unique_emails[@]} -eq 0 ]]; then
    echo "No Accounts Configured"
else
    echo "${(j:, :)unique_emails}"
fi

exit 0
