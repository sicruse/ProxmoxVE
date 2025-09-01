# ProxmoxVE T2 Mac Kernel Management - Source Tree Architecture

## Overview

This document outlines the complete source tree organization for the T2 Mac Kernel Management tool integration with ProxmoxVE community scripts. The structure follows community standards while accommodating the specific needs of T2 Mac hardware management.

## Repository Structure

### Root Directory Organization
```
ProxmoxVE/
├── docs/                           # Documentation root
│   ├── architecture/               # Architecture documentation
│   │   ├── coding-standards.md     # Development standards
│   │   ├── tech-stack.md          # Technology stack details
│   │   └── source-tree.md         # This document
│   ├── stories/                    # Development stories
│   ├── prd.md                     # Product requirements
│   └── architecture.md            # Main architecture document
├── tools/                         # Community tools directory
│   ├── pve/                       # ProxmoxVE infrastructure tools
│   │   └── t2mac.sh              # Main T2 Mac management tool
│   └── headers/                   # ASCII art headers
│       └── t2mac                  # T2 Mac tool header
├── frontend/                      # Web UI integration
│   └── public/
│       └── json/
│           └── t2mac.json         # Web UI metadata
├── testing/                       # Testing infrastructure
│   ├── unit/                      # Unit tests
│   ├── integration/               # Integration tests
│   ├── hardware/                  # Hardware simulation
│   ├── regression/                # Regression testing
│   └── end-to-end/               # Complete workflow tests
├── .ai/                          # AI development support
│   └── debug-log.md              # Development debug log
└── .bmad-core/                   # BMAD framework files
    └── core-config.yaml          # Project configuration
```

## Core Implementation Files

### Primary Tool Implementation

#### `tools/pve/t2mac.sh` - Main Tool Implementation
```bash
#!/usr/bin/env bash

# File: tools/pve/t2mac.sh
# Size: ~800-1000 lines (estimated after community integration)
# Purpose: Complete T2 Mac kernel management for ProxmoxVE hosts

# Structure:
# ├── Community Integration Header (lines 1-50)
# ├── Global Variables and Constants (lines 51-100)
# ├── Hardware Detection Functions (lines 101-250)
# ├── Kernel Management Functions (lines 251-450)
# ├── Fan Control Functions (lines 451-600)
# ├── User Interface Functions (lines 601-750)
# ├── Utility Functions (lines 751-850)
# └── Main Execution Flow (lines 851-1000)
```

**Key Sections:**

1. **Community Integration Header** (50 lines)
   - ProxmoxVE community script boilerplate
   - Build system integration
   - Standard variable initialization
   - Error handling setup

2. **Global Variables and Configuration** (50 lines)
   - T2-specific state variables
   - GitHub API configuration
   - Hardware detection settings
   - Service management constants

3. **Hardware Detection Module** (150 lines)
   - Multi-method Mac hardware detection
   - T2 chip capability verification
   - System information gathering
   - Hardware compatibility validation

4. **Kernel Management Module** (200 lines)
   - GitHub API integration
   - Version comparison logic
   - Package download and installation
   - Kernel removal and rollback

5. **Fan Control Module** (150 lines)
   - Sensor detection and configuration
   - t2fanrd service management
   - Module loading and validation
   - Service health monitoring

6. **User Interface Module** (150 lines)
   - Interactive menu system
   - Input validation and processing
   - Status display and reporting
   - Community messaging integration

7. **Utility Functions** (100 lines)
   - Helper functions and utilities
   - Error handling and recovery
   - File management and cleanup
   - Validation and safety checks

8. **Main Execution Flow** (150 lines)
   - Application initialization
   - Main menu loop
   - Command-line argument processing
   - Graceful shutdown and cleanup

#### `tools/headers/t2mac` - ASCII Art Header
```
File: tools/headers/t2mac
Size: ~20-30 lines
Purpose: ASCII art header for T2 Mac management tool

┌─────────────────────────────────────────────────────────────┐
│  ████████  ██████       ███    ███  █████   ██████         │
│     ██        ██        ████  ████ ██   ██ ██              │  
│     ██       ██         ██ ████ ██ ███████ ██              │
│     ██      ██          ██  ██  ██ ██   ██ ██              │
│     ██    ██████        ██      ██ ██   ██  ██████         │
│                                                             │
│            Kernel Management for ProxmoxVE                 │
└─────────────────────────────────────────────────────────────┘
```

