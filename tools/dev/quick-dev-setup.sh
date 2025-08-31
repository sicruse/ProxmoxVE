#!/bin/bash
# quick-dev-setup.sh - Complete environment setup in under 2 hours

set -e

echo "=== T2Mac Development Environment Quick Setup ==="

# Create development directory structure
mkdir -p ~/.t2mac-dev/{config,backups,simulation-data,testing}

# Clone community repository
if [[ ! -d ~/proxmoxve-community ]]; then
    git clone https://github.com/community-scripts/ProxmoxVE.git ~/proxmoxve-community
    echo "✅ Community repository cloned"
fi

# Install required tools
sudo apt-get update
sudo apt-get install -y bash git curl dmidecode bc shellcheck

# Create development configuration
cat > ~/.t2mac-dev/config/dev-config.conf << 'EOF'
# T2Mac Development Configuration
DEV_MODE=true
BACKUP_BEFORE_CHANGES=true
DRY_RUN_DEFAULT=true
LOG_LEVEL=debug
SIMULATION_MODE=true
EOF

# Set up simulation framework
export T2MAC_SIMULATION_MODE=true
export T2MAC_SIMULATED_HARDWARE=macbook-pro-2019

# Create mock hardware detection data
cat > ~/.t2mac-dev/simulation-data/dmidecode-mock.txt << 'EOF'
# Manufacturer: Apple Inc.
# Product Name: MacBookPro15,4
# Version: 1.0
# Serial Number: FVFXXXXCXXXXH
# Family: Mac
EOF

# Create backup script
cat > ~/.t2mac-dev/backup-env.sh << 'EOF'
#!/bin/bash
# Backup development environment state

BACKUP_DIR="$HOME/.t2mac-dev/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup system state
dpkg --get-selections > "$BACKUP_DIR/dpkg-selections.txt"
systemctl list-unit-files --state=enabled > "$BACKUP_DIR/enabled-services.txt"

# Backup kernel information
uname -a > "$BACKUP_DIR/kernel-info.txt"
ls -la /boot/ > "$BACKUP_DIR/boot-contents.txt"

echo "Environment backed up to: $BACKUP_DIR"
EOF

chmod +x ~/.t2mac-dev/backup-env.sh

# Create reset script
cat > ~/.t2mac-dev/reset-env.sh << 'EOF'
#!/bin/bash
# Reset development environment to clean state

# Restore from latest backup
LATEST_BACKUP=$(ls -1t ~/.t2mac-dev/backups/ | head -n1)
if [[ -n "$LATEST_BACKUP" ]]; then
    echo "Restoring from backup: $LATEST_BACKUP"
    # Restore package selections
    sudo dpkg --set-selections < ~/.t2mac-dev/backups/$LATEST_BACKUP/dpkg-selections.txt
    sudo apt-get dselect-upgrade -y
else
    echo "No backups found for restoration"
fi

# Clean simulation data
rm -rf ~/.t2mac-dev/simulation-data/*
rm -rf ~/.t2mac-dev/testing/*

# Reset environment variables
unset T2MAC_SIMULATION_MODE T2MAC_SIMULATED_HARDWARE
unset OFFLINE_MODE_TEST

echo "Development environment reset complete"
EOF

chmod +x ~/.t2mac-dev/reset-env.sh

# Backup current environment
~/.t2mac-dev/backup-env.sh

# Validate tool versions
bash ./tools-version-check.sh

# Run integration verification
bash ./integration-verification.sh

echo "✅ Development environment setup complete"
echo "⏰ Setup time: $(date)"
echo "📁 Environment location: ~/.t2mac-dev/"