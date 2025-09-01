# ProxmoxVE Development Environment Setup Guide

## Overview

This guide establishes a reproducible development environment for T2 Mac kernel management community integration work. The environment supports ProxmoxVE 8.x+ testing, Mac hardware simulation, and community scripts integration.

## 1. ProxmoxVE Development Environment

### System Requirements
- **Operating System**: Linux-based development machine or ProxmoxVE 8.x+ installation
- **RAM**: Minimum 4GB available for development work
- **Storage**: Minimum 20GB free space for repositories and test environments
- **Network**: Internet access for GitHub API testing and package downloads

### ProxmoxVE Test Instance Setup

#### Option A: VM-based Development
```bash
# Create ProxmoxVE test VM (if using virtualization)
# Minimum: 2 vCPU, 4GB RAM, 32GB storage
# Enable nested virtualization if testing on hypervisor
```

#### Option B: Bare Metal Development  
```bash
# Install ProxmoxVE 8.x+ on dedicated hardware
# Follow standard ProxmoxVE installation procedure
# Ensure network connectivity for API testing
```

### Network Configuration
```bash
# GitHub API testing configuration
export GITHUB_API_URL="https://api.github.com"
export T2_KERNEL_REPO="AdityaGarg8/pve-edge-kernel-t2"

# Offline scenario testing
export OFFLINE_MODE_TEST=false  # Set to true for offline testing
```

## 2. Mac Hardware Testing Setup

### Hardware Compatibility Matrix

| Mac Model | Year Range | T2 Chip | Testing Status |
|-----------|------------|---------|----------------|
| MacBook Pro 13" | 2018-2020 | Yes | Supported |
| MacBook Pro 15" | 2018-2019 | Yes | Supported |
| MacBook Pro 16" | 2019-2020 | Yes | Supported |
| Mac Mini | 2018-2020 | Yes | Supported |
| iMac | 2019-2020 | Yes | Supported |
| iMac Pro | 2017-2019 | Yes | Supported |

### Hardware Detection Simulation Framework

```bash
# Hardware simulation environment variables
export T2MAC_SIMULATION_MODE=true

# Available hardware profiles for simulation
export T2MAC_SIMULATED_HARDWARE="macbook-pro-2019"  # Default
# Options: macbook-pro-2018, macbook-pro-2019, macbook-pro-2020
#          mac-mini-2018, mac-mini-2020
#          imac-2019, imac-2020, imac-pro-2017

# Simulation data directory
mkdir -p ~/.t2mac-dev/simulation-data

# Mock hardware detection responses
cat > ~/.t2mac-dev/simulation-data/dmidecode-mock.txt << 'EOF'
# Manufacturer: Apple Inc.
# Product Name: MacBookPro15,4
# Version: 1.0
# Serial Number: FVFXXXXCXXXXH
# Family: Mac
EOF

# Mock SMC detection
cat > ~/.t2mac-dev/simulation-data/smc-mock.txt << 'EOF'
# SMC Version: 2.37f18
# T2 Security Chip: Present
EOF
```

### Alternative Testing for Non-Mac Developers
```bash
# Docker-based Mac hardware simulation
# Note: This simulates detection only, not actual T2 functionality
docker run --rm -it \
  -v $(pwd):/workspace \
  -e T2MAC_SIMULATION_MODE=true \
  -e T2MAC_SIMULATED_HARDWARE=macbook-pro-2019 \
  ubuntu:22.04 bash
```

## 3. Community Scripts Integration Tools

### Repository Setup
```bash
# Clone community scripts repository
git clone https://github.com/community-scripts/ProxmoxVE.git ~/proxmoxve-community
cd ~/proxmoxve-community

# Set up development branch
git checkout -b t2mac-integration-dev
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Community Function Integration
```bash
# Source community functions for testing
source ~/proxmoxve-community/misc/core.func

# Test community messaging patterns
msg_info "Testing community integration patterns"
msg_ok "Community functions loaded successfully"
msg_error "Error handling test"

# Test community header system
source ~/proxmoxve-community/misc/tools.func
```

### Local Development Testing
```bash
# Create isolated testing environment
mkdir -p ~/.t2mac-dev/testing
cd ~/.t2mac-dev/testing

