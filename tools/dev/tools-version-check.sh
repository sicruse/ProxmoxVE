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