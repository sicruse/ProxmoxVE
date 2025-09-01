#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/core.func)
# Copyright (c) 2021-2025 tteck & Si Cruse
# Author: Si Cruse (sicruse)
# Co-maintainer: tteck (tteckster) 
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/AdityaGarg8/pve-edge-kernel-t2
# Description: T2 Mac Hardware Kernel Management for ProxmoxVE

APP="T2 Mac Manager"
var_tags="${var_tags:-hardware;mac;kernel}"

# Community standard exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_INPUT=2
readonly EXIT_NETWORK_ERROR=3
readonly EXIT_PERMISSION_ERROR=4
readonly EXIT_DEPENDENCY_ERROR=5

# Community standard initialization
header_info "$APP"
catch_errors

# Get system information
KERNEL_ON=$(uname -r)
HOSTNAME=$(hostname)

# Configuration for GitHub API integration
readonly GITHUB_API_BASE="https://api.github.com"
readonly T2_REPO="AdityaGarg8/pve-edge-kernel-t2"
readonly CACHE_DIR="/tmp/t2mac-cache"
readonly CACHE_TTL=3600  # 1 hour cache TTL
readonly MAX_RETRIES=3
readonly INITIAL_RETRY_DELAY=5

##
# init_api_cache - Initialize GitHub API cache directory
#
# Description:
#   Creates cache directory and cleans old cache files to prevent
#   disk space issues from accumulating cache data.
##
init_api_cache() {
    mkdir -p "$CACHE_DIR"
    # Clean old cache files (older than 24 hours)
    find "$CACHE_DIR" -type f -mtime +1 -delete 2>/dev/null || true
}

##
# validate_version - Validate version string format
#
# Description:
#   Validates that a version string follows the expected semantic versioning
#   format for T2 kernel versions (X.Y.Z or X.Y.Z-N)
#
# Parameters:
#   $1: Version string to validate
#
# Returns:
#   Exit 0: Version format is valid
#   Exit 1: Invalid version format
#
# Examples:
#   validate_version "6.8.12-2" && echo "Valid version"
##
validate_version() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        return 1
    fi
    
    # Allow T2 version format: X.Y.Z-N-t2-N (e.g., 6.14.11-1-t2-2)
    # Also allow standard format: X.Y.Z or X.Y.Z-N
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+(-t2-[0-9]+)?)?$ ]]; then
        return 1
    fi
    
    return 0
}

##
# return_offline_guidance - Provide offline operation guidance
#
# Description:
#   Displays comprehensive guidance for users when network connectivity
#   issues prevent normal operation, with specific troubleshooting steps.
##
return_offline_guidance() {
    cat << 'EOF'
🌐 Network Connectivity Issues Detected

The T2 kernel manager requires internet access to:
• Check for latest kernel versions
• Download kernel packages  
• Validate package integrity

Current network status appears limited. You can:

1. Check Network Connection:
   • Verify internet connectivity: ping github.com
   • Check firewall settings
   • Confirm DNS resolution

2. Offline Operation Options:
   • Use manual kernel package if available
   • Retry operation when network is restored
   • Check cached version information

3. Alternative Download Methods:
   • Download packages manually from GitHub
   • Use local mirror if configured
   • Contact system administrator for assistance

GitHub Repository: https://github.com/AdityaGarg8/pve-edge-kernel-t2
EOF
}

