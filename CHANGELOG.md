# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
