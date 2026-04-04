# Jamf Extension Attributes

A collection of extension attribute scripts for Jamf Pro to enhance Mac fleet management and reporting capabilities.

## Overview

Extension attributes in Jamf Pro allow administrators to collect custom inventory data from managed devices. This repository contains battle-tested scripts that gather valuable information about macOS devices in your environment.

## Repository Structure

```
jamf-extension-attributes/
├── extension-attributes/     # Extension attribute scripts
│   └── *.zsh                # Individual scripts
├── CHANGELOG.md             # Version history and changes
├── LICENSE                  # License information
└── README.md               # This file
```

## Extension Attributes

### 1. Apple Intelligence Readiness Check

**File:** `extension-attributes/apple-intelligence-readiness.zsh`

**Description:**
Determines if a Mac is capable of running Apple Intelligence features by checking hardware requirements.

**Requirements Checked:**
- Apple Silicon processor (M1 or newer)
- Unified Memory ≥ 8GB (configurable in script)

**Possible Results:**
- `Ready` - Device meets all requirements for Apple Intelligence
- `Not Supported (Intel)` - Device has Intel processor
- `Not Supported (Low RAM)` - Apple Silicon device with insufficient RAM

**Configuration:**
Edit the `RAM_THRESHOLD_GB` variable in the script to adjust RAM requirements (default: 8GB).

**Use Case:**
Identify which devices in your fleet can run Apple Intelligence features before scoping policies or OS upgrades. Useful for planning deployments and setting user expectations.

### 2. Orphaned Home Directory Detector

**File:** `extension-attributes/orphaned-home-directories.zsh`

**Description:**
Identifies home directories in `/Users/` that no longer have corresponding user accounts. Helps administrators locate and reclaim disk space from deleted or reassigned accounts.

**Directories Checked:**
- All directories in `/Users/` except:
  - `Shared`
  - `Guest`
  - Hidden directories (starting with `.`)

**Possible Results:**
- `None` - No orphaned directories found
- `username1, username2, ...` - Comma-separated list of orphaned directory names

**How It Works:**
1. Lists all directories in `/Users/`
2. For each directory, checks if a corresponding user account exists using `id -u [username]`
3. Reports directories where the user account no longer exists

**Use Case:**
When computers are reassigned or users leave the organization, local accounts are often deleted but home folders remain behind, consuming significant disk space. This extension attribute helps identify these orphaned directories for cleanup. Create a Smart Group for devices with orphaned directories to scope a cleanup policy or generate reports for manual review.

### 3. Slow Charging Detection (Wattage Mismatch)

**File:** `extension-attributes/slow-charging-detection.zsh`

**Description:**
Detects when a Mac is charging with an underpowered adapter that may cause performance issues or battery drain during use. Identifies users who are using USB-C hubs, phone chargers, or other low-wattage adapters instead of their MacBook's proper power adapter.

**Detection Method:**
- Queries `system_profiler SPPowerDataType` for AC charger information
- Extracts actual wattage from connected power adapter
- Compares against configurable threshold (default: 45W)

**Possible Results:**
- `Normal` - Adequate charging wattage detected
- `Low Wattage Detected (XXW)` - Charging below threshold (shows actual wattage)
- `Not Charging` - Device not connected to power
- `Unable to Detect` - Cannot determine wattage information