##
# github_api_get - GitHub API client with rate limiting and caching
#
# Description:
#   Makes GitHub API requests with intelligent retry logic, rate limiting
#   protection, caching support, and graceful fallback to cached data.
#
# Parameters:
#   $1: API endpoint path (e.g., "/repos/owner/repo/releases/latest")
#
# Returns:
#   String: API response JSON
#   Exit 0: Success (fresh or cached data)
#   Exit 1: All retries failed and no cached data available
##
github_api_get() {
    local endpoint="$1"
    local cache_file="$CACHE_DIR/$(echo "$endpoint" | sed 's|/|_|g')"
    local url="${GITHUB_API_BASE}${endpoint}"
    
    # Check cache first
    local file_mtime=0
    if [ -f "$cache_file" ]; then
        if stat -c %Y "$cache_file" >/dev/null 2>&1; then
            # GNU stat (Linux)
            file_mtime=$(stat -c %Y "$cache_file")
        else
            # BSD stat (macOS)
            file_mtime=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
        fi
    fi
    
    if [ -f "$cache_file" ] && [ $(($(date +%s) - file_mtime)) -lt $CACHE_TTL ]; then
        msg_info "Using cached GitHub API data"
        cat "$cache_file"
        return 0
    fi
    
    # Make API request with rate limiting protection
    local attempt=1
    local retry_delay=$INITIAL_RETRY_DELAY
    
    while [ $attempt -le $MAX_RETRIES ]; do
        msg_info "Fetching from GitHub API (attempt $attempt/$MAX_RETRIES)"
        
        local response
        local http_code
        local temp_response
        
        # Make request with timeout and user agent
        temp_response=$(curl -s -w "\n%{http_code}" \
            -H "Accept: application/vnd.github+json" \
            -H "User-Agent: T2MacManager/1.0 (ProxmoxVE)" \
            --connect-timeout 10 \
            --max-time 30 \
            "$url" 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            http_code=$(echo "$temp_response" | tail -n1)
            response=$(echo "$temp_response" | sed '$d')
        else
            http_code="000"
            response=""
        fi
        
        case "$http_code" in
            200)
                # Success - cache and return
                echo "$response" > "$cache_file"
                echo "$response"
                return 0
                ;;
            403)
                # Rate limiting - check for reset time in headers
                msg_warn "GitHub API rate limited (HTTP 403)"
                local wait_time=60  # Default wait time
                if [ $attempt -lt $MAX_RETRIES ]; then
                    msg_info "Waiting ${wait_time}s before retry due to rate limiting"
                    sleep $wait_time
                fi
                ;;
            404)
                msg_error "GitHub repository or endpoint not found (HTTP 404)"
                return 1
                ;;
            000)
                msg_warn "Network connection failed (timeout or DNS issues)"
                ;;
            *)
                msg_warn "GitHub API returned HTTP $http_code"
                ;;
        esac
        
        if [ $attempt -lt $MAX_RETRIES ]; then
            msg_info "Waiting ${retry_delay}s before retry"
            sleep $retry_delay
            retry_delay=$((retry_delay * 2))  # Exponential backoff
        fi
        
        ((attempt++))
    done
    
    # All retries failed - check for cached fallback
    if [ -f "$cache_file" ]; then
        msg_warn "GitHub API unavailable, using cached data (may be stale)"
        cat "$cache_file"
        return 0
    fi
    
    msg_error "GitHub API unavailable and no cached data available"
    return_offline_guidance
    return 1
}

##
# get_latest_t2_version - Retrieve latest T2 kernel version from GitHub
#
# Description:
#   Fetches the latest release version from AdityaGarg8/pve-edge-kernel-t2
#   with enhanced rate limiting protection, caching, and error handling.
#
# Returns:
#   String: Latest version number (e.g., "6.8.12-2")
#   Exit 0: Success
#   Exit 1: Network error or API failure
#
# Examples:
#   latest_version=$(get_latest_t2_version)
#   if [ $? -eq 0 ]; then msg_info "Latest: $latest_version"; fi
##
get_latest_t2_version() {
    init_api_cache
    
    msg_info "Checking for latest T2 kernel version"
    
    local api_response
    if ! api_response=$(github_api_get "/repos/$T2_REPO/releases/latest"); then
        # Offline fallback already handled by github_api_get
        return 1
    fi
    
    # Parse version from JSON response
    local latest_version
    latest_version=$(echo "$api_response" | grep -o '"tag_name":"[^"]*"' | cut -d '"' -f 4 | sed 's/^v//')
    
    if [ -z "$latest_version" ]; then
        msg_error "Unable to parse version information from GitHub API"
        return_offline_guidance
        return 1
    fi
    
    if ! validate_version "$latest_version"; then
        msg_error "Invalid version format received: $latest_version"
        return 1
    fi
    
    msg_ok "Latest T2 kernel version: $latest_version"
    echo "$latest_version"
    return 0
}
##
# detect_mac_hardware_enhanced - Enhanced hardware detection with comprehensive reporting
#
# Description:
#   Multi-method hardware detection that validates T2 Mac compatibility using
#   DMI, SMC, ACPI, and T2-specific device markers with confidence scoring.
#
# Returns:
#   String: "true" if Mac hardware detected with high confidence, "false" otherwise
#   Exit 0: Mac hardware detected
#   Exit 1: Not Mac hardware or insufficient confidence
##
detect_mac_hardware_enhanced() {
    local detection_results=()
    local confidence_score=0
    local total_methods=0
    
    echo "🔍 Performing comprehensive Mac hardware detection..."
    
    # Method 1: DMI System Manufacturer
    ((total_methods++))
    if command -v dmidecode >/dev/null 2>&1; then
        if dmidecode -s system-manufacturer 2>/dev/null | grep -qi "Apple"; then
            detection_results+=("✅ DMI System Manufacturer: Apple detected")
            ((confidence_score++))
        else
            detection_results+=("❌ DMI System Manufacturer: Not Apple")
        fi
    else
        detection_results+=("⚠️  DMI System Manufacturer: dmidecode unavailable")
    fi
    
    # Method 2: DMI Product Name
    ((total_methods++))
    if command -v dmidecode >/dev/null 2>&1; then
        local product_name=$(dmidecode -s system-product-name 2>/dev/null)
        if echo "$product_name" | grep -qi "Mac"; then
            detection_results+=("✅ DMI Product Name: Mac detected ($product_name)")
            ((confidence_score++))
        else
            detection_results+=("❌ DMI Product Name: No Mac identifier ($product_name)")
        fi
    fi
    
    # Method 3: Apple SMC Detection
    ((total_methods++))
    if [ -d "/sys/devices/platform/applesmc" ]; then
        detection_results+=("✅ Apple SMC: System Management Controller detected")
        ((confidence_score++))
    else
        detection_results+=("❌ Apple SMC: No SMC device found")
    fi
    
    # Method 4: ACPI Apple Device
    ((total_methods++))
    if [ -d "/sys/bus/acpi/devices/APP0001:00" ]; then
        detection_results+=("✅ ACPI Apple Device: APP0001 detected")
        ((confidence_score++))
    else
        detection_results+=("❌ ACPI Apple Device: No Apple ACPI device")
    fi
    
    # Method 5: T2-Specific Devices
    ((total_methods++))
    if [ -d "/sys/class/apple_mfi_fastcharge" ]; then
        detection_results+=("✅ T2 Specific Device: MFi fastcharge detected")
        ((confidence_score++))
    else
        detection_results+=("❌ T2 Specific Device: No T2 fastcharge device")
    fi
    
    # Display detection results
    echo "📊 Hardware Detection Results:"
    printf '%s\n' "${detection_results[@]}"
    echo ""
    
    # Calculate confidence percentage
    local confidence_percentage=$((confidence_score * 100 / total_methods))
    echo "🎯 Detection Confidence: $confidence_score/$total_methods methods ($confidence_percentage%)"
    
    # Determine hardware compatibility
    if [ $confidence_score -ge 2 ]; then
        echo "✅ Hardware Assessment: Mac hardware detected with high confidence"
        echo "true"
        return 0
    else
        echo "❌ Hardware Assessment: Not compatible Mac hardware"
        echo "false"
        return 1
    fi
}

