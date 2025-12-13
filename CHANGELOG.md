# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
