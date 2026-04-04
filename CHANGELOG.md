# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.7.0] - 2026-04-03

### Added
- XProtect Version and Currency extension attribute script
  - Reads the installed XProtect version from `XProtect.meta.plist`
  - Fetches the latest published version from the SOFA macOS data feed (sofafeed.macadmins.io)
  - Compares local vs. latest and returns "Current" or "Outdated"
  - Falls back to "Unknown" status if the SOFA feed is unreachable (no network, proxy block)
  - Common use cases:
    - Identify devices running outdated XProtect definitions that may be at higher malware risk
    - Verify that Rapid Security Responses have propagated across the fleet
    - Include XProtect currency in security compliance reporting dashboards

### Changed
- Updated repository version to 2.7.0

## [2.6.0] - 2026-04-03

### Added
- Bootstrap Token Escrow Status extension attribute script
  - Runs `profiles status -type bootstraptoken` to query MDM escrow state
  - Returns "Escrowed" when the Bootstrap Token has been sent to and confirmed by MDM
  - Returns "Not Escrowed" when a token exists but has not been escrowed
  - Returns "Not Supported" on devices or OS versions that do not support Bootstrap Token
  - Common use cases:
    - Ensure Bootstrap Tokens are escrowed before relying on MDM-driven FileVault recovery
    - Identify devices that failed to escrow after enrolment or a re-enrolment event
    - Audit Bootstrap Token state as part of a Zero Touch deployment validation workflow

### Changed
- Updated repository version to 2.6.0

## [2.5.0] - 2026-04-03

### Added
- Secure Boot Policy extension attribute script
  - Detects architecture via `uname -m` to select the correct detection path
  - Apple Silicon: runs `bputil -d` and maps output to Full / Reduced / Permissive Security
  - Intel T2: checks `system_profiler SPiBridgeDataType` for T2 presence, then queries `bputil -d`
  - Intel without T2: returns "N/A (Intel Mac, No T2)"
  - Common use cases:
    - Enforce Full Security policy across the fleet before deploying sensitive workloads
    - Identify Macs with Permissive or Reduced security that have kernel extensions enabled
    - Audit Secure Boot state after MDM security policy deployment

### Changed
- Updated repository version to 2.5.0

## [2.4.0] - 2026-04-03

### Added
- Apple Intelligence Eligibility and Status extension attribute script
  - Checks architecture (must be Apple Silicon arm64)
  - Validates macOS version (must be 15.1 or later)
  - Checks MDM restriction keys (`allowAppleIntelligence`, `allowWritingTools`)
  - Checks user-level opt-in via CloudSubscriptionFeatures preference
  - Returns eligibility and enabled state in a single result string
  - Common use cases:
    - Identify devices eligible for Apple Intelligence features
    - Track MDM restriction compliance
    - Measure user adoption of Apple Intelligence across the fleet
- Updated README.md with documentation for Apple Intelligence Eligibility and Status script

### Changed
- Updated repository version to 2.4.0

## [2.3.0] - 2026-04-03

### Added
- Jamf Connect Migration Status extension attribute script
  - Returns "Migrated" if Jamf Connect is installed and present in the auth chain
  - Returns "Not Migrated" if installed but not configured in the login window
  - Returns "Jamf Connect Not Installed" if the app is absent
  - Uses `authchanger -print` (checks `/usr/local/bin` and `/usr/bin`) to inspect the auth chain
  - Common use cases:
    - Track progress of Jamf Connect rollout across the fleet
    - Identify devices where installation succeeded but auth migration did not
    - Validate post-migration state before decommissioning legacy auth
- Updated README.md with documentation for Jamf Connect Migration Status script

### Changed
- Updated repository version to 2.3.0

## [2.2.0] - 2026-04-03

### Added
- Login Items and Background Agents extension attribute script
  - On macOS 13+ (Ventura): uses `sfltool dumpbtm` to enumerate Background Task Management registrations
  - On macOS 12 and earlier: reads `/Library/LaunchAgents` and per-user `~/Library/LaunchAgents` plists
  - Deduplicates and sorts all discovered item names
  - Common use cases:
    - Audit persistent software installed by third-party apps
    - Detect unexpected background agents that could indicate compromise
    - Inventory login item sprawl before a cleanup initiative

### Changed
- Updated repository version to 2.2.0

## [2.1.0] - 2026-04-03

### Added
- FileVault SecureToken Status extension attribute script
  - Iterates over all local users with UID ≥ 500 using `dscl . -list /Users`
  - Queries each user's SecureToken state via `sysadminctl -secureTokenStatus`
  - Returns a comma-separated per-user status (e.g., "alice: Enabled, bob: Disabled")
  - Handles missing `sysadminctl` gracefully (macOS < 10.14)
  - Common use cases:
    - Identify users who cannot unlock FileVault at the pre-boot login window
    - Ensure all IT admin accounts have SecureToken before enabling FileVault
    - Audit SecureToken state after account migrations or MDM re-enrolment