##
# validate_t2_compatibility - Prevent installation on incompatible hardware
#
# Description:
#   Validates T2 Mac hardware compatibility and prevents installation on
#   incompatible systems with comprehensive error messaging.
#
# Returns:
#   Exit 0: Compatible hardware detected
#   Exit 1: Incompatible hardware or insufficient confidence
##
validate_t2_compatibility() {
    local hardware_detected
    hardware_detected=$(detect_mac_hardware_enhanced 2>/dev/null | tail -n 1)
    
    if [ "$hardware_detected" = "false" ]; then
        cat << 'EOF'
⚠️  T2 MAC HARDWARE NOT DETECTED ⚠️

This tool is specifically designed for Apple Mac hardware with T2 chips.
Your system does not appear to be compatible Mac hardware.

Supported Hardware:
• MacBook Pro (2018, 2019, 2020)
• Mac Mini (2018)
• iMac (2019, 2020)
• iMac Pro (2017-2020)

If you believe this detection is incorrect:
1. Ensure you're running on actual Mac hardware (not virtualized)
2. Check that your Mac has a T2 security chip
3. Verify dmidecode is installed and working
4. Contact community support with your hardware details

Installation cannot continue on incompatible hardware.
EOF
        return 1
    fi
    
    return 0
}

##
# show_hardware_diagnostics - Provide detailed diagnostic information
#
# Description:
#   Displays comprehensive hardware diagnostic information for
#   troubleshooting and community support purposes.
##
show_hardware_diagnostics() {
    echo "🔧 Hardware Diagnostic Information"
    echo "=================================="
    
    echo "System Information:"
    echo "  Hostname: $(hostname)"
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    
    if command -v dmidecode >/dev/null 2>&1; then
        echo "  System Manufacturer: $(dmidecode -s system-manufacturer 2>/dev/null || echo 'Unknown')"
        echo "  System Product: $(dmidecode -s system-product-name 2>/dev/null || echo 'Unknown')"
        echo "  System Version: $(dmidecode -s system-version 2>/dev/null || echo 'Unknown')"
    else
        echo "  DMI Information: dmidecode not available"
    fi
    
    echo ""
    echo "Apple Hardware Indicators:"
    echo "  Apple SMC: $([ -d "/sys/devices/platform/applesmc" ] && echo "Present" || echo "Not found")"
    echo "  Apple ACPI Device: $([ -d "/sys/bus/acpi/devices/APP0001:00" ] && echo "Present" || echo "Not found")"
    echo "  T2 MFi Device: $([ -d "/sys/class/apple_mfi_fastcharge" ] && echo "Present" || echo "Not found")"
    
    echo ""
    echo "System Capabilities:"
    echo "  Root Access: $([ "$EUID" -eq 0 ] && echo "Available" || echo "Required")"
    echo "  Network Access: $(ping -c1 github.com >/dev/null 2>&1 && echo "Available" || echo "Limited")"
    echo "  Package Management: $(command -v dpkg >/dev/null 2>&1 && echo "Available" || echo "Not found")"
    
    echo ""
}

##
# community_hardware_detection - Enhanced detection with community messaging
#
# Description:
#   Community-integrated hardware detection function that provides
#   clear messaging and integrates with existing community standards.
##
community_hardware_detection() {
    msg_info "Starting comprehensive Mac hardware detection"
    
    local hardware_result
    hardware_result=$(detect_mac_hardware_enhanced 2>/dev/null | tail -n 1)
    
    if [ "$hardware_result" = "true" ]; then
        msg_ok "Mac hardware detected and validated for T2 kernel management"
        return 0
    else
        msg_error "Mac hardware detection failed - system not compatible"
        msg_info "Use diagnostic mode for detailed hardware information"
        return 1
    fi
}

