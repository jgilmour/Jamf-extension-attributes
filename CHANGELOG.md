# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