### Community Integration Files

#### `frontend/public/json/t2mac.json` - Web UI Metadata
```json
{
  "name": "t2mac",
  "displayName": "T2 Mac Kernel Manager",
  "description": "Complete T2 Mac kernel and hardware management for ProxmoxVE hosts",
  "category": "System",
  "subcategory": "Kernel Management",
  "tags": ["system", "kernel", "mac", "hardware", "t2", "fan-control"],
  "author": "Community Scripts",
  "version": "1.0.0",
  "privileged": true,
  "osType": "proxmox",
  "requirements": {
    "hardware": ["Apple T2 Mac"],
    "os": "ProxmoxVE 8.0+",
    "privileges": "root"
  },
  "documentation": {
    "readme": "https://github.com/community-scripts/ProxmoxVE/blob/main/docs/t2mac.md",
    "troubleshooting": "https://github.com/community-scripts/ProxmoxVE/wiki/T2-Mac-Troubleshooting"
  },
  "support": {
    "issues": "https://github.com/community-scripts/ProxmoxVE/issues",
    "discussions": "https://github.com/community-scripts/ProxmoxVE/discussions"
  }
}
```

## Function Architecture and Organization

### Hardware Detection Module
```bash
# File: tools/pve/t2mac.sh (lines 101-250)

# Core detection functions:
detect_mac_hardware()           # Primary Mac detection logic
├── detect_via_dmi()           # DMI/SMBIOS detection method
├── detect_via_smc()           # SMC chip detection method  
├── detect_via_acpi()          # ACPI device tree method
└── detect_via_t2_devices()    # T2-specific device detection

check_t2_capabilities()         # T2 chip capability verification
├── check_bridge_controller()  # Bridge controller presence
├── check_t2_modules()         # Kernel module availability
└── validate_t2_features()     # Feature compatibility check

get_system_info()              # System information gathering
├── get_hardware_model()       # Mac model identification
├── get_kernel_version()       # Current kernel information
├── get_t2_status()           # T2 chip status and capabilities
└── get_sensor_info()         # Hardware sensor enumeration
```

### Kernel Management Module  
```bash
# File: tools/pve/t2mac.sh (lines 251-450)

# GitHub API integration:
get_latest_t2_version()        # Latest version retrieval
├── query_github_api()         # GitHub API communication
├── parse_release_info()       # Release information parsing
├── cache_version_info()       # Local version caching
└── handle_api_errors()        # API error handling and fallback

compare_kernel_versions()       # Version comparison logic
├── parse_version_string()     # Version string parsing
├── semantic_version_compare() # Semantic version comparison
└── determine_update_needed()  # Update requirement assessment

install_t2_kernel()            # Kernel installation workflow
├── download_kernel_packages() # Package download with progress
├── verify_package_integrity() # Package verification and validation
├── install_deb_packages()     # Debian package installation
├── update_boot_config()       # Boot configuration update
└── validate_installation()    # Installation success validation

remove_t2_kernel()             # Kernel removal workflow
├── identify_t2_packages()     # T2 package identification
├── create_removal_backup()    # Pre-removal backup creation
├── remove_packages_safely()   # Safe package removal
├── restore_boot_config()      # Boot configuration restoration
└── validate_removal()         # Removal success validation
```

### Fan Control Module
```bash
# File: tools/pve/t2mac.sh (lines 451-600)

# Sensor management:
configure_sensors()            # Hardware sensor configuration
├── detect_available_sensors() # Available sensor detection
├── configure_lm_sensors()     # lm-sensors configuration
├── setup_sensor_modules()     # Kernel module configuration
└── validate_sensor_config()   # Configuration validation

setup_t2fanrd()               # Fan daemon setup
├── install_t2fanrd_service() # Service installation
├── configure_fan_curves()    # Fan curve configuration  
├── setup_service_dependencies() # Service dependency setup
└── validate_fan_service()    # Service validation

manage_fan_service()          # Service lifecycle management
├── start_fan_service()       # Service startup
├── stop_fan_service()        # Service shutdown
├── restart_fan_service()     # Service restart
├── check_service_status()    # Service status checking
└── monitor_service_health()  # Service health monitoring
```