### Changed
- Updated repository version to 2.1.0

## [2.0.0] - 2026-04-03

### Added
- VPN Connected Status extension attribute script
  - Inspects all active `utun` interfaces via `ifconfig` for routable IPv4 addresses
  - Reports the tunnel interface name and assigned IP when connected
  - Secondary check: detects Palo Alto GlobalProtect daemon (`PanGPS`) as a VPN indicator
  - Skips link-local (169.254.x.x) addresses and macOS system utun0 when higher tunnels exist
  - Common use cases:
    - Confirm VPN is active before allowing access to restricted policies
    - Audit remote worker VPN connectivity at inventory time
    - Identify devices that are offline from corporate VPN for compliance reporting

### Changed
- Updated repository version to 2.0.0

## [1.9.0] - 2026-04-03

### Added
- Chrome Extension Audit extension attribute script
  - Loops through all user Chrome profiles (Default + Profile *) for every local user
  - Parses `manifest.json` to extract human-readable extension names
  - Deduplicates across users and profiles; skips localisation token names (`__MSG_*`)
  - Returns a sorted, comma-separated list or "No Extensions Found" / "Chrome Not Installed"
  - Common use cases:
    - Detect unapproved or malicious browser extensions across the fleet
    - Enforce extension allowlists for regulated environments
    - Audit extension sprawl before a browser management rollout

### Changed
- Updated repository version to 1.9.0

## [1.8.0] - 2026-04-03

### Added
- Wi-Fi SSID and Security Protocol extension attribute script
  - Returns connected SSID and security protocol (e.g. "SSID: Corp-WiFi | Security: WPA3 Personal")
  - Uses `networksetup -getairportnetwork` for SSID (reliable on macOS 15+)
  - Parses `system_profiler SPAirPortDataType` for security mode
  - Handles multiple Wi-Fi interfaces (en0, en1), Wi-Fi off, and not connected states
  - Common use cases:
    - Detect devices connecting to open or weak-security networks
    - Enforce WPA3 compliance policies across the fleet
    - Identify remote workers on potentially insecure home networks
- Updated README.md with documentation for Wi-Fi SSID and Security Protocol script

### Changed
- Updated repository version to 1.8.0

## [1.7.0] - 2026-04-03

### Added
- Local Admin Account Audit extension attribute script
  - Returns comma-separated list of unexpected local admin accounts, or "Clean"
  - Reads admin group membership via `dscl . -read /Groups/admin GroupMembership`
  - Compares members against a configurable `EXPECTED_ADMINS` allowlist
  - Skips system accounts (UID < 500) and accounts that no longer exist in dscl
  - Common use cases:
    - Detect rogue or accidental admin escalations
    - Enforce least-privilege policies across the fleet
    - Audit admin accounts after offboarding or role changes
- Updated README.md with documentation for Local Admin Account Audit script

### Changed
- Updated repository version to 1.7.0

## [1.6.0] - 2026-04-03

### Added
- Days Since Last Reboot extension attribute script
  - Uses `sysctl kern.boottime` to retrieve kernel boot time as epoch seconds
  - Calculates complete days elapsed since last reboot via integer arithmetic
  - Returns a plain integer (e.g., "3") representing days since last reboot
  - Returns "0" if the device rebooted today or if boot time cannot be determined
  - Common use cases:
    - Identify devices that haven't been rebooted within policy (e.g., 14 or 30 days)
    - Enforce reboot compliance for patch management and memory health
    - Trigger remediation policies for devices with excessive uptime
- Updated README.md with documentation for Days Since Last Reboot script

### Changed
- Updated repository version to 1.6.0

## [1.5.0] - 2025-12-13

### Added
- VPN Client Auto-Connect Status extension attribute script
  - Checks auto-connect configuration for 10 enterprise VPN clients
  - Supported VPNs: Cisco AnyConnect, Palo Alto GlobalProtect, Fortinet FortiClient, Zscaler, Pulse Secure, Tunnelblick, Sophos Connect, SonicWall NetExtender, Check Point VPN, Cloudflare WARP
  - Reads client-specific preference files and configurations
  - Reports status for all installed VPN clients: Enabled, Disabled, Unknown, or Not Installed
  - Returns multiple VPN statuses in single result (e.g., "Cisco AnyConnect: Enabled, GlobalProtect: Disabled")
  - Common use cases:
    - Ensure remote workers maintain security posture with auto-connect VPN
    - Security policy enforcement and compliance auditing
    - Identify devices with disabled auto-connect for remediation
    - Generate reports for hybrid workforce security
