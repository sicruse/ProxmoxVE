#!/bin/bash
# dev-config-manager.sh - Development configuration management system

# Configuration management for T2Mac development environment

# Global configuration paths
DEV_CONFIG_DIR="$HOME/.t2mac-dev/config"
BACKUP_DIR="$HOME/.t2mac-dev/backups"
TEMPLATES_DIR="$HOME/.t2mac-dev/templates"

# Initialize configuration management
init_config_management() {
    echo "Initializing configuration management..."
    
    # Create directory structure
    mkdir -p "$DEV_CONFIG_DIR" "$BACKUP_DIR" "$TEMPLATES_DIR"
    
    # Create main development configuration template
    create_dev_config_template
    
    # Create backup and restore procedures
    create_backup_procedures
    
    # Create environment isolation tools
    create_isolation_tools
    
    echo "✅ Configuration management initialized"
}

# Create development configuration template
create_dev_config_template() {
    cat > "$TEMPLATES_DIR/dev-config-template.conf" << 'EOF'
# T2Mac Development Configuration Template
# Copy this to ~/.t2mac-dev/config/dev-config.conf and customize

# Development mode settings
DEV_MODE=true
MACOS_DEVELOPMENT={{MACOS_FLAG}}
BACKUP_BEFORE_CHANGES=true
DRY_RUN_DEFAULT=true
LOG_LEVEL=debug
SIMULATION_MODE=true

# Hardware simulation settings
T2MAC_SIMULATION_MODE=true
T2MAC_SIMULATED_HARDWARE={{HARDWARE_PROFILE}}
SIMULATION_DATA_DIR="$HOME/.t2mac-dev/simulation-data"

# Community integration settings
COMMUNITY_REPO_PATH="$HOME/proxmoxve-community"
COMMUNITY_FUNCTIONS_LOADED=false
LOCAL_TESTING_DIR="$HOME/.t2mac-dev/testing"

# GitHub API settings
GITHUB_API_URL="https://api.github.com"
T2_KERNEL_REPO="AdityaGarg8/pve-edge-kernel-t2"
OFFLINE_MODE_TEST=false
API_RATE_LIMIT_PROTECTION=true

# Tool paths (adjust for platform)
SHIMS_PATH="$HOME/.t2mac-dev/shims"
TOOL_VALIDATION_SCRIPT="./tools-version-check.sh"

# Safety settings
REQUIRE_CONFIRMATION=true
MAX_BACKUP_AGE_DAYS=30
AUTO_BACKUP_FREQUENCY=daily
EOF

    # Create active configuration from template
    if [[ ! -f "$DEV_CONFIG_DIR/dev-config.conf" ]]; then
        # Detect platform and set appropriate flags
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -e 's/{{MACOS_FLAG}}/true/g' \
                -e 's/{{HARDWARE_PROFILE}}/macbook-pro-2019/g' \
                "$TEMPLATES_DIR/dev-config-template.conf" > "$DEV_CONFIG_DIR/dev-config.conf"
        else
            sed -e 's/{{MACOS_FLAG}}/false/g' \
                -e 's/{{HARDWARE_PROFILE}}/macbook-pro-2019/g' \
                "$TEMPLATES_DIR/dev-config-template.conf" > "$DEV_CONFIG_DIR/dev-config.conf"
        fi
        echo "✅ Active development configuration created"
    else
        echo "✅ Existing development configuration preserved"
    fi
}