### User Interface Module
```bash
# File: tools/pve/t2mac.sh (lines 601-750)

# Interactive interface:
show_main_menu()              # Main menu display
├── display_current_status()  # System status information
├── show_menu_options()       # Available menu options
├── get_user_selection()      # User input processing
└── validate_menu_choice()    # Input validation

handle_user_input()           # Input processing and routing
├── process_install_request() # Installation request handling
├── process_remove_request()  # Removal request handling  
├── process_status_request()  # Status request handling
├── process_config_request()  # Configuration request handling
└── process_exit_request()    # Exit request handling

display_system_status()       # Status information display
├── show_hardware_info()      # Hardware information display
├── show_kernel_info()        # Kernel information display
├── show_service_status()     # Service status display
└── show_fan_status()         # Fan control status display
```

## Testing Infrastructure Organization

### Testing Directory Structure
```
testing/
├── unit/                      # Unit test files
│   ├── test_hardware_detection.sh    # Hardware detection tests
│   ├── test_version_comparison.sh    # Version comparison tests
│   ├── test_api_integration.sh       # GitHub API integration tests
│   └── test_fan_control.sh          # Fan control function tests
├── integration/               # Integration test files
│   ├── test_community_integration.sh # Community standards tests
│   ├── test_build_system.sh         # Build system integration tests
│   ├── test_messaging_system.sh     # Messaging system tests
│   └── test_error_handling.sh       # Error handling tests
├── hardware/                  # Hardware simulation framework
│   ├── mock_hardware.sh             # Hardware detection mocking
│   ├── simulate_t2_chip.sh          # T2 chip simulation
│   ├── simulate_sensors.sh          # Sensor simulation
│   └── test_hardware_matrix.sh      # Hardware compatibility testing
├── regression/                # Regression test suite
│   ├── compare_functionality.sh     # Functionality comparison
│   ├── test_original_workflows.sh   # Original workflow validation
│   ├── performance_benchmarks.sh    # Performance regression testing
│   └── safety_mechanism_tests.sh    # Safety mechanism validation
└── end-to-end/               # Complete workflow testing
    ├── full_installation_test.sh    # Complete installation workflow
    ├── removal_and_rollback_test.sh # Removal and rollback workflow
    ├── fan_control_integration.sh   # Fan control integration testing
    └── community_deployment_test.sh # Community deployment validation
```

### Test Framework Architecture
```bash
# Common test framework functions (testing/lib/test_framework.sh)

# Test execution framework:
run_test_suite()              # Test suite execution
├── setup_test_environment()  # Test environment initialization
├── execute_test_functions()  # Individual test execution
├── collect_test_results()    # Result collection and aggregation
├── generate_test_report()    # Test report generation
└── cleanup_test_environment() # Test environment cleanup

# Test utilities:
assert_equals()               # Equality assertion
assert_true()                # Boolean true assertion  
assert_false()               # Boolean false assertion
assert_contains()            # String containment assertion
assert_file_exists()         # File existence assertion
assert_service_running()     # Service status assertion

# Mock and simulation utilities:
mock_hardware_detection()    # Hardware detection mocking
mock_github_api()           # GitHub API response mocking
mock_package_installation() # Package installation mocking
simulate_user_input()       # User input simulation
```

## Configuration and Documentation Structure

