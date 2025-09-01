#!/bin/bash
# tools-version-check.sh

echo "=== Development Environment Tool Validation ==="

# Function to compare versions
version_compare() {
    local version1="$1"
    local version2="$2"
    local IFS=.
    local i ver1=($version1) ver2=($version2)
    
    # Fill empty fields with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do
        ver2[i]=0
    done
    
    # Compare versions
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ ${ver1[i]} -gt ${ver2[i]} ]]; then
            return 0  # version1 > version2
        elif [[ ${ver1[i]} -lt ${ver2[i]} ]]; then
            return 1  # version1 < version2
        fi
    done
    return 0  # versions are equal
}

# Bash version check
bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
if version_compare "$bash_version" "4.4"; then
    echo "✅ Bash $bash_version (>= 4.4 required)"
else
    echo "❌ Bash $bash_version (< 4.4, upgrade required)"
fi

# Git version check
git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+' | head -n1)
if version_compare "$git_version" "2.25"; then
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

# Platform detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📱 Detected macOS development environment"
    # macOS-specific tool checks
    for tool in curl grep sed; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✅ $tool available"
        else
            echo "❌ $tool missing"
        fi
    done
    echo "⚠️  Linux-specific tools (dmidecode, systemctl, dpkg, apt) not available on macOS - this is expected"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detected Linux development environment"
    # Linux-specific tool checks
    for tool in dmidecode systemctl dpkg apt curl grep sed; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✅ $tool available"
        else
            echo "❌ $tool missing"
        fi
    done
else
    echo "❓ Unknown platform: $OSTYPE"
    # Generic tool check
    for tool in curl grep sed; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✅ $tool available"
        else
            echo "❌ $tool missing"
        fi
    done
fi

# Community script linting tools
if command -v shellcheck >/dev/null 2>&1; then
    echo "✅ shellcheck available for linting"
else
    echo "⚠️  shellcheck recommended for linting"
fi

echo "✅ Using built-in bash version comparison (no bc dependency required)"