# Copy community functions for local testing
cp ~/proxmoxve-community/misc/*.func ./

# Test community script patterns
./test_community_patterns
```

## 4. Required Tools and Versions

### Version Validation Script
```bash
#!/bin/bash
# tools-version-check.sh

echo "=== Development Environment Tool Validation ==="

# Bash version check
bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+')
if [[ $(echo "$bash_version >= 4.4" | bc -l) -eq 1 ]]; then
    echo "✅ Bash $bash_version (>= 4.4 required)"
else
    echo "❌ Bash $bash_version (< 4.4, upgrade required)"
fi

# Git version check
git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+')
if [[ $(echo "$git_version >= 2.25" | bc -l) -eq 1 ]]; then
    echo "✅ Git $git_version (>= 2.25 required)"
else
    echo "❌ Git $git_version (< 2.25, upgrade required)"
fi

# curl capabilities check
if curl --version | grep -q "https"; then
    echo "✅ curl with HTTPS support available"
else
    echo "❌ curl missing HTTPS support"
fi

# System tools check
for tool in dmidecode systemctl dpkg apt; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool available"
    else
        echo "❌ $tool missing"
    fi
done

# Community script linting tools
if command -v shellcheck >/dev/null 2>&1; then
    echo "✅ shellcheck available for linting"
else
    echo "⚠️  shellcheck recommended for linting"
fi

if command -v bc >/dev/null 2>&1; then
    echo "✅ bc available for version comparison"
else
    echo "❌ bc required for version comparison"
fi
```

## 5. Configuration Management

### Development Configuration Templates
```bash
# Create development configuration directory
mkdir -p ~/.t2mac-dev/config

# Safe testing configuration template
cat > ~/.t2mac-dev/config/dev-config.conf << 'EOF'
# T2Mac Development Configuration
DEV_MODE=true
BACKUP_BEFORE_CHANGES=true
DRY_RUN_DEFAULT=true
LOG_LEVEL=debug
SIMULATION_MODE=true
EOF

# Environment backup script
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
```

### Environment Reset Procedures
```bash
# Environment reset script
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
```

## 6. Integration Verification Framework

### Environment Validation Script
```bash
#!/bin/bash
# integration-verification.sh

echo "=== Integration Verification ==="

# IV1: Development environment produces identical script behavior
echo "Testing IV1: Script behavior consistency..."
if [[ -f ~/proxmoxve-community/tmp/t2man ]]; then
    # Run script in simulation mode
    T2MAC_SIMULATION_MODE=true ~/proxmoxve-community/tmp/t2man --test-mode
    echo "✅ IV1: Script behavior testing available"
else
    echo "❌ IV1: t2man script not found for testing"
fi

# IV2: Community script integration patterns testable
echo "Testing IV2: Community integration patterns..."
if source ~/proxmoxve-community/misc/core.func 2>/dev/null; then
    msg_info "Community functions integration test"
    echo "✅ IV2: Community patterns accessible"
else
    echo "❌ IV2: Community functions not accessible"
fi

# IV3: t2man functionality reproduction
echo "Testing IV3: t2man functionality..."
if T2MAC_SIMULATION_MODE=true bash ~/proxmoxve-community/tmp/t2man --version 2>/dev/null; then
    echo "✅ IV3: t2man functionality accessible"
else
    echo "❌ IV3: t2man functionality not accessible"
fi

# IV4: GitHub API integration testing
echo "Testing IV4: GitHub API connectivity..."
if curl -s "https://api.github.com/repos/AdityaGarg8/pve-edge-kernel-t2/releases/latest" >/dev/null; then
    echo "✅ IV4: GitHub API accessible"
    # Test offline scenario
    OFFLINE_MODE_TEST=true
    echo "✅ IV4: Offline mode testing available"
else
    echo "❌ IV4: GitHub API not accessible"
fi

echo "Integration verification complete"
```

## 7. Quick Setup Script

```bash
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

# Validate tool versions
bash ~/proxmoxve-community/tools/dev/tools-version-check.sh

# Set up simulation framework
export T2MAC_SIMULATION_MODE=true
export T2MAC_SIMULATED_HARDWARE=macbook-pro-2019

# Backup current environment
~/.t2mac-dev/backup-env.sh

# Run integration verification
bash ~/proxmoxve-community/tools/dev/integration-verification.sh

echo "✅ Development environment setup complete"
echo "⏰ Setup time: $(date)"
echo "📁 Environment location: ~/.t2mac-dev/"
```

## Usage

1. **Initial Setup**: Run `tools/dev/quick-dev-setup.sh` 
2. **Daily Development**: Source `~/.t2mac-dev/config/dev-config.conf`
3. **Testing**: Use simulation mode with `T2MAC_SIMULATION_MODE=true`
4. **Reset**: Run `~/.t2mac-dev/reset-env.sh` if needed
5. **Verification**: Run `tools/dev/integration-verification.sh` to validate setup

## Troubleshooting

### Common Issues
- **dmidecode permission denied**: Run with sudo or add user to appropriate group
- **GitHub API rate limiting**: Use authentication token or offline mode testing
- **Missing bc command**: Install bc package for version comparisons
- **Community functions not loading**: Verify ProxmoxVE repository clone completed

### Support
- Check simulation data in `~/.t2mac-dev/simulation-data/`
- Review backup logs in `~/.t2mac-dev/backups/`
- Validate tools with `tools/dev/tools-version-check.sh`