### Documentation Organization
```
docs/
├── architecture/             # Architecture documentation
│   ├── coding-standards.md   # Development coding standards
│   ├── tech-stack.md        # Technology stack documentation
│   └── source-tree.md       # Source tree organization (this file)
├── stories/                 # Development stories and requirements
│   ├── story-1.0-development-environment-setup.md
│   ├── story-1.1-community-standards-compliance.md
│   ├── story-1.2-enhanced-hardware-detection.md
│   ├── story-1.3-github-api-integration.md
│   ├── story-1.4-community-documentation.md
│   ├── story-1.5-community-integration-testing.md
│   ├── story-1.6-testing-infrastructure-validation.md
│   └── story-1.7-community-integration-deployment.md
├── qa/                      # Quality assurance documentation
│   └── gates/               # QA gate definitions
│       ├── 1.1.0-development-environment-setup.yml
│       └── 1.2-enhanced-hardware-detection.yml
├── user/                    # User documentation (to be created)
│   ├── installation-guide.md       # Installation instructions
│   ├── usage-guide.md             # Usage documentation
│   ├── troubleshooting-guide.md   # Troubleshooting information
│   └── hardware-compatibility.md  # Hardware compatibility matrix
├── developer/               # Developer documentation (to be created)
│   ├── development-setup.md       # Development environment setup
│   ├── testing-guide.md          # Testing procedures and guidelines
│   ├── contribution-guide.md     # Community contribution guidelines
│   └── maintenance-guide.md      # Long-term maintenance procedures
├── prd.md                  # Product requirements document
└── architecture.md         # Main architecture document
```

### Configuration Files
```
.ai/
└── debug-log.md            # AI development debug log

.bmad-core/
└── core-config.yaml        # BMAD framework configuration

# Root-level configuration files:
.gitignore                  # Git ignore patterns
README.md                   # Project README (community standard)
LICENSE                     # Project license information
CHANGELOG.md                # Version history and changes
CONTRIBUTING.md             # Community contribution guidelines
```

## Development and Build Pipeline

### Development Workflow Files
```bash
# Development support files:
.github/                    # GitHub workflow integration (if applicable)
├── workflows/              # CI/CD pipeline definitions
│   ├── test.yml           # Automated testing workflow
│   ├── lint.yml           # Code quality checking
│   └── community-review.yml # Community review process
└── ISSUE_TEMPLATE/         # Issue templates
    ├── bug_report.md       # Bug report template
    ├── feature_request.md  # Feature request template
    └── community_question.md # Community question template

scripts/                    # Development utility scripts
├── setup-dev-env.sh       # Development environment setup
├── run-tests.sh           # Test execution wrapper
├── lint-code.sh           # Code linting utility
├── build-distribution.sh  # Distribution package creation
└── validate-community.sh  # Community standards validation
```

### Code Organization Patterns

#### Function Grouping Strategy
```bash
# tools/pve/t2mac.sh organization pattern:

#######################################################################
# SECTION 1: COMMUNITY INTEGRATION AND INITIALIZATION
#######################################################################
source <(curl -fsSL .../misc/build.func)  # Community framework
header_info "$APP"                         # Standard initialization
variables && color && catch_errors         # Community setup

#######################################################################  
# SECTION 2: GLOBAL CONFIGURATION AND CONSTANTS
#######################################################################
readonly T2_GITHUB_REPO="AdityaGarg8/pve-edge-kernel-t2"
readonly T2_FANRD_SERVICE="t2fanrd"
readonly BACKUP_SUFFIX=".t2mac.backup"

#######################################################################
# SECTION 3: HARDWARE DETECTION MODULE
#######################################################################
detect_mac_hardware() { ... }
check_t2_capabilities() { ... }
get_system_info() { ... }

#######################################################################
# SECTION 4: KERNEL MANAGEMENT MODULE  
#######################################################################
get_latest_t2_version() { ... }
compare_kernel_versions() { ... }
install_t2_kernel() { ... }
remove_t2_kernel() { ... }

#######################################################################
# SECTION 5: FAN CONTROL MODULE
#######################################################################
configure_sensors() { ... }
setup_t2fanrd() { ... }
manage_fan_service() { ... }

#######################################################################
# SECTION 6: USER INTERFACE MODULE
#######################################################################
show_main_menu() { ... }
handle_user_input() { ... }
display_system_status() { ... }

#######################################################################
# SECTION 7: UTILITY AND HELPER FUNCTIONS
#######################################################################
create_backup() { ... }
cleanup_temporary_files() { ... }
validate_prerequisites() { ... }

#######################################################################
# SECTION 8: MAIN EXECUTION FLOW
#######################################################################
main() { ... }
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
```

This source tree architecture provides a clear, maintainable, and scalable organization that supports the complex functionality of T2 Mac kernel management while adhering to ProxmoxVE community standards and best practices.