- Updated README.md with documentation for VPN Auto-Connect Status script
  - Complete list of 10 supported VPN clients
  - Detection methodology for each VPN client
  - Use cases for remote workforce security
  - Smart Group suggestions for compliance and remediation

### Changed
- Updated repository version to 1.5.0

## [1.4.0] - 2025-12-13

### Added
- Default Web Browser extension attribute script
  - Identifies default system-wide HTTP/HTTPS URL handler using LaunchServices
  - Primary method: Python with Foundation/AppKit frameworks
  - Fallback method: PlistBuddy for LaunchServices preferences
  - Recognizes 12+ popular browsers (Safari, Chrome, Firefox, Edge, Brave, Arc, Opera, Vivaldi, etc.)
  - Returns human-readable browser names or "Unknown" for unrecognized browsers
  - Common use cases:
    - Application compatibility planning and testing
    - Security policy enforcement
    - Software standardization tracking
    - Browser migration project measurement
- Updated README.md with documentation for Default Web Browser script
  - Comprehensive list of supported browsers
  - Detection methodology explanation
  - Use cases for compatibility and policy enforcement
  - Smart Group suggestions for browser-specific policies

### Changed
- Updated repository version to 1.4.0

## [1.3.0] - 2025-12-13

### Added
- Current Monitor Refresh Rate extension attribute script
  - Reports refresh rate of main display using `system_profiler SPDisplaysDataType`
  - Detects ProMotion (120Hz) and standard (60Hz) refresh rates
  - Returns: "XX Hertz" format (e.g., "120 Hertz", "60 Hertz") or "Unable to Detect"
  - Helps ensure ProMotion MacBook Pros aren't locked to lower refresh rates
  - Common use case: Verify creative workstations are utilizing premium display hardware correctly
- Updated README.md with documentation for Monitor Refresh Rate script
  - Script details and detection methodology
  - Use case explanation for ProMotion and external displays
  - Smart Group suggestions for display configuration monitoring

### Changed
- Updated repository version to 1.3.0

## [1.2.0] - 2025-12-13

### Added
- Slow Charging Detection (Wattage Mismatch) extension attribute script
  - Detects underpowered charging adapters using `system_profiler SPPowerDataType`
  - Extracts and compares actual charger wattage against configurable threshold (default: 45W)
  - Returns: "Normal", "Low Wattage Detected (XXW)", "Not Charging", or "Unable to Detect"
  - Helps identify performance issues caused by USB-C hubs, phone chargers, or inadequate power adapters
  - Common use case: Proactively address user complaints about battery drain or performance while plugged in
- Updated README.md with documentation for Slow Charging Detection script
  - Script details and detection method
  - Configuration options for wattage threshold
  - Smart Group suggestions for helpdesk workflows
  - Reference wattages for common MacBook models

### Changed
- Updated repository version to 1.2.0

## [1.1.0] - 2025-12-13

### Added
- Orphaned Home Directory Detector extension attribute script
  - Identifies home directories in /Users/ without corresponding user accounts
  - Excludes system directories (Shared, Guest, hidden directories)
  - Returns "None" or comma-separated list of orphaned directory names
  - Helps administrators reclaim disk space from deleted/reassigned accounts
- Updated README.md with documentation for Orphaned Home Directory Detector
  - Script details and use cases
  - How it works explanation
  - Smart Group suggestions for cleanup workflows

### Changed
- Updated repository version to 1.1.0

## [1.0.0] - 2025-12-13

### Added
- Initial repository structure for Jamf extension attributes
- Apple Intelligence Readiness Check extension attribute script
  - Detects Apple Silicon (M1 or newer) processors
  - Validates RAM requirements (8GB+ configurable threshold)
  - Returns device readiness status for Apple Intelligence features
- Comprehensive README.md with:
  - Repository overview and structure
  - Installation instructions for Jamf Pro
  - Script documentation and use cases
  - Best practices and contribution guidelines
  - Script standards and compatibility information
- CHANGELOG.md for tracking version history
- MIT License

### Changed
- N/A (Initial release)

### Deprecated
- N/A (Initial release)

### Removed
- N/A (Initial release)

### Fixed
- N/A (Initial release)

### Security
- N/A (Initial release)

---

## Release Notes Format

Each release will document changes in the following categories:
- **Added** - New features or scripts
- **Changed** - Changes to existing functionality
- **Deprecated** - Features that will be removed in upcoming releases
- **Removed** - Features or scripts that have been removed
- **Fixed** - Bug fixes
- **Security** - Security-related changes or fixes

## Version Numbering

This project follows Semantic Versioning (SemVer):
- **MAJOR** version for incompatible changes
- **MINOR** version for new functionality in a backward-compatible manner
- **PATCH** version for backward-compatible bug fixes
