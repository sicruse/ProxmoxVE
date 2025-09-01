# ProxmoxVE T2 Mac Kernel Management - Coding Standards

## Overview

This document defines coding standards for the T2 Mac Kernel Management tool integration with ProxmoxVE community scripts. These standards ensure consistency, maintainability, and compatibility with the broader community ecosystem.

## Bash Scripting Standards

### Script Structure

```bash
#!/usr/bin/env bash

# Standard PVE infrastructure tool header
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# Application metadata
APP="T2 Mac Kernel Manager"
var_tags="${var_tags:-system;kernel;mac}"
var_unprivileged="${var_unprivileged:-0}"

# Community initialization
header_info "$APP"
variables
color
catch_errors

# Main functionality implementation
start
```

### Variable Naming Conventions

#### PVE Standard Variables
```bash
# System configuration variables
var_cpu="1"           # CPU cores
var_ram="512"         # RAM in MB  
var_disk="1"          # Disk size in GB
var_os="proxmox"      # Operating system
var_unprivileged="0"  # Privilege level
```

#### T2-Specific Variables
```bash
# T2 kernel state variables
T2_KERNEL_INSTALLED=""    # Installation count
IS_MAC_HARDWARE=""        # Hardware detection result
LATEST_T2_VER=""         # Latest available version
T2_FANRD_ACTIVE=""       # Fan service status
KERNEL_ON=""             # Current kernel version
```

#### Community Color Variables
```bash
# Standard PVE color definitions
YW=$(echo "\033[33m")     # Yellow
RD=$(echo "\033[01;31m")  # Red
GN=$(echo "\033[1;92m")   # Green
CL=$(echo "\033[m")       # Clear
BFR="\\r\\033[K"          # Buffer clear
HOLD="-"                  # Hold character
CM="${GN}✓${CL}"         # Check mark
CROSS="${RD}✗${CL}"      # Cross mark
```

### Function Organization

#### Function Naming Pattern
```bash
# Hardware detection functions
detect_mac_hardware()      # Multi-method Mac detection
check_t2_capabilities()    # T2-specific feature detection
get_system_info()          # System information gathering

# Kernel management functions
get_latest_t2_version()    # GitHub API integration
compare_kernel_versions()  # Version comparison logic
install_t2_kernel()        # Installation workflow
remove_t2_kernel()         # Removal workflow

# Fan control functions
configure_sensors()        # Hardware sensor setup
setup_t2fanrd()           # Fan daemon configuration
validate_fan_service()    # Service health checks

# Interface functions
show_main_menu()           # Interactive menu system
handle_user_input()       # Input processing and validation
display_system_status()   # Status information display
```

#### Function Structure Template
```bash
function example_function() {
    # Function documentation comment
    # Parameters: $1 - description
    # Returns: 0 on success, 1 on error
    
    local param1="$1"
    local result=""
    
    # Validation
    if [[ -z "$param1" ]]; then
        msg_error "Parameter required"
        return 1
    fi
    
    # Implementation
    msg_info "Processing $param1"
    
    # Main logic here
    
    if [[ $? -eq 0 ]]; then
        msg_ok "Operation completed successfully"
        return 0
    else
        msg_error "Operation failed"
        return 1
    fi
}
```

### Messaging Standards

#### Community Messaging Functions
```bash
# Information messages
msg_info "Detecting Mac hardware"
msg_info "Downloading T2 kernel packages"
msg_info "Configuring fan control"

# Success messages
msg_ok "Mac hardware detected successfully"
msg_ok "T2 kernel installation complete"
msg_ok "Fan control configured"

# Warning messages
msg_warn "Latest kernel already installed"
msg_warn "No active swap detected"

# Error messages
msg_error "Root privileges required"
msg_error "Hardware detection failed"
```

#### Custom Status Display
```bash
# Status formatting with community colors
echo "${GN}Current Status:${CL}"
echo "  Kernel: ${YW}${KERNEL_ON}${CL}"
echo "  Hardware: ${CM} T2 Mac Detected"
echo "  Fan Service: ${T2_FANRD_ACTIVE}"
```

### Error Handling Standards

#### Community Error Handling
```bash
# Use community error handling patterns
set -euo pipefail

# Community error catching
catch_errors

# Custom error handling for T2-specific operations
handle_t2_error() {
    local exit_code="$1"
    local operation="$2"
    
    case "$exit_code" in
        1) msg_error "General error in $operation" ;;
        2) msg_error "Hardware not detected for $operation" ;;
        3) msg_error "Network error during $operation" ;;
        4) msg_error "Permission denied for $operation" ;;
        *) msg_error "Unknown error ($exit_code) in $operation" ;;
    esac
}
```

#### Safe Operations Pattern
```bash
# Safe system modification pattern
function safe_system_operation() {
    local operation="$1"
    local backup_created=false
    
    # Create backup if needed
    if create_backup; then
        backup_created=true
        msg_info "Backup created for safety"
    fi
    
    # Attempt operation
    if ! execute_operation "$operation"; then
        msg_error "Operation failed"
        
        # Restore backup if available
        if [[ "$backup_created" == true ]]; then
            msg_info "Restoring from backup"
            restore_backup
        fi
        
        return 1
    fi
    
    msg_ok "Operation completed successfully"
    return 0
}
```

## Code Quality Standards