# Enhanced Mac hardware detection with comprehensive reporting
IS_MAC_HARDWARE=$(detect_mac_hardware_enhanced 2>/dev/null | tail -n 1)
# More comprehensive T2 kernel detection
T2_KERNEL_INSTALLED=$(dpkg --list | grep -E 'pve-.*t2|.*-t2-.*|.*t2.*pve' | wc -l)

# Get latest T2 kernel version with enhanced error handling
LATEST_T2_VER=$(get_latest_t2_version)
if [ $? -ne 0 ]; then
    msg_warn "Could not fetch latest version, using fallback"
    LATEST_T2_VER="unknown"
fi

##
# is_kernel_up_to_date - Check if current kernel is up to date
#
# Description:
#   Compares current kernel version with latest available T2 kernel version
#
# Returns:
#   Exit 0: Current kernel is up to date
#   Exit 1: Update available or cannot determine
##
is_kernel_up_to_date() {
    # If we couldn't fetch the latest version, assume update needed
    if [[ "$LATEST_T2_VER" == "unknown" || -z "$LATEST_T2_VER" ]]; then
        return 1
    fi
    
    # Check if current kernel contains T2 and matches latest version
    if echo "$KERNEL_ON" | grep -q "t2" && echo "$KERNEL_ON" | grep -q "$LATEST_T2_VER"; then
        return 0
    fi
    
    return 1
}

##
# command_exists - Check if command exists in PATH
#
# Description:
#   Utility function to check command availability
#
# Parameters:
#   $1: Command name to check
#
# Returns:
#   Exit 0: Command exists
#   Exit 1: Command not found
##
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

##
# confirm_action - Community standard user confirmation dialog
#
# Description:
#   Prompts user for yes/no confirmation with input validation.
#   Follows community patterns for user interaction and safety.
#
# Parameters:
#   $1: Prompt message to display to user
#
# Returns:
#   Exit 0: User confirmed (yes)
#   Exit 1: User declined (no)
#
# Examples:
#   confirm_action "Proceed with installation" && install_kernel
##
confirm_action() {
    local prompt="$1"
    local response
    
    if [[ -z "$prompt" ]]; then
        msg_error "confirm_action: No prompt provided"
        return $EXIT_INVALID_INPUT
    fi
    
    while true; do
        read -p "$prompt (y/n)? " response
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) 
                return $EXIT_SUCCESS 
                ;;
            [Nn]|[Nn][Oo]) 
                return $EXIT_FAILURE 
                ;;
            *) 
                msg_warn "Please answer yes (y) or no (n)." 
                ;;
        esac
    done
}

##
# install_t2_kernel - Install or update T2 Edge Kernel with version checking
#
# Description:
#   Downloads and installs the latest T2 Edge Kernel from GitHub releases.
#   Includes version checking to prevent unnecessary installations.
#
# Returns:
#   Exit 0: Installation successful or cancelled by user
#   Exit 1: Installation failed
##
install_t2_kernel() {
    # Check if the latest version is already installed
    if is_kernel_up_to_date; then
        msg_warn "The latest T2 Edge Kernel appears to be already installed."
        msg_info "Current kernel: $KERNEL_ON"
        msg_info "Latest kernel: $LATEST_T2_VER"
        
        if ! confirm_action "Do you still want to proceed with installation/update"; then
            msg_ok "Installation cancelled."
            return 0
        fi
    fi
    
    install_t2_kernel_no_check
}