**Configuration:**
Edit the `WATTAGE_THRESHOLD` variable in the script to adjust the minimum acceptable wattage (default: 45W). Common MacBook chargers: 30W (MacBook Air), 61-67W (MacBook Pro 13"), 96-140W (MacBook Pro 14"/16").

**Use Case:**
Users often experience performance degradation or battery drain while plugged in because they're using underpowered USB-C accessories. This extension attribute helps identify these situations proactively. Create a Smart Group for devices with low wattage detection to send notifications to users or IT teams, or include in helpdesk workflows when troubleshooting performance complaints.

### 4. Current Monitor Refresh Rate

**File:** `extension-attributes/monitor-refresh-rate.zsh`

**Description:**
Reports the current refresh rate of the main display. Ensures ProMotion-capable MacBook Pros (120Hz) aren't accidentally locked to 60Hz and that external displays are running at optimal settings.

**Detection Method:**
- Queries `system_profiler SPDisplaysDataType` for display information
- Extracts refresh rate from display metadata
- Focuses on the main/primary display

**Possible Results:**
- `120 Hertz` - ProMotion or high refresh rate active
- `60 Hertz` - Standard refresh rate
- `XX Hertz` - Other refresh rate detected
- `Unable to Detect` - Cannot determine refresh rate

**Use Case:**
Creative agencies and organizations that invest in ProMotion MacBook Pros (120Hz displays) need to ensure users aren't accidentally running at lower refresh rates, which defeats the purpose of the premium hardware. External display users can also benefit from verifying optimal display settings. Create a Smart Group for devices not running at expected refresh rates to identify configuration issues or send reminders to users about display settings.

### 5. Default Web Browser

**File:** `extension-attributes/default-web-browser.zsh`

**Description:**
Identifies which web browser is set as the default system-wide handler for HTTP/HTTPS URLs. Essential for application compatibility planning, security policy enforcement, and software standardization tracking.

**Detection Method:**
- Primary: Uses Python with Foundation/AppKit frameworks to query LaunchServices
- Fallback: Reads LaunchServices preferences using PlistBuddy
- Parses bundle identifier and converts to human-readable browser name

**Possible Results:**
- `Safari` - Apple Safari browser
- `Chrome` - Google Chrome
- `Firefox` - Mozilla Firefox
- `Edge` - Microsoft Edge
- `Brave` - Brave Browser
- `Arc` - Arc Browser
- `Opera` - Opera browser
- `Vivaldi` - Vivaldi browser
- `Chromium` - Chromium browser
- `Safari Technology Preview` - Apple's beta Safari
- `Firefox Developer Edition` - Mozilla's developer browser
- `Chrome Canary` - Google's beta Chrome
- `Unknown` - Unrecognized browser or no default set

**Use Case:**
Organizations need to track browser adoption for application compatibility testing, security policy enforcement, and standardization initiatives. Some web applications only support specific browsers, making it critical to identify devices that may have compatibility issues. Create Smart Groups based on browser type to scope browser-specific policies, deploy extensions, or send communications about supported browsers. Also useful for measuring the success of browser migration projects.

### 6. VPN Client Auto-Connect Status

**File:** `extension-attributes/vpn-auto-connect-status.zsh`

**Description:**
Checks if enterprise VPN clients are configured to auto-connect on startup. Ensures remote workers maintain security posture by automatically connecting to corporate VPN when starting their devices.

**Supported VPN Clients:**
- Cisco AnyConnect
- Palo Alto GlobalProtect
- Fortinet FortiClient
- Zscaler
- Pulse Secure
- OpenVPN/Tunnelblick
- Sophos Connect
- SonicWall NetExtender
- Check Point VPN
- Cloudflare WARP

**Detection Method:**
- Checks if each VPN client application is installed
- Reads client-specific preference files and configurations
- Determines auto-connect/connect-on-demand settings
- Reports status for all installed VPN clients

**Possible Results:**
- `Not Installed` - No supported VPN clients found
- `[VPN Name]: Enabled` - Auto-connect is enabled (e.g., "Cisco AnyConnect: Enabled")
- `[VPN Name]: Disabled` - Auto-connect is disabled
- `[VPN Name]: Unknown` - VPN installed but auto-connect status cannot be determined
- Multiple VPNs: `Cisco AnyConnect: Enabled, GlobalProtect: Disabled`

**Use Case:**
Remote and hybrid workforces require consistent VPN connectivity to access corporate resources securely. This extension attribute helps IT teams verify that VPN clients are properly configured for automatic connection, reducing security risks from users forgetting to connect manually. Create Smart Groups for devices with disabled auto-connect to send reminders, deploy configuration profiles, or generate compliance reports. Essential for security policy enforcement and audit requirements.

### 7. Days Since Last Reboot

**File:** `extension-attributes/days-since-last-reboot.zsh`

**Description:**
Returns the number of whole days since the last system boot as a plain integer, enabling numeric comparisons in Jamf smart groups.

**Detection Method:**
- Reads `sysctl -n kern.boottime` to get boot epoch seconds
- Computes elapsed seconds against current epoch (`date +%s`)
- Divides by 86400 to yield whole days

**Possible Results:**
- `14` - Integer number of days since last reboot (example)
- `Unknown` - Boot time could not be determined or returned unexpected format

**Use Case:**
Identify devices that haven't rebooted within policy (e.g., more than 14 or 30 days). Create Smart Groups using numeric comparisons to scope reboot-nudge policies, enforce patch management workflows, or flag devices with excessive uptime before they cause problems.

### 8. Local Admin Account Audit

**File:** `extension-attributes/local-admin-account-audit.zsh`

**Description:**
Audits local admin group membership and returns any accounts that are not on the expected allowlist. Helps detect rogue or accidental admin escalations across your fleet.

**Detection Method:**
- Reads admin group members via `dscl . -read /Groups/admin GroupMembership`
- Filters out system accounts (UID < 500) and accounts that no longer exist in dscl
- Compares remaining members against a configurable `EXPECTED_ADMINS` array

**Possible Results:**
- `Clean` - Only expected accounts have admin privileges
- `rogue_user, tempaccount` - Comma-separated list of unexpected admin accounts
- `No Admin Group Found` - Admin group could not be read

**Configuration:**
Edit the `EXPECTED_ADMINS` array in the script to match the admin account names in your environment.

**Use Case:**
Enforce least-privilege policies and detect unauthorized admin escalations. Create a Smart Group for devices where this attribute is not `Clean` to trigger remediation policies or alert your security team.

### 9. Wi-Fi SSID and Security Protocol

**File:** `extension-attributes/wifi-ssid-security.zsh`

**Description:**
Returns the connected Wi-Fi SSID and security protocol in a single string. Detects open or weak networks and confirms WPA3 adoption across the fleet.

**Detection Method:**
- Uses `networksetup -getairportnetwork` per interface for SSID (reliable on macOS 15+)
- Parses `system_profiler SPAirPortDataType` for the security mode of the current network
- Handles multiple Wi-Fi interfaces (en0, en1)

**Possible Results:**
- `SSID: Corp-WiFi | Security: WPA3 Personal` - Connected with security info
- `Not Connected` - Wi-Fi on but not associated to a network
- `Wi-Fi Off` - Wi-Fi hardware is disabled

**Use Case:**
Detect devices connecting to open or WPA2 networks when WPA3 is required. Create Smart Groups to identify remote workers on weak home networks, enforce connection policies, or audit compliance with wireless security standards.

### 10. VPN Connected Status

**File:** `extension-attributes/vpn-connected-status.zsh`

**Description:**
Reports whether a VPN tunnel is currently active by inspecting `utun` interfaces for routable IPv4 addresses. Includes a secondary check for the Palo Alto GlobalProtect daemon.

**Detection Method:**
- Parses `ifconfig` output for all `utun` interfaces with non-link-local IPv4 addresses
- Prefers higher-numbered `utun` interfaces (e.g., `utun2`) over `utun0` which macOS uses for system features
- Checks for `PanGPS` process as a GlobalProtect connectivity indicator

**Possible Results:**
- `Connected (10.0.0.42 via utun3)` - VPN active with tunnel IP and interface
- `Connected (GlobalProtect active, IP pending)` - GP daemon running but IP not yet assigned
- `Not Connected` - No active VPN tunnel detected

**Use Case:**
Verify VPN connectivity at inventory collection time for remote workers. Create Smart Groups for devices not connected to VPN to enforce compliance policies, trigger notifications, or restrict access to sensitive configuration profiles.

### 11. FileVault SecureToken Status

**File:** `extension-attributes/filevault-securetoken-status.zsh`

**Description:**
Reports the SecureToken status for every local standard user account (UID ≥ 500). SecureToken is required for a user to decrypt and unlock FileVault at the pre-boot login window.

**Detection Method:**
- Lists all user accounts via `dscl . -list /Users` and filters by UID ≥ 500
- Calls `sysadminctl -secureTokenStatus <username>` for each account
- Parses stdout/stderr for `ENABLED` or `DISABLED` keywords

**Possible Results:**
- `alice: Enabled, bob: Disabled` - Per-user SecureToken state, comma-separated
- `No local users found` - No standard accounts found on the device
- `sysadminctl unavailable` - Tool not present (requires macOS 10.14+)

**Use Case:**
Before enforcing FileVault via MDM, ensure the right accounts have SecureToken so they can unlock the volume. Create Smart Groups for devices where any user shows `Disabled` to trigger remediation workflows or SecureToken bootstrapping policies.

### 12. Login Items and Background Agents

**File:** `extension-attributes/login-items-background-agents.zsh`

**Description:**
Enumerates all login items and background agents registered on the device. Uses the modern Background Task Management API on macOS 13+ and falls back to LaunchAgent scanning on macOS 12 and earlier.

**Detection Method:**
- **macOS 13+ (Ventura):** Runs `sfltool dumpbtm` and parses `name` fields from Background Task Management output
- **macOS 12 and earlier:** Reads `Label` from all `.plist` files in `/Library/LaunchAgents/` and each user's `~/Library/LaunchAgents/`
- Results are deduplicated and sorted alphabetically

**Possible Results:**
- `1Password, Dropbox, com.company.agent` - Sorted, comma-separated list of item names/labels
- `None` - No login items or background agents found
- `Unable to Detect` - `sfltool dumpbtm` returned no output

**Use Case:**
Audit persistent background software across the fleet. Identify unexpected background agents that could indicate adware, malware persistence, or unwanted software. Create Smart Groups to flag devices with specific items for investigation or automated removal policies.

### 13. Chrome Extension Audit

**File:** `extension-attributes/chrome-extension-audit.zsh`

**Description:**
Audits Google Chrome browser extensions installed across all user profiles on the device. Returns a sorted, deduplicated list of extension names to detect unapproved or malicious extensions.

**Detection Method:**
- Iterates through all local user home directories
- Scans all Chrome profiles (`Default` and `Profile *`) per user
- Parses `manifest.json` in each extension's versioned directory
- Deduplicates extension names across all users and profiles
- Skips localisation token names (`__MSG_*`) that lack human-readable labels

**Possible Results:**
- `Chrome Not Installed` - Google Chrome app not found in `/Applications`
- `No Extensions Found` - Chrome is installed but no extensions detected
- `1Password – Password Manager, uBlock Origin, ...` - Sorted comma-separated list of extension names

**Use Case:**
Identify unapproved or malicious browser extensions across the fleet before a security incident occurs. Create Smart Groups scoped to devices with known-bad extensions or audit extension sprawl ahead of a browser management rollout. Also useful for verifying that required security extensions (e.g., endpoint protection, password managers) are installed.

### 11. Login Items / Background Launch Agents

**File:** `extension-attributes/login-items-background-agents.zsh`

**Description:**
Lists non-Apple background login items and launch agents. On macOS 13+ uses the Background Task Manager via `sfltool dumpbtm`; on macOS 12 and earlier falls back to scanning LaunchAgents directories.

**Detection Method:**
- macOS 13+: parses `sfltool dumpbtm` output, filters out `com.apple.*` bundle IDs
- macOS 12 and earlier: scans `/Library/LaunchAgents`, `/Library/LaunchDaemons`, and per-user LaunchAgents

**Possible Results:**
- `com.vendor.app` (newline-delimited) - Non-Apple background items found
- `None Found` - No non-Apple background items detected
- `macOS 12 or earlier - Legacy scan: None Found` - Legacy path, nothing found
- `macOS 12 or earlier - Legacy scan:` followed by item list

**Use Case:**
Identify unauthorised persistence mechanisms, third-party software installing background agents without consent, or track down unwanted startup items across the fleet.

### 12. Jamf Connect Migration Status

**File:** `extension-attributes/jamf-connect-migration-status.zsh`

**Description:**
Checks whether Jamf Connect is installed and whether the login window authentication chain has been configured to use it. Useful for tracking rollout progress.

**Detection Method:**
- Checks for `/Applications/Jamf Connect.app`
- Runs `authchanger -print` (searches `/usr/local/bin` and `/usr/bin`) and looks for `JamfConnect` in the output

**Possible Results:**
- `Migrated` - Jamf Connect is installed and present in the auth chain
- `Not Migrated` - Installed but not in the auth chain (authchanger not configured)
- `Jamf Connect Not Installed` - App not found on device

**Use Case:**
Track the progress of a Jamf Connect deployment. Identify devices where the app was installed but the auth migration did not complete, or validate full migration before retiring legacy auth methods.

### 13. Apple Intelligence Eligibility and Status

**File:** `extension-attributes/apple-intelligence-eligibility.zsh`

**Description:**
Checks whether a device is eligible for Apple Intelligence and whether it has been enabled by the current user.

**Detection Method:**
- Architecture check: must be `arm64` (Apple Silicon)
- macOS version check: must be 15.1 or later
- MDM restriction check: reads `com.apple.applicationaccess` for `allowAppleIntelligence` / `allowWritingTools`
- User opt-in check: reads `com.apple.CloudSubscriptionFeatures` preference for the console user

**Possible Results:**
- `Eligible: Yes | Enabled: Yes` - Eligible and user has enabled it
- `Eligible: Yes | Enabled: No` - Eligible but not yet enabled
- `Eligible: No | Reason: Intel Mac` - Intel processor, not supported
- `Eligible: No | Reason: macOS below 15.1` - OS too old
- `Eligible: No | Reason: MDM Restricted` - MDM policy is blocking Apple Intelligence

**Use Case:**
Identify which devices can run Apple Intelligence, track user adoption, and verify that MDM restriction policies are applied where required. Create Smart Groups for eligible-but-not-enabled devices to send enablement guides to users.

### 14. Secure Boot Policy

**File:** `extension-attributes/secure-boot-policy.zsh`

**Description:**
Reports the current Secure Boot security policy level. Differentiates between Apple Silicon and Intel (with or without T2 security chip) to provide the correct policy level for each platform.

**Detection Method:**
- Checks architecture with `uname -m`
- **Apple Silicon:** queries `bputil -d` for Full / Reduced / Permissive Security levels
- **Intel T2:** verifies T2 presence via `system_profiler SPiBridgeDataType`, then queries `bputil -d`
- **Intel without T2:** reports N/A — no Secure Boot capability

**Possible Results:**
- `Full Security` - Default; only Apple-signed, current macOS versions allowed to boot
- `Reduced Security` - Older macOS or approved third-party kernel extensions permitted
- `Permissive Security` - Minimal restrictions; all kernel extensions allowed
- `Full Security (Intel T2)` / `Medium Security (Intel T2)` / `No Security (Intel T2)`
- `N/A (Intel Mac, No T2)` - Intel Mac without T2 security chip

**Use Case:**
Audit and enforce Secure Boot policy across the fleet. Create Smart Groups for devices with Reduced or Permissive Security to trigger remediation, validate that MDM security baseline policies have been applied, and ensure kext-dependent software doesn't inadvertently lower security posture across the environment.

### 24. Time Machine Backup Status

**File:** `extension-attributes/time-machine-backup-status.zsh`

**Description:**
Reports the last Time Machine backup date and destination name. Identifies devices that have never backed up or have no Time Machine destination configured.

**Detection Method:**
- `tmutil destinationinfo` — retrieves the configured backup destination name
- `tmutil latestbackup` — returns the path of the most recent completed snapshot
- Parses the snapshot directory name (`YYYY-MM-DD-HHMMSS`) to produce a readable timestamp

**Possible Results:**
- `Last Backup: YYYY-MM-DD HH:MM | Destination: NAME | Status: OK` - Backup found
- `Last Backup: Never | Destination: NAME | Status: OK` - Destination set but no backup yet
- `Not Configured` - No Time Machine destination is configured

**Use Case:**
Create a Smart Group for devices with "Last Backup: Never" or devices whose last backup date is older than your policy threshold. Scope a Self Service notification or a Jamf Notify alert to remind users to connect their backup drive or configure Time Machine.

### 23. Battery Health and Cycle Count

**File:** `extension-attributes/battery-health-and-cycle-count.zsh`

**Description:**
Reports battery condition, cycle count, and maximum capacity for MacBook models. Returns a fixed result for desktop Macs that have no battery.

**Detection Method:**
- Runs `system_profiler SPPowerDataType`
- Extracts `Condition`, `Cycle Count`, and `Maximum Capacity` fields
- Uses absence of `Cycle Count` data to identify desktop Macs

**Possible Results:**
- `Condition: Normal | Cycle Count: N | Max Capacity: N%` - Healthy battery
- `Condition: Service Recommended | Cycle Count: N | Max Capacity: N%` - Battery needs replacement
- `Desktop Mac (No Battery)` - Mac mini, Mac Pro, iMac, or Mac Studio

**Use Case:**
Create a Smart Group for laptops with "Condition: Service Recommended" to proactively identify devices needing battery replacement before users experience unexpected shutdowns. Track cycle count trends to forecast fleet-wide battery refresh cycles.

### 22. Mail App Configured Accounts

**File:** `extension-attributes/mail-app-configured-accounts.zsh`

**Description:**
Lists email addresses configured in the macOS Mail app for all local users by parsing Mail account plists with `python3 plistlib`. Works with binary and XML plists across Mail V8/V9/V10 data directories.

**Detection Method:**
- Iterates local users with UID ≥ 500
- Searches Mail data directories (`~/Library/Mail/V8–V10/MailData/Accounts.plist`)
- Recursively finds keys matching `AccountEmailAddress` / `EmailAddress` containing `@`
- Deduplicates email addresses across all users

**Possible Results:**
- `user@corp.com, user@personal.com` - Comma-separated list of configured email addresses
- `No Accounts Configured` - No Mail accounts found for any local user

**Use Case:**
Verify that managed devices have corporate email configured in Mail. Detect personal email accounts that may be in violation of acceptable use policy. Useful for auditing Mail configuration before device reassignment or decommission.

### 21. MDM Configuration Profile Audit

**File:** `extension-attributes/mdm-configuration-profile-audit.zsh`

**Description:**
Reports the total number and display names of all MDM configuration profiles installed on the device. Useful for verifying that required profiles are present and auditing unexpected profiles.

**Detection Method:**
- Runs `profiles list -all`
- Parses `profileDisplayName` fields from the output

**Possible Results:**
- `N profile(s) installed: name1, name2, ...` - Comma-separated list with count
- `0 profiles installed` - No profiles found

**Use Case:**
Verify that every device has the expected set of baseline security and compliance profiles. Create Smart Groups for devices with a profile count below a threshold or for devices missing a specific profile name string. Also useful after an MDM migration to confirm all profiles have re-applied successfully.

### 20. TCC Full Disk Access Apps

**File:** `extension-attributes/tcc-full-disk-access-apps.zsh`

**Description:**
Lists all applications that have been granted Full Disk Access (FDA) by querying the system TCC database. Full Disk Access is a high-privilege TCC permission that allows apps to read all files on the system.

**Detection Method:**
- Queries `/Library/Application Support/com.apple.TCC/TCC.db` via `sqlite3`
- Filters on `service = 'kTCCServiceSystemPolicyAllFiles'` and `auth_value = 2` (allowed)
- Deduplicates and sorts results

**Requirements:**
The Jamf management framework must have Full Disk Access granted in System Settings to read the system TCC database. Grant this via a PPPC (Privacy Preferences Policy Control) profile.

**Possible Results:**
- `com.vendor.app, /path/to/tool, ...` - Comma-separated bundle IDs / paths with FDA
- `None Granted` - No apps have Full Disk Access

**Use Case:**
Audit which applications have Full Disk Access across the fleet. Detect unexpected grants that may indicate a compromised or misconfigured device. Validate that required security tools (EDR agents, backup software) have received FDA after a PPPC profile deployment.

### 19. Local User Password Age

**File:** `extension-attributes/local-user-password-age.zsh`

**Description:**
Reports how many days have elapsed since each local standard user (UID ≥ 500) last changed their password. Uses Directory Services to read `passwordLastSetTime` for each account.

**Detection Method:**
- Lists all local users via `dscl . -list /Users`
- Filters to UID ≥ 500 (standard/admin users)
- Reads `passwordLastSetTime` and converts from Apple Core Data epoch to days elapsed

**Possible Results:**
- `user1: N days | user2: N days` - Days since last password change per user
- `No Local Users Found` - No standard local accounts present

**Use Case:**
Identify devices with users who have not rotated their password within your policy window (e.g., 90 days). Create a Smart Group using a "greater than" criteria on the result and scope a Jamf Notify or Self Service reminder policy to prompt users to change their password.

### 18. Pending macOS Software Updates

**File:** `extension-attributes/pending-macos-software-updates.zsh`

**Description:**
Reports the number and names of pending Apple software updates. Allows Smart Groups and policies to target devices with outstanding updates.

**Detection Method:**
- Runs `softwareupdate -l`
- Parses lines starting with `*` to extract pending update names
- Checks for "No new software available" to confirm a clean state

**Possible Results:**
- `N update(s) pending: name1, name2, ...` - Updates are available
- `0 updates pending` - Device is fully up to date

**Use Case:**
Create Smart Groups for devices with any pending updates to scope deferred-update nudge policies or force-install policies for critical security patches. Track how quickly new OS updates propagate across the fleet after release.

### 17. Homebrew Package Audit

**File:** `extension-attributes/homebrew-package-audit.zsh`

**Description:**
Lists all Homebrew formulae installed for the console user. Useful for auditing developer tools, detecting unapproved software, and tracking package sprawl across managed Macs.

**Detection Method:**
- Identifies the console user via `stat -f "%Su" /dev/console`
- Searches for the `brew` binary at `/opt/homebrew/bin/brew` (Apple Silicon) and `/usr/local/bin/brew` (Intel)
- Runs `brew list --formula` as the console user

**Possible Results:**
- Newline-separated list of installed formula names
- `No Formulae Installed` - Homebrew is present but no formulae are installed
- `Homebrew Not Installed` - No `brew` binary found
- `No User Logged In` - No active console session

**Use Case:**
Identify devices where users have installed security-sensitive tools (nmap, netcat, john, hashcat) or unapproved software via Homebrew. Create Smart Groups scoped to devices with specific package names to trigger policy enforcement or user notifications. Also useful for planning a managed Homebrew rollout to replace ad-hoc installations.

### 16. XProtect Version and Currency

**File:** `extension-attributes/xprotect-version-and-currency.zsh`

**Description:**
Reports the installed XProtect version and whether it matches the latest version published in the SOFA macOS data feed. Helps identify devices with stale malware definitions.

**Detection Method:**
- Reads `Version` key from `/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Resources/XProtect.meta.plist`
- Fetches the SOFA macOS data feed (`sofafeed.macadmins.io`) via `curl`
- Compares local version against the latest published `com.apple.XProtect` payload version

**Possible Results:**
- `Version: X | Status: Current` - Installed version matches the SOFA feed
- `Version: X | Status: Outdated` - A newer version is available
- `Version: X | Status: Unknown` - SOFA feed was unreachable; version shown but currency unknown
- `Not Found` - XProtect meta plist missing (unusual)

**Use Case:**
Create a Smart Group for devices with "Status: Outdated" to identify machines where XProtect updates have stalled. Pair with a policy to trigger a software update check, or alert the security team when a significant portion of the fleet falls behind.

### 15. Bootstrap Token Escrow Status

**File:** `extension-attributes/bootstrap-token-escrow-status.zsh`

**Description:**
Reports whether the device's Bootstrap Token has been escrowed with the MDM server. The Bootstrap Token is required for MDM-managed FileVault recovery key rotation and Erase All Content and Settings (EACS) on Apple Silicon.

**Detection Method:**
- Runs `profiles status -type bootstraptoken`
- Parses the "escrowed to server" field from the output

**Possible Results:**
- `Escrowed` - Bootstrap Token has been successfully sent to and confirmed by MDM
- `Not Escrowed` - Token exists locally but has not been delivered to MDM
- `Not Supported` - Device or macOS version does not support Bootstrap Token

**Use Case:**
Bootstrap Token escrow is a prerequisite for MDM-driven FileVault recovery key rotation and Erase All Content and Settings on Apple Silicon. Create a Smart Group for devices where the token is "Not Escrowed" and scope a re-enrolment or Bootstrap Token re-escrow policy to remediate.

## Installation

### Adding to Jamf Pro

1. Log in to your Jamf Pro server
2. Navigate to **Settings** > **Computer Management** > **Extension Attributes**
3. Click **+ New**
4. Configure the extension attribute:
   - **Display Name:** Choose a descriptive name (e.g., "Apple Intelligence Ready")
   - **Description:** Add context for your team
   - **Data Type:** String
   - **Inventory Display:** Choose appropriate category (e.g., "Hardware")
   - **Input Type:** Script
5. Copy and paste the script content into the script field
6. Click **Save**

### Running Scripts Locally for Testing

```zsh
# Make script executable
chmod +x extension-attributes/apple-intelligence-readiness.zsh

# Run the script
./extension-attributes/apple-intelligence-readiness.zsh
```

## Best Practices

- **Test First:** Always test scripts on a representative sample of devices before deploying fleet-wide
- **Review Output:** Check the extension attribute data after the next inventory update
- **Smart Groups:** Create Smart Groups based on extension attribute values for targeted deployments
- **Documentation:** Update descriptions in Jamf Pro to help your team understand each attribute's purpose
- **Performance:** Extension attributes run during inventory collection - keep scripts efficient

## Contributing

When adding new extension attributes to this repository:

1. Place scripts in the `extension-attributes/` directory
2. Use descriptive filenames (e.g., `check-something-specific.zsh`)
3. Include header comments with:
   - Description
   - Requirements
   - Expected output values
   - Author and version
4. Update this README with script details
5. Add an entry to `CHANGELOG.md`
6. Follow zsh best practices and handle errors gracefully

## Script Standards

All scripts in this repository should:
- Use zsh as the interpreter (`#!/bin/zsh`)
- Output in Jamf-compatible format: `<result>VALUE</result>`
- Include comprehensive comments
- Handle errors gracefully
- Use functions for complex logic
- Set appropriate exit codes
- Be idempotent and safe to run multiple times

## Compatibility

- **Jamf Pro:** 10.x and later
- **macOS:** Version-specific requirements noted in individual scripts

## Support

For issues or questions:
- Check individual script comments for specific details
- Review Jamf Pro documentation for extension attributes
- Test scripts locally before deploying

## License

See [LICENSE](LICENSE) file for details.

## Version

Current version: 2.5.0
See [CHANGELOG.md](CHANGELOG.md) for version history.
