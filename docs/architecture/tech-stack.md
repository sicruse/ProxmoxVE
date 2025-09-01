# ProxmoxVE T2 Mac Kernel Management - Technology Stack

## Overview

This document outlines the complete technology stack for the T2 Mac Kernel Management tool integration with ProxmoxVE community scripts. The stack leverages proven technologies from the existing standalone implementation while adopting community standards.

## Core Technology Stack

### Primary Language and Runtime

#### Bash Shell Scripting
- **Version**: Bash 4.4+ (ProxmoxVE standard)
- **Compatibility**: POSIX shell compliance where possible
- **Rationale**: Native Linux scripting environment, community standard
- **Key Features**:
  - Advanced parameter expansion
  - Array support for hardware detection methods
  - Function definition and modular organization
  - Built-in error handling with `set -euo pipefail`

```bash
#!/usr/bin/env bash
# Bash-specific features utilized:
# - Associative arrays for version mapping
# - Advanced parameter expansion ${var:-default}
# - Function return values and local scope
# - Built-in regex matching with [[ =~ ]]
```

### System Integration Layer

#### Linux System Tools
- **dmidecode**: Hardware detection and DMI table parsing
- **systemctl**: Service management (t2fanrd, modules)
- **dpkg**: Debian package management for kernel installation
- **apt**: Package dependency resolution and updates
- **modprobe**: Kernel module loading for sensors and fan control
- **sensors-detect**: Hardware sensor discovery and configuration

#### ProxmoxVE Integration
- **proxmox-boot-tool**: Kernel boot configuration management
- **pve-kernel packages**: ProxmoxVE kernel package system integration
- **ProxmoxVE 8.x+**: Target platform compatibility
- **Community Scripts Framework**: Build and messaging system integration

### Network and API Integration

#### GitHub API Integration
- **REST API v3**: Repository information and release data
- **curl**: HTTP client for API requests and file downloads
- **jq**: JSON parsing for API responses (when available)
- **Rate Limiting**: GitHub API rate limit handling (5000 req/hour authenticated)

```bash
# GitHub API endpoints used:
# - https://api.github.com/repos/AdityaGarg8/pve-edge-kernel-t2/releases/latest
# - https://api.github.com/repos/AdityaGarg8/pve-edge-kernel-t2/releases
# - Direct download URLs for .deb packages
```

#### Network Tools
- **curl**: Primary HTTP client with retry logic and error handling
- **wget**: Fallback download tool for package retrieval
- **Network Error Handling**: Offline operation support and graceful degradation

### Hardware Detection Stack

#### Multi-Method Hardware Detection
```bash
# Detection method hierarchy:
1. DMI/SMBIOS Detection (dmidecode)
   - System manufacturer identification
   - Product name parsing for Mac models
   - BIOS version checking for T2 indicators

2. SMC (System Management Controller) Detection
   - Direct SMC chip communication
   - Temperature sensor enumeration
   - Fan control capability detection

3. ACPI Detection
   - Device tree analysis for Apple-specific entries  
   - T2 security chip identification
   - Bridge controller detection

4. T2-Specific Device Detection
   - /dev/bridgecontroller presence
   - Kernel module availability
   - Driver compatibility checking
```

#### Hardware Compatibility Matrix
| Mac Model | Year | T2 Chip | Detection Methods | Support Status |
|-----------|------|---------|-------------------|----------------|
| MacBook Pro 13" | 2018-2020 | Yes | DMI+SMC+ACPI | Full Support |
| MacBook Pro 16" | 2019-2020 | Yes | DMI+SMC+ACPI | Full Support |
| Mac Mini | 2018-2020 | Yes | DMI+SMC+ACPI | Full Support |
| iMac Pro | 2017-2019 | Yes | DMI+SMC+ACPI | Full Support |
| Mac Studio | 2022+ | M1/M2 | N/A | Not Supported |

### Package Management Integration

#### T2 Edge Kernel Packages
- **Repository**: AdityaGarg8/pve-edge-kernel-t2 (GitHub)
- **Package Format**: Debian (.deb) packages
- **Package Types**:
  - `pve-kernel-*-t2` - Main kernel packages
  - `pve-headers-*-t2` - Kernel headers for development
  - `linux-firmware` - Updated firmware packages

#### Dependency Management
```bash
# Core dependencies managed:
pve-kernel-{version}-t2        # T2-patched kernel
linux-firmware                # Updated T2 firmware
apple-gmux                    # Graphics switching support
apple-t2-audio-config         # Audio configuration
apple-bce                     # Bridge controller driver
```

### Service Management Stack

#### Fan Control System
- **t2fanrd**: T2-specific fan daemon
- **lm-sensors**: Hardware monitoring framework
- **systemd**: Service lifecycle management
- **Module System**: Kernel module loading and configuration

```bash
# Service architecture:
t2fanrd.service               # Main fan control daemon
├── Depends: lm-sensors       # Hardware monitoring
├── Requires: apple-bce.ko    # Bridge controller module
└── After: multi-user.target  # System initialization
```