# Create backup and restore procedures
create_backup_procedures() {
    # Enhanced backup script
    cat > "$DEV_CONFIG_DIR/backup-procedures.sh" << 'EOF'
#!/bin/bash
# Enhanced backup procedures for development environment

BACKUP_DIR="$HOME/.t2mac-dev/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating development environment backup..."

# Backup system state (platform-aware)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS backup
    brew list > "$BACKUP_DIR/brew-packages.txt"
    system_profiler SPHardwareDataType > "$BACKUP_DIR/hardware-info.txt"
    uname -a > "$BACKUP_DIR/kernel-info.txt"
else
    # Linux backup
    dpkg --get-selections > "$BACKUP_DIR/dpkg-selections.txt"
    systemctl list-unit-files --state=enabled > "$BACKUP_DIR/enabled-services.txt"
    uname -a > "$BACKUP_DIR/kernel-info.txt"
    ls -la /boot/ > "$BACKUP_DIR/boot-contents.txt"
fi

# Backup development configuration
cp -r ~/.t2mac-dev/config "$BACKUP_DIR/"
cp -r ~/.t2mac-dev/simulation-data "$BACKUP_DIR/"

# Backup git configuration
git config --list > "$BACKUP_DIR/git-config.txt"

echo "Environment backed up to: $BACKUP_DIR"
EOF

    chmod +x "$DEV_CONFIG_DIR/backup-procedures.sh"

    # Enhanced restore script  
    cat > "$DEV_CONFIG_DIR/restore-procedures.sh" << 'EOF'
#!/bin/bash
# Enhanced restore procedures for development environment

restore_from_backup() {
    local backup_name="${1:-latest}"
    
    if [[ "$backup_name" == "latest" ]]; then
        backup_name=$(ls -1t ~/.t2mac-dev/backups/ | head -n1)
    fi
    
    local backup_path="$HOME/.t2mac-dev/backups/$backup_name"
    
    if [[ ! -d "$backup_path" ]]; then
        echo "❌ Backup not found: $backup_path"
        return 1
    fi
    
    echo "Restoring from backup: $backup_name"
    
    # Platform-aware restore
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS restore
        if [[ -f "$backup_path/brew-packages.txt" ]]; then
            echo "Restoring Homebrew packages..."
            # Note: Manual package restoration needed on macOS
            echo "📋 Review packages to restore: $backup_path/brew-packages.txt"
        fi
    else
        # Linux restore
        if [[ -f "$backup_path/dpkg-selections.txt" ]]; then
            sudo dpkg --set-selections < "$backup_path/dpkg-selections.txt"
            sudo apt-get dselect-upgrade -y
        fi
    fi
    
    # Restore development configuration
    if [[ -d "$backup_path/config" ]]; then
        cp -r "$backup_path/config"/* ~/.t2mac-dev/config/
        echo "✅ Development configuration restored"
    fi
    
    # Restore simulation data
    if [[ -d "$backup_path/simulation-data" ]]; then
        cp -r "$backup_path/simulation-data"/* ~/.t2mac-dev/simulation-data/
        echo "✅ Simulation data restored"
    fi
    
    echo "✅ Restore complete from $backup_name"
}

# List available backups
list_backups() {
    echo "Available backups:"
    ls -1t ~/.t2mac-dev/backups/ | while read backup; do
        backup_date=$(echo "$backup" | cut -d_ -f1-2)
        backup_size=$(du -sh ~/.t2mac-dev/backups/"$backup" | cut -f1)
        echo "  $backup ($backup_size)"
    done
}

# Main execution
case "${1:-}" in
    "restore")
        restore_from_backup "$2"
        ;;
    "list")
        list_backups
        ;;
    *)
        echo "Usage: $0 {restore [backup_name]|list}"
        echo "  restore latest    - Restore from most recent backup"
        echo "  restore YYYYMMDD_HHMMSS - Restore from specific backup"
        echo "  list             - List available backups"
        ;;
esac
EOF

    chmod +x "$DEV_CONFIG_DIR/restore-procedures.sh"
}

# Create environment isolation tools
create_isolation_tools() {
    # Environment reset script
    cat > "$DEV_CONFIG_DIR/reset-environment.sh" << 'EOF'
#!/bin/bash
# Reset development environment to clean state

echo "Resetting development environment..."

# Clean simulation data
rm -rf ~/.t2mac-dev/simulation-data/*
rm -rf ~/.t2mac-dev/testing/*

# Reset environment variables
unset T2MAC_SIMULATION_MODE T2MAC_SIMULATED_HARDWARE
unset OFFLINE_MODE_TEST DEV_MODE MACOS_DEVELOPMENT

# Reinitialize simulation framework
mkdir -p ~/.t2mac-dev/simulation-data
bash ./hardware-simulation-framework.sh init macbook-pro-2019

# Source fresh configuration
source ~/.t2mac-dev/config/dev-config.conf

echo "✅ Development environment reset complete"
EOF

    chmod +x "$DEV_CONFIG_DIR/reset-environment.sh"

    # Environment activation script
    cat > "$DEV_CONFIG_DIR/activate-dev-env.sh" << 'EOF'
#!/bin/bash
# Activate development environment with all configurations

echo "Activating T2Mac development environment..."

# Load development configuration
source ~/.t2mac-dev/config/dev-config.conf

# Add tool shims to PATH (macOS)
if [[ "$MACOS_DEVELOPMENT" == "true" ]]; then
    export PATH="$HOME/.t2mac-dev/shims:$PATH"
    echo "✅ macOS development shims activated"
fi

# Activate hardware simulation
export T2MAC_SIMULATION_MODE=true
export T2MAC_SIMULATED_HARDWARE="${T2MAC_SIMULATED_HARDWARE:-macbook-pro-2019}"

# Load community functions if available
if [[ -f "$HOME/proxmoxve-community/misc/core.func" ]]; then
    source "$HOME/proxmoxve-community/misc/core.func"
    echo "✅ Community functions loaded"
fi

echo "✅ Development environment activated"
echo "🔧 Current hardware simulation: $T2MAC_SIMULATED_HARDWARE"
echo "📁 Working directory: $(pwd)"
EOF

    chmod +x "$DEV_CONFIG_DIR/activate-dev-env.sh"

    # Cleanup and maintenance script
    cat > "$DEV_CONFIG_DIR/maintenance.sh" << 'EOF'
#!/bin/bash
# Development environment maintenance

# Clean old backups (older than 30 days)
cleanup_old_backups() {
    echo "Cleaning backups older than 30 days..."
    find ~/.t2mac-dev/backups -type d -mtime +30 -exec rm -rf {} \;
    echo "✅ Old backups cleaned"
}

# Update community repository
update_community_repo() {
    if [[ -d ~/proxmoxve-community ]]; then
        cd ~/proxmoxve-community
        git fetch origin
        git pull origin main
        echo "✅ Community repository updated"
        cd - >/dev/null
    else
        echo "❌ Community repository not found"
    fi
}

# Validate environment health
validate_environment() {
    echo "=== Environment Health Check ==="
    
    # Check configuration files
    if [[ -f ~/.t2mac-dev/config/dev-config.conf ]]; then
        echo "✅ Configuration file present"
    else
        echo "❌ Configuration file missing"
    fi
    
    # Check simulation framework
    if [[ -f ~/.t2mac-dev/simulation-data/dmidecode-mock.txt ]]; then
        echo "✅ Hardware simulation data present"
    else
        echo "❌ Hardware simulation data missing"
    fi
    
    # Check community repository
    if [[ -d ~/proxmoxve-community ]]; then
        echo "✅ Community repository present"
    else
        echo "❌ Community repository missing"
    fi
    
    # Run tool validation
    bash ./tools-version-check.sh
}

# Main execution
case "${1:-}" in
    "cleanup")
        cleanup_old_backups
        ;;
    "update")
        update_community_repo
        ;;
    "validate")
        validate_environment
        ;;
    "all")
        cleanup_old_backups
        update_community_repo
        validate_environment
        ;;
    *)
        echo "Usage: $0 {cleanup|update|validate|all}"
        echo "  cleanup  - Remove old backups"
        echo "  update   - Update community repository"
        echo "  validate - Check environment health"
        echo "  all      - Run all maintenance tasks"
        ;;
esac
EOF

    chmod +x "$DEV_CONFIG_DIR/maintenance.sh"
}

# Main execution
case "${1:-}" in
    "init")
        init_config_management
        ;;
    "backup")
        "$DEV_CONFIG_DIR/backup-procedures.sh"
        ;;
    "restore")
        "$DEV_CONFIG_DIR/restore-procedures.sh" restore "$2"
        ;;
    "reset")
        "$DEV_CONFIG_DIR/reset-environment.sh"
        ;;
    "activate")
        source "$DEV_CONFIG_DIR/activate-dev-env.sh"
        ;;
    "maintenance")
        "$DEV_CONFIG_DIR/maintenance.sh" "$2"
        ;;
    *)
        echo "Development Configuration Manager"
        echo "Usage: $0 {init|backup|restore|reset|activate|maintenance}"
        echo ""
        echo "Commands:"
        echo "  init        - Initialize configuration management system"
        echo "  backup      - Create environment backup"
        echo "  restore     - Restore from backup"
        echo "  reset       - Reset environment to clean state"
        echo "  activate    - Activate development environment"
        echo "  maintenance - Run maintenance tasks"
        ;;
esac