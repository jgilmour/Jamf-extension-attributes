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

Current version: 1.0.0
See [CHANGELOG.md](CHANGELOG.md) for version history.