#### Configuration Management
- **systemd unit files**: Service definitions and dependencies
- **/etc/modules**: Persistent module loading configuration
- **/etc/sensors.d/**: Hardware sensor configuration
- **systemctl**: Service control and status management

### Community Integration Framework

#### ProxmoxVE Community Scripts Architecture
```bash
# Community framework components:
source <(curl -fsSL .../misc/build.func)  # Build system integration
├── header_info()                          # Header display system
├── variables()                           # Standard variable initialization  
├── color()                               # Color scheme setup
├── catch_errors()                        # Community error handling
└── msg_*() functions                     # Messaging system
```

#### Standard Community Functions
- **msg_info()**: Information messages with standard formatting
- **msg_ok()**: Success messages with check marks
- **msg_warn()**: Warning messages with appropriate styling
- **msg_error()**: Error messages with consistent formatting
- **header_info()**: Application header display with ASCII art

### Build and Distribution System

#### Distribution Architecture
```bash
ProxmoxVE/
├── tools/pve/t2mac.sh           # Main executable script
├── tools/headers/t2mac          # ASCII art header
└── frontend/public/json/t2mac.json  # Web UI metadata
```

#### Web UI Integration
```json
{
  "name": "t2mac",
  "displayName": "T2 Mac Kernel Manager", 
  "description": "Manage T2 Mac kernels and fan control",
  "category": "System",
  "tags": ["system", "kernel", "mac", "hardware"],
  "privileged": true,
  "osType": "proxmox"
}
```

### Development and Testing Stack

#### Development Environment
- **Git**: Version control with GitHub integration
- **VS Code / vim**: Development environment with bash language support
- **shellcheck**: Static analysis for bash scripts
- **Test Frameworks**: Custom testing suite for hardware simulation

#### Testing Infrastructure
```bash
# Testing stack components:
tests/
├── unit/                    # Individual function testing
├── integration/             # Community integration tests
├── hardware/               # Hardware simulation framework  
├── regression/             # Existing functionality validation
└── end-to-end/             # Complete workflow testing
```

#### Hardware Simulation
```bash
# Mock hardware detection for development:
MOCK_MAC_HARDWARE=true       # Enable hardware simulation
MOCK_T2_CHIP=true           # Simulate T2 chip presence  
MOCK_SENSORS=true           # Simulate hardware sensors
MOCK_GITHUB_API=true        # Use local API responses
```

## External Dependencies and Integration

### GitHub Repository Dependencies
- **AdityaGarg8/pve-edge-kernel-t2**: Primary T2 kernel repository
- **community-scripts/ProxmoxVE**: Community scripts framework
- **Stable Internet Connection**: For initial setup and updates
- **GitHub API Access**: For version checking and downloads

### System Prerequisites
```bash
# Required system components:
ProxmoxVE 8.0+              # Target platform
Apple T2 Mac Hardware       # Compatible hardware platform
Root/sudo access            # Administrative privileges
Internet connectivity       # GitHub API and downloads
dmidecode utility           # Hardware detection
systemctl (systemd)        # Service management
```

### Optional Dependencies
- **jq**: Enhanced JSON parsing (fallback: manual parsing)
- **sensors**: Hardware monitoring utilities  
- **curl progress**: Enhanced download progress display
- **Network caching**: Local API response caching

## Performance and Resource Requirements

### System Resource Usage
- **Memory**: <50MB RAM during execution
- **Disk Space**: 500MB temporary space for package downloads
- **Network**: ~100MB for full T2 kernel download
- **CPU**: Minimal - primarily I/O bound operations

### Performance Characteristics
```bash
# Typical operation times:
Hardware Detection:          <5 seconds
GitHub API Version Check:    1-3 seconds  
Kernel Package Download:     2-10 minutes (network dependent)
Installation Process:        5-15 minutes
Fan Control Configuration:   10-30 seconds
Service Management:          5-10 seconds
```

### Scalability Considerations
- **API Rate Limiting**: Intelligent caching to minimize GitHub API calls
- **Network Resilience**: Offline operation support where possible
- **Resource Cleanup**: Automatic temporary file management
- **Background Operations**: Non-blocking operations where appropriate

## Security Architecture

### Security Model
```bash
# Security considerations:
Root Privilege Requirement   # System-level kernel management
Input Validation            # All user inputs validated
Temporary File Security     # Secure temp file creation (600 permissions)
Package Signature Verification  # Verify downloaded packages
Network Security           # HTTPS-only connections
```

### Trust Boundaries
- **GitHub Repository Trust**: Trusted source for T2 kernels
- **Package Integrity**: SHA verification of downloads
- **System Modification Safety**: Backup and rollback capabilities
- **Network Communication**: Encrypted HTTPS connections only

## Integration Standards Compliance

### ProxmoxVE Community Standards
- **Coding Style**: Community bash scripting standards
- **Error Handling**: Consistent error patterns and messages
- **User Interface**: Standard community messaging and formatting
- **Documentation**: Inline help and comprehensive documentation

### Compatibility Matrix
| Component | Version Requirement | Compatibility |
|-----------|-------------------|---------------|
| ProxmoxVE | 8.0+ | Required |
| Bash | 4.4+ | Required |
| systemd | 240+ | Required |  
| curl | 7.68+ | Required |
| dmidecode | 3.2+ | Required |
| dpkg | 1.19+ | Required |

This technology stack provides a robust, scalable, and maintainable foundation for the T2 Mac Kernel Management tool while ensuring seamless integration with the ProxmoxVE community ecosystem.