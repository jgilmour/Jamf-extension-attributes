# Jamf Extension Attributes

A collection of extension attribute scripts for Jamf Pro to enhance Mac fleet management and reporting capabilities.

## Overview

Extension attributes in Jamf Pro allow administrators to collect custom inventory data from managed devices. This repository contains battle-tested scripts that gather valuable information about macOS devices in your environment.

## Repository Structure

```
jamf-extension-attributes/
├── extension-attributes/     # Extension attribute scripts
│   └── *.sh                 # Individual scripts
├── CHANGELOG.md             # Version history and changes
├── LICENSE                  # License information
└── README.md               # This file
```

## Extension Attributes

### 1. Apple Intelligence Readiness Check

**File:** `extension-attributes/apple-intelligence-readiness.sh`

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

**File:** `extension-attributes/orphaned-home-directories.sh`

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

**File:** `extension-attributes/slow-charging-detection.sh`

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

**File:** `extension-attributes/monitor-refresh-rate.sh`

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

**File:** `extension-attributes/default-web-browser.sh`

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

### 7. Days Since Last Reboot

**File:** `extension-attributes/Days-Since-Last-Reboot.sh`

**Description:**
Reports the number of complete days since the Mac last rebooted, using the kernel boot time from `sysctl kern.boottime`.

**Detection Method:**
- Reads `kern.boottime` epoch value via `sysctl`
- Subtracts boot epoch from current epoch and divides by 86400

**Possible Results:**
- `3` - Integer days since last reboot
- `0` - Rebooted today or calculation failed

**Use Case:**
Enforce reboot compliance policies by identifying devices that haven't restarted within a defined window (e.g., 14 or 30 days). Create Smart Groups on this value to trigger self-healing policies or user notifications.

### 6. VPN Client Auto-Connect Status

**File:** `extension-attributes/vpn-auto-connect-status.sh`

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

```bash
# Make script executable
chmod +x extension-attributes/apple-intelligence-readiness.sh

# Run the script
./extension-attributes/apple-intelligence-readiness.sh
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
2. Use descriptive filenames (e.g., `check-something-specific.sh`)
3. Include header comments with:
   - Description
   - Requirements
   - Expected output values
   - Author and version
4. Update this README with script details
5. Add an entry to `CHANGELOG.md`
6. Follow bash best practices and handle errors gracefully

## Script Standards

All scripts in this repository should:
- Use bash as the interpreter (`#!/bin/bash`)
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

Current version: 1.6.0
See [CHANGELOG.md](CHANGELOG.md) for version history.