### Input Validation
```bash
# Parameter validation pattern
validate_parameters() {
    local required_params=("$@")
    
    for param in "${required_params[@]}"; do
        if [[ -z "${!param}" ]]; then
            msg_error "Required parameter '$param' not provided"
            return 1
        fi
    done
}

# User input validation
validate_user_choice() {
    local choice="$1"
    local valid_choices=("$@")
    
    for valid in "${valid_choices[@]:1}"; do
        if [[ "$choice" == "$valid" ]]; then
            return 0
        fi
    done
    
    msg_error "Invalid choice: $choice"
    return 1
}
```

### Security Best Practices
```bash
# Secure temporary file handling
create_temp_file() {
    local temp_file
    temp_file=$(mktemp) || {
        msg_error "Failed to create temporary file"
        return 1
    }
    
    # Set restrictive permissions
    chmod 600 "$temp_file"
    
    echo "$temp_file"
}

# Safe command execution
execute_safe_command() {
    local cmd="$1"
    
    # Log command for debugging (without sensitive data)
    msg_info "Executing: ${cmd//password=*/password=***}"
    
    # Execute with error handling
    if ! eval "$cmd"; then
        msg_error "Command execution failed"
        return 1
    fi
}
```

### Documentation Standards

#### Function Documentation
```bash
# Function documentation template
function example_function() {
    # Brief description of function purpose
    #
    # Arguments:
    #   $1 - parameter description
    #   $2 - optional parameter description (optional)
    #
    # Returns:
    #   0 - success
    #   1 - general error
    #   2 - specific error condition
    #
    # Example:
    #   example_function "value1" "value2"
    
    # Implementation here
}
```

#### Inline Comments
```bash
# Use comments to explain complex logic
if detect_mac_hardware; then
    # Hardware detection succeeded, proceed with T2-specific checks
    if check_t2_capabilities; then
        # T2 chip detected, enable full functionality
        T2_CAPABLE=true
    else
        # Mac hardware without T2 chip, limited functionality
        T2_CAPABLE=false
        msg_warn "Mac hardware detected but T2 chip not found"
    fi
else
    # Not Mac hardware, exit gracefully
    msg_error "This tool is designed for Apple Mac hardware"
    exit 1
fi
```

## Testing Standards

### Test Function Structure
```bash
# Test function naming and structure
test_hardware_detection() {
    local test_name="Hardware Detection Test"
    local result=0
    
    msg_info "Running $test_name"
    
    # Test setup
    setup_test_environment
    
    # Test execution
    if detect_mac_hardware; then
        msg_ok "$test_name passed"
    else
        msg_error "$test_name failed"
        result=1
    fi
    
    # Test cleanup
    cleanup_test_environment
    
    return $result
}
```

### Validation Patterns
```bash
# State validation pattern
validate_system_state() {
    local errors=0
    
    # Check prerequisites
    if ! command -v dmidecode >/dev/null 2>&1; then
        msg_error "dmidecode not found"
        ((errors++))
    fi
    
    if ! command -v systemctl >/dev/null 2>&1; then
        msg_error "systemctl not found"
        ((errors++))
    fi
    
    # Check permissions
    if [[ $EUID -ne 0 ]]; then
        msg_error "Root privileges required"
        ((errors++))
    fi
    
    if [[ $errors -gt 0 ]]; then
        msg_error "System validation failed with $errors errors"
        return 1
    fi
    
    msg_ok "System validation passed"
    return 0
}
```

## Performance Standards

### Efficient Operations
```bash
# Cache expensive operations
get_system_info_cached() {
    local cache_file="/tmp/t2mac_system_info"
    local cache_max_age=300  # 5 minutes
    
    # Check if cache is valid
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
        if [[ $cache_age -lt $cache_max_age ]]; then
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Generate fresh data and cache it
    get_system_info > "$cache_file"
    cat "$cache_file"
}

# Parallel operations where safe
parallel_checks() {
    local pids=()
    
    # Start background checks
    check_kernel_version &
    pids+=($!)
    
    check_hardware_status &
    pids+=($!)
    
    check_service_status &
    pids+=($!)
    
    # Wait for all checks to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}
```

### Resource Management
```bash
# Cleanup pattern
cleanup_resources() {
    local temp_files=("$@")
    
    for file in "${temp_files[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
        fi
    done
    
    # Kill any background processes
    jobs -p | xargs -r kill 2>/dev/null || true
}

# Ensure cleanup on exit
trap cleanup_resources EXIT
```

## Community Integration Standards

### Build System Compatibility
```bash
# Standard build function integration
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# Required metadata
APP="T2 Mac Kernel Manager"
var_tags="${var_tags:-system;kernel;mac}"
var_unprivileged="${var_unprivileged:-0}"

# Standard initialization sequence
header_info "$APP"
variables
color  
catch_errors
```

### Variable Compatibility
```bash
# Use community standard variables where applicable
# and extend with T2-specific variables
function initialize_variables() {
    # Community standards
    variables  # Initialize standard community variables
    
    # T2-specific extensions
    T2_KERNEL_INSTALLED=""
    IS_MAC_HARDWARE=""
    LATEST_T2_VER=""
    T2_FANRD_ACTIVE=""
    KERNEL_ON=""
}
```

This coding standards document provides comprehensive guidelines for maintaining consistency and quality in the T2 Mac Kernel Management tool development while ensuring seamless integration with the ProxmoxVE community scripts ecosystem.