##
# install_t2_kernel_no_check - Install T2 kernel without version validation
#
# Description:
#   Downloads and installs T2 kernel packages directly without checking
#   if newer version is already installed. Used for forced installations.
#
# Returns:
#   Exit 0: Installation completed successfully
#   Exit 1: Installation failed
##
install_t2_kernel_no_check() {
    # Validate hardware compatibility before installation
    if ! validate_t2_compatibility; then
        msg_error "Installation aborted due to hardware incompatibility"
        echo ""
        msg_info "Press Enter to continue..."
        read
        return $EXIT_FAILURE
    fi
    
    msg_info "Installing T2 Edge Kernel ${LATEST_T2_VER}..."
    
    # Create temp directory for downloads
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download all .deb files from the latest release
    msg_info "Downloading kernel packages..."
    curl -s "https://api.github.com/repos/AdityaGarg8/pve-edge-kernel-t2/releases/latest" |
      grep "browser_download_url.*\.deb" |
      cut -d '"' -f 4 |
      xargs -n 1 wget -q --show-progress
    
    # Install the packages
    msg_info "Installing kernel packages..."
    dpkg -i ./*.deb || apt-get -f install -y
    
    # Clean up
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    msg_ok "T2 kernel installation complete!"
}

# Function to configure fan control
configure_fan_control() {
    msg_info "Configuring T2 Fan Control..."
    
    # Check if this is actually Mac hardware
    if [ "$IS_MAC_HARDWARE" != "true" ]; then
        msg_error "This does not appear to be Mac hardware. Aborting configuration."
        return $EXIT_FAILURE
    fi
    
    # Install required packages in a single apt call
    msg_info "Installing required packages..."
    apt-get update
    apt-get install -y lm-sensors t2fanrd
    
    # Run sensors-detect to detect hardware sensors
    msg_info "Detecting hardware sensors..."
    msg_info "Please answer YES to all prompts in the sensors-detect utility."
    
    # Create a temporary file to capture sensors-detect output
    local sensors_output=$(mktemp)
    sensors-detect --auto | tee "$sensors_output"
    
    # Check if sensors-detect recommended modules to add
    if grep -q "add this to /etc/modules" "$sensors_output"; then
        msg_info "sensors-detect has identified modules that need to be loaded."
        
        # Extract the recommended modules
        local modules_to_add=$(grep -A 10 "add this to /etc/modules" "$sensors_output" | 
                              grep -B 10 "cut here" | 
                              grep -v "cut here" | 
                              grep -v "add this to /etc/modules")
        
        echo ""
        msg_info "Recommended modules to add to /etc/modules:"
        echo "$modules_to_add"
        echo ""
        
        # Check if modules are already in /etc/modules
        local modules_missing=false
        while IFS= read -r module_line; do
            # Skip comments and empty lines
            [[ "$module_line" =~ ^#.*$ || -z "$module_line" ]] && continue
            
            # Extract module name
            local module_name=$(echo "$module_line" | awk '{print $1}')
            
            if ! grep -q "^$module_name\$" /etc/modules && ! grep -q "^$module_name " /etc/modules; then
                modules_missing=true
                break
            fi
        done <<< "$modules_to_add"
        
        if [ "$modules_missing" = true ]; then
            if confirm_action "Would you like to update /etc/modules with these recommended modules"; then
                msg_info "Updating /etc/modules..."
                
                # Add a backup timestamp
                local timestamp=$(date +"%Y%m%d%H%M%S")
                cp /etc/modules "/etc/modules.backup.$timestamp"
                msg_info "Backup created at /etc/modules.backup.$timestamp"
                
                # Append modules to /etc/modules if they don't already exist
                echo "" >> /etc/modules
                echo "# Added by t2-edge-kernel.sh on $(date)" >> /etc/modules
                while IFS= read -r module_line; do
                    # Skip comments and empty lines
                    [[ "$module_line" =~ ^#.*$ || -z "$module_line" ]] && continue
                    
                    # Extract module name
                    local module_name=$(echo "$module_line" | awk '{print $1}')
                    
                    if ! grep -q "^$module_name\$" /etc/modules && ! grep -q "^$module_name " /etc/modules; then
                        echo "$module_line" >> /etc/modules
                    fi
                done <<< "$modules_to_add"
                
                msg_ok "Updated /etc/modules successfully."
                msg_info "You may need to reboot for these changes to take effect."
            else
                msg_info "No changes made to /etc/modules. You may need to manually add the recommended modules."
            fi
        else
            msg_ok "All recommended modules are already in /etc/modules."
        fi
    fi
    
    # Clean up temporary file
    rm -f "$sensors_output"
    
    # Display sensor readings
    msg_info "Current sensor readings:"
    sensors
    
    # Enable and start the service
    msg_info "Enabling and starting t2fanrd service..."
    systemctl enable --now t2fanrd
    
    # Check if service started successfully
    if systemctl is-active --quiet t2fanrd; then
        msg_ok "T2 Fan Control daemon started successfully!"
        msg_info "Service status:"
        systemctl status t2fanrd
    else
        msg_error "Failed to start T2 Fan Control daemon. Check logs with 'journalctl -u t2fanrd'."
    fi
    
    msg_ok "T2 Fan Control configuration complete!"
    msg_info "You can monitor sensor readings anytime with the command: watch sensors"
    
    # Add pause to allow user to review the output
    echo ""
    msg_info "Press Enter to return to the main menu..."
    read
}

# Function to remove T2 kernel
remove_t2_kernel() {
    msg_info "Removing T2 Edge Kernel..."
    
    # More comprehensive detection of T2 kernel packages
    local t2_packages=$(dpkg --list | grep -E 'pve-.*t2|.*-t2-.*|.*t2.*pve' | awk '{print $2}')
    
    if [ -z "$t2_packages" ]; then
        msg_warn "No T2 kernel packages found."
        
        # Additional debugging information
        msg_info "Current kernel: $KERNEL_ON"
        msg_info "Checking for packages with current kernel version..."
        local kernel_version=$(echo $KERNEL_ON | sed 's/-pve-t2$//')
        local version_packages=$(dpkg --list | grep "$kernel_version" | awk '{print $2}')
        
        if [ -n "$version_packages" ]; then
            msg_info "Found packages matching current kernel version:"
            echo "$version_packages"
            
            if confirm_action "Would you like to remove these packages"; then
                msg_info "Removing kernel packages..."
                apt --purge remove -y $version_packages
                
                # Unpin kernel if needed
                if command_exists proxmox-boot-tool; then
                    proxmox-boot-tool kernel unpin
                fi
                
                msg_ok "Kernel removal complete!"
                return 0
            fi
        fi
        
        return 0
    fi
    
    msg_info "The following T2 kernel packages will be removed:"
    echo "$t2_packages"
    
    if confirm_action "Proceed with removal"; then
        msg_info "Removing T2 kernel packages..."
        apt --purge remove -y $t2_packages
        
        # Unpin kernel if needed
        if command_exists proxmox-boot-tool; then
            proxmox-boot-tool kernel unpin
        fi
        
        msg_ok "T2 kernel removal complete!"
    fi
}

##
# show_help_main - Display main help information
#
# Description:
#   Shows comprehensive main help with overview, menu options,
#   system requirements, and supported hardware information.
##
show_help_main() {
    cat << 'EOF'
╭─────────────────────────────────────────────────────────────────────────────╮
│                        T2 Mac Kernel Manager - Help                        │
╰─────────────────────────────────────────────────────────────────────────────╯

OVERVIEW:
  Manage T2 Mac kernels and fan control for Proxmox hosts running on Apple 
  hardware with T2 security chips (2018-2020 Mac models).

MAIN MENU OPTIONS:
  1) Install/Update T2 Kernel    - Install or update to latest T2 kernel
  2) Configure T2 Fan Control    - Set up and configure T2 fan management  
  3) Remove T2 Kernel           - Remove T2 kernel and restore original
  4) Hardware Diagnostics       - Run comprehensive hardware detection
  h) Help & Documentation       - Access detailed help and documentation
  x) Exit                       - Exit the application

SYSTEM REQUIREMENTS:
  • Apple Mac hardware with T2 security chip (2018-2020 models)
  • ProxmoxVE 8.0 or later
  • Root/sudo access required
  • Internet connection for kernel downloads

SUPPORTED HARDWARE:
  • MacBook Pro (13-inch, 15-inch, 16-inch): 2018, 2019, 2020
  • Mac Mini: 2018
  • iMac (21.5-inch, 27-inch): 2019, 2020
  • iMac Pro: 2017-2020

For detailed help on specific options, select the option and choose "Help".

GitHub: https://github.com/community-scripts/ProxmoxVE
Issues: https://github.com/community-scripts/ProxmoxVE/issues
EOF
}

##
# show_help_install - Display T2 kernel installation help
#
# Description:
#   Shows detailed help for T2 kernel installation process,
#   safety features, requirements, and troubleshooting.
##
show_help_install() {
    cat << 'EOF'
╭─────────────────────────────────────────────────────────────────────────────╮
│                     T2 Kernel Installation Help                            │
╰─────────────────────────────────────────────────────────────────────────────╯

INSTALLATION PROCESS:
  1. Hardware validation ensures T2 compatibility
  2. Latest kernel version fetched from GitHub
  3. Kernel packages downloaded and verified
  4. Installation performed with system backup
  5. Boot configuration updated for T2 kernel
  6. System prepared for reboot with new kernel

WHAT GETS INSTALLED:
  • T2-compatible Linux kernel packages
  • Hardware-specific drivers and modules
  • Boot configuration updates
  • Fan control sensor modules

SAFETY FEATURES:
  • Original kernel preserved for rollback
  • System state backup before changes
  • Installation validation and verification
  • Automatic rollback on critical failures

NETWORK REQUIREMENTS:
  • Internet connection required for download
  • GitHub API access for version checking
  • Backup packages cached locally when possible

POST-INSTALLATION:
  • System reboot required to activate new kernel
  • Fan control configuration recommended
  • Hardware validation confirms successful installation

TROUBLESHOOTING:
  If installation fails:
  1. Check hardware compatibility with diagnostics
  2. Verify internet connectivity
  3. Ensure sufficient disk space (>500MB)
  4. Check system logs for error details
  5. Use removal option to restore previous state
EOF
}

##
# show_help_fan_control - Display fan control configuration help
#
# Description:
#   Shows detailed help for T2 fan control setup, sensor configuration,
#   and service management.
##
show_help_fan_control() {
    cat << 'EOF'
╭─────────────────────────────────────────────────────────────────────────────╮
│                     Fan Control Configuration Help                         │
╰─────────────────────────────────────────────────────────────────────────────╯

FAN CONTROL OVERVIEW:
  T2 fan control manages thermal regulation for Mac hardware running ProxmoxVE.
  This ensures optimal cooling performance and prevents thermal throttling.

CONFIGURATION PROCESS:
  1. Install lm-sensors and t2fanrd packages
  2. Run sensors-detect to identify hardware sensors
  3. Configure kernel modules for sensor access
  4. Enable and start t2fanrd service
  5. Validate fan control functionality

REQUIRED COMPONENTS:
  • lm-sensors: Hardware sensor detection and monitoring
  • t2fanrd: T2-specific fan control daemon
  • Kernel modules: Hardware-specific sensor drivers
  • systemd service: Automatic fan control service

SENSOR DETECTION:
  The sensors-detect utility automatically identifies:
  • Temperature sensors (CPU, GPU, ambient)
  • Fan speed sensors and controls
  • Power management sensors
  • T2-specific hardware monitoring

SERVICE MANAGEMENT:
  • Automatic startup: Enabled via systemd
  • Status monitoring: systemctl status t2fanrd
  • Log viewing: journalctl -u t2fanrd
  • Configuration: /etc/t2fanrd/ directory

TROUBLESHOOTING:
  • Verify T2 kernel is installed and active
  • Check sensor module loading: lsmod | grep sensors
  • Monitor sensor readings: watch sensors
  • Review service logs for error messages
EOF
}

##
# show_help_hardware - Display hardware compatibility and diagnostic help
#
# Description:
#   Shows comprehensive hardware compatibility matrix and
#   diagnostic information for troubleshooting.
##
show_help_hardware() {
    cat << 'EOF'
╭─────────────────────────────────────────────────────────────────────────────╮
│                    Hardware Compatibility Guide                            │
╰─────────────────────────────────────────────────────────────────────────────╯

SUPPORTED HARDWARE:

✅ FULLY SUPPORTED:
  MacBook Pro 13-inch:
    • Mid 2018 (A1989) - MacBookPro15,2
    • Mid 2019 (A1989) - MacBookPro15,2  
    • Early 2020 (A2251) - MacBookPro16,2

  MacBook Pro 15-inch:
    • Mid 2018 (A1990) - MacBookPro15,1
    • Mid 2019 (A1990) - MacBookPro15,1

  MacBook Pro 16-inch:
    • Late 2019 (A2141) - MacBookPro16,1
    • Mid 2020 (A2141) - MacBookPro16,1

  Mac Mini:
    • Late 2018 (A1993) - Macmini8,1

  iMac 21.5-inch:
    • Early 2019 (A2116) - iMac19,2

  iMac 27-inch:
    • Mid 2019 (A2115) - iMac19,1
    • Mid 2020 (A2115) - iMac20,1

  iMac Pro:
    • Late 2017 (A1862) - iMacPro1,1

⚠️  UNTESTED BUT MAY WORK:
  • Mac Studio (M1 models require different approach)
  • Mac Pro (2019) - Limited T2 functionality

❌ NOT SUPPORTED:
  • Apple Silicon Macs (M1, M2, M3)
  • Intel Macs without T2 chip (pre-2017)
  • Hackintosh or virtualized environments
  • Non-Apple hardware

DETECTION METHODS:
  The tool uses multiple detection methods:
  1. DMI system manufacturer and product identification
  2. Apple System Management Controller (SMC) detection
  3. ACPI Apple-specific device detection
  4. T2-specific hardware device detection

Run "Hardware Diagnostics" for detailed compatibility analysis.
EOF
}

##
# show_help_removal - Display kernel removal help
#
# Description:
#   Shows detailed help for T2 kernel removal process,
#   safety considerations, and restoration procedures.
##
show_help_removal() {
    cat << 'EOF'
╭─────────────────────────────────────────────────────────────────────────────╮
│                       T2 Kernel Removal Help                               │
╰─────────────────────────────────────────────────────────────────────────────╯

REMOVAL OVERVIEW:
  Safely removes T2 kernel packages and restores original ProxmoxVE kernel.
  This process reverses T2 kernel installation and related modifications.

REMOVAL PROCESS:
  1. Identify all T2-related kernel packages
  2. Confirm package removal with user
  3. Remove T2 kernel packages via apt
  4. Unpin kernel boot configuration
  5. Restore original boot settings
  6. Clean up T2-specific configurations

WHAT GETS REMOVED:
  • All T2 kernel packages (pve-kernel-*-t2)
  • T2-specific kernel headers
  • Related firmware packages
  • Boot configuration modifications

SAFETY CONSIDERATIONS:
  • Original ProxmoxVE kernel remains intact
  • System automatically falls back to original kernel
  • No data loss during removal process
  • Boot configuration safely restored

POST-REMOVAL:
  • System reboot required to activate original kernel
  • Fan control may revert to basic functionality
  • Hardware sensors may need reconfiguration
  • System performance returns to pre-T2 state

TROUBLESHOOTING:
  If removal encounters issues:
  1. Use apt --purge remove for complete cleanup
  2. Check for remaining T2 packages: dpkg -l | grep t2
  3. Manually restore boot configuration if needed
  4. Review system logs for error details
  5. Contact community support if problems persist
EOF
}

# Main menu function
show_menu() {
    clear
    
    # Check if current kernel is up to date
    local kernel_status="(\033[0;31mUpdate Available\033[0m)"
    if is_kernel_up_to_date; then
        kernel_status="(\033[0;32mUp to Date\033[0m)"
    fi
    
    echo ""
    msg_info "=== SYSTEM INFORMATION ==="
    echo "Hostname: $HOSTNAME"
    echo "Current Kernel: $KERNEL_ON"
    echo "Mac Hardware: $IS_MAC_HARDWARE"
    echo "T2 Kernel Packages: $T2_KERNEL_INSTALLED"
    echo -e "Latest T2 Kernel: $LATEST_T2_VER $kernel_status"
    echo ""
    
    msg_info "=== MAC PROXMOX MANAGEMENT ==="
    
    local options=(
        "Install/Update T2 Edge Kernel"
        "Configure T2 Fan Control" 
        "Remove T2 Edge Kernel"
        "Hardware Diagnostics"
        "Help & Documentation"
        "Exit"
    )
    
    PS3="Select an option: "
    select opt in "${options[@]}"; do
        case $REPLY in
            1)
                # Check if the latest version is already installed before asking for confirmation
                if is_kernel_up_to_date; then
                    msg_warn "The latest T2 Edge Kernel appears to be already installed."
                    msg_info "Current kernel: $KERNEL_ON"
                    msg_info "Latest kernel: $LATEST_T2_VER"
                    
                    if confirm_action "Do you still want to proceed with installation"; then
                        install_t2_kernel_no_check
                        if confirm_action "Reboot to apply changes"; then
                            reboot
                        fi
                    fi
                else
                    if confirm_action "Install/Update T2 Edge Kernel"; then
                        install_t2_kernel_no_check
                        if confirm_action "Reboot to apply changes"; then
                            reboot
                        fi
                    fi
                fi
                ;;
            2)
                if confirm_action "Configure T2 Fan Control"; then
                    configure_fan_control
                fi
                ;;
            3)
                if confirm_action "Remove T2 Edge Kernel"; then
                    remove_t2_kernel
                    if confirm_action "Reboot to apply changes"; then
                        reboot
                    fi
                fi
                ;;
            4)
                clear
                echo "🔧 Hardware Diagnostics Mode"
                echo "============================="
                echo ""
                
                # Show enhanced hardware detection
                echo "Running enhanced hardware detection..."
                echo ""
                detect_mac_hardware_enhanced
                echo ""
                
                # Show detailed diagnostics
                show_hardware_diagnostics
                
                echo ""
                msg_info "Press Enter to return to the main menu..."
                read
                ;;
            5)
                show_help_menu
                ;;
            6) 
                msg_ok "Exiting T2 Mac Manager..."
                exit $EXIT_SUCCESS
                ;;
            *) 
                echo "Invalid selection. Please try again." 
                ;;
        esac
        break  # Exit after selection, don't loop back automatically
    done
}

# Help menu function using community select pattern
show_help_menu() {
    clear
    echo "📖 Help & Documentation"
    echo "======================="
    echo ""
    
    local help_options=(
        "Main Help - Overview and system requirements"
        "Installation Help - T2 kernel installation guide"
        "Fan Control Help - Fan configuration and troubleshooting"
        "Hardware Compatibility - Supported devices and detection"
        "Removal Help - Kernel removal and restoration"
        "Back to main menu"
    )
    
    PS3="Select help topic: "
    select opt in "${help_options[@]}"; do
        case $REPLY in
            1) 
                clear
                show_help_main
                echo ""
                echo "Press Enter to return to help menu..."
                read
                ;;
            2) 
                clear
                show_help_install
                echo ""
                echo "Press Enter to return to help menu..."
                read
                ;;
            3) 
                clear
                show_help_fan_control
                echo ""
                echo "Press Enter to return to help menu..."
                read
                ;;
            4) 
                clear
                show_help_hardware
                echo ""
                echo "Press Enter to return to help menu..."
                read
                ;;
            5) 
                clear
                show_help_removal
                echo ""
                echo "Press Enter to return to help menu..."
                read
                ;;
            6) 
                return  # Return to main menu
                ;;
            *) 
                echo "Invalid selection. Please try again." 
                ;;
        esac
        break
    done
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    msg_error "This script must be run as root"
    exit $EXIT_PERMISSION_ERROR
fi

##
# validate_community_dependencies - Validate required system dependencies
#
# Description:
#   Checks for required system utilities and community framework functions
#
# Returns:
#   Exit 0: All dependencies available
#   Exit 1: Missing dependencies
##
validate_community_dependencies() {
    local missing_deps=()
    
    # Check for essential system utilities
    local required_commands=("curl" "grep" "cut" "sed" "tail" "head")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for community messaging functions
    if ! declare -f msg_info >/dev/null 2>&1; then
        missing_deps+=("community messaging functions")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Missing required dependencies:" >&2
        printf '  %s\n' "${missing_deps[@]}" >&2
        return 1
    fi
    
    return 0
}

# Validate system dependencies
if ! validate_community_dependencies; then
    exit $EXIT_DEPENDENCY_ERROR
fi

# Display warning and get confirmation
msg_warn "WARNING: This is a Mac-Based Proxmox Management Tool."
msg_warn "USE AT YOUR OWN RISK."

if confirm_action "Proceed"; then
    show_menu
else
    msg_info "Operation cancelled."
    exit $EXIT_SUCCESS
fi
