# Contributing to T2 Mac Kernel Manager

We welcome contributions from the community! This document provides guidelines for contributing to the T2 Mac Kernel Manager project, part of the ProxmoxVE community scripts ecosystem.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Contribution Types](#contribution-types)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Submission Process](#submission-process)
- [Community Guidelines](#community-guidelines)

## Getting Started

### Prerequisites
- Apple Mac hardware with T2 chip for testing (recommended)
- ProxmoxVE 8.0+ installation
- Basic understanding of bash scripting
- Git version control knowledge
- GitHub account for contributions

### Initial Setup
1. Fork the repository on GitHub
2. Clone your fork locally
3. Set up development environment following [Development Environment Setup](dev-environment-setup.md)
4. Review existing code and documentation
5. Join community discussions and forums

## Development Environment

### Required Tools
```bash
# Essential development tools
sudo apt update
sudo apt install -y \
    bash \
    shellcheck \
    git \
    curl \
    dmidecode \
    systemd

# Testing and validation tools
sudo apt install -y \
    bats \
    parallel \
    jq
```

### Development Standards
- **Shell**: Bash 4.4+ with POSIX compatibility where possible
- **Style**: Follow ProxmoxVE community coding standards
- **Documentation**: Inline comments and function documentation required
- **Testing**: Comprehensive test coverage for new functionality

## Contribution Types

### 1. Bug Reports
When reporting bugs, please include:
- Hardware model and identifier (e.g., MacBookPro15,2)
- ProxmoxVE version
- Kernel version currently running
- Complete error messages or unexpected behavior
- Steps to reproduce the issue
- Output from hardware diagnostics (option 4 in main menu)

**Template**:
```
**Hardware Information:**
- Model: MacBook Pro 13-inch 2019
- Identifier: MacBookPro15,2
- ProxmoxVE Version: 8.2
- Current Kernel: 6.8.12-2-pve

**Issue Description:**
[Clear description of the problem]

**Steps to Reproduce:**
1. [First step]
2. [Second step]
3. [Additional steps...]

**Expected Behavior:**
[What should have happened]

**Actual Behavior:**
[What actually happened]

**Error Messages:**
```
[Any error messages or logs]
```

**Diagnostic Output:**
[Output from hardware diagnostics if applicable]
```

### 2. Hardware Compatibility Testing
Help expand hardware support by testing on different Mac models:

#### Testing Process
1. Run hardware diagnostics (option 4)
2. Test kernel installation process
3. Validate fan control functionality
4. Perform stability testing (24+ hours)
5. Document results in compatibility matrix

#### Reporting Results
```json
{
  "model": "MacBookPro16,1",
  "year": "2020",
  "identifier": "MacBookPro16,1",
  "status": "fully_supported|limited_support|not_supported",
  "tested": true,
  "notes": "Detailed testing notes",
  "kernel_compatibility": "6.8.12+",
  "fan_control": "full_support|limited|not_supported",
  "issues_found": ["List any issues encountered"]
}
```

### 3. Feature Development
For new features:
1. Discuss proposed changes in GitHub Issues first
2. Create detailed implementation plan
3. Follow existing code patterns and standards
4. Include comprehensive testing
5. Update documentation accordingly

#### Feature Development Guidelines
- **Backwards Compatibility**: Maintain compatibility with existing functionality
- **Error Handling**: Implement robust error handling and recovery
- **User Experience**: Follow ProxmoxVE community UX patterns
- **Performance**: Consider impact on system resources and boot time
- **Security**: Validate all inputs and avoid privileged operation risks

### 4. Documentation Improvements
Documentation contributions are highly valued:
- **Inline Help**: Improve built-in help system
- **Troubleshooting Guides**: Add common issue solutions
- **Hardware Guides**: Create model-specific documentation
- **Translation**: Translate documentation to other languages
- **Examples**: Provide usage examples and tutorials

## Code Standards

### Bash Scripting Standards
Follow the established coding standards in [docs/architecture/coding-standards.md](architecture/coding-standards.md):

#### Function Structure
```bash
##
# function_name - Brief description
#
# Description:
#   Detailed description of function purpose and behavior.
#   Include important implementation details.
#
# Parameters:
#   $1: Parameter description
#   $2: Optional parameter description (optional)
#
# Returns:
#   Exit 0: Success condition
#   Exit 1: Error condition description
#
# Examples:
#   function_name "param1" "param2"
#   result=$(function_name "value") && echo "Success: $result"
##
function_name() {
    local param1="$1"
    local param2="${2:-default_value}"
    
    # Input validation
    if [[ -z "$param1" ]]; then
        msg_error "function_name: Parameter 1 required"
        return 1
    fi
    
    # Function logic here
    msg_info "Processing $param1"
    
    # Return appropriate exit code
    return 0
}
```

#### Error Handling
```bash
# Use community error handling patterns
set -euo pipefail

# Community messaging functions
msg_info "Information message"
msg_ok "Success message"
msg_warn "Warning message" 
msg_error "Error message"

# Input validation
validate_input "$user_input" || {
    msg_error "Invalid input provided"
    return 1
}

# Safe command execution
if ! execute_command_safely "$cmd"; then
    msg_error "Command execution failed"
    return 1
fi
```

#### Community Integration
```bash
# Standard community script header
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/core.func)

# Application metadata
APP="T2 Mac Manager"
var_tags="${var_tags:-hardware;mac;kernel}"

# Community initialization
header_info "$APP"
catch_errors
```

## Testing Requirements

### Unit Testing
All new functions must include unit tests:

```bash
# Test file: tests/unit/test_new_function.sh
#!/usr/bin/env bash

# Source the function to test
source "../../tools/pve/t2mac-manager.sh"

# Test case 1: Normal operation
test_function_normal_operation() {
    local result
    result=$(new_function "valid_input")
    
    assert_equals "expected_output" "$result"
    assert_equals 0 "$?"
}

# Test case 2: Error handling
test_function_error_handling() {
    local result
    result=$(new_function "" 2>/dev/null)
    
    assert_equals 1 "$?"
}

# Run tests
test_function_normal_operation
test_function_error_handling
```

### Integration Testing
Test integration with existing functionality:
- Hardware detection workflow
- Kernel installation process
- Fan control configuration
- Error recovery scenarios

### Hardware Testing
When possible, test on actual hardware:
- Multiple Mac models from compatibility matrix
- Different ProxmoxVE versions
- Various network conditions
- Edge cases and error scenarios

## Submission Process

### Pull Request Guidelines

#### 1. Preparation
- Create feature branch from latest main
- Follow naming convention: `feature/description` or `fix/issue-description`
- Keep changes focused and atomic
- Update version numbers if applicable

#### 2. Code Review Checklist
- [ ] Code follows established patterns and standards
- [ ] All functions have proper documentation
- [ ] Input validation implemented
- [ ] Error handling comprehensive
- [ ] Tests included and passing
- [ ] Documentation updated
- [ ] Backwards compatibility maintained

#### 3. Pull Request Template
```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Tested on hardware: [specify models]
- [ ] Manual testing completed

## Hardware Compatibility
- [ ] No impact on hardware compatibility
- [ ] Expands hardware support: [specify models]
- [ ] Updates compatibility matrix

## Documentation
- [ ] Code documentation updated
- [ ] User documentation updated
- [ ] Help system updated if applicable

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code, particularly hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or feature works
- [ ] New and existing unit tests pass locally
```

#### 4. Review Process
1. Automated checks (if available)
2. Code review by maintainers
3. Community feedback period
4. Hardware testing validation
5. Final approval and merge

## Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn and contribute
- Follow ProxmoxVE community standards

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community discussion
- **Pull Requests**: Code review and technical discussion
- **ProxmoxVE Forum**: Broader community support

### Recognition
Contributors are recognized through:
- Git commit attribution
- Contributor listings in documentation
- Community acknowledgments
- Maintainer consideration for significant contributions

## Troubleshooting Development Issues

### Common Development Problems

#### Hardware Detection Issues
```bash
# Debug hardware detection
dmidecode -s system-manufacturer
ls -la /sys/devices/platform/applesmc
ls -la /sys/bus/acpi/devices/APP0001:00
```

#### Testing Environment Setup
```bash
# Verify required tools
command -v shellcheck || echo "Install shellcheck"
command -v git || echo "Install git"
command -v curl || echo "Install curl"
```

#### Code Quality Issues
```bash
# Run shellcheck on scripts
shellcheck tools/pve/t2mac-manager.sh

# Check bash syntax
bash -n tools/pve/t2mac-manager.sh
```

### Getting Help
1. Check existing documentation and issues
2. Use hardware diagnostics for troubleshooting
3. Provide detailed information when asking for help
4. Be patient and respectful when seeking assistance

## Future Development

### Roadmap Items
- Extended hardware support for newer Mac models
- Enhanced fan curve customization
- Automated testing infrastructure
- Multi-language support
- Performance optimizations

### Architecture Improvements
- Modular function organization
- Enhanced error recovery
- Improved logging and diagnostics
- Better integration with ProxmoxVE ecosystem

## License and Legal

By contributing to this project, you agree that your contributions will be licensed under the MIT License. Ensure you have the right to contribute any code you submit and that it doesn't infringe on third-party intellectual property.

## Thank You

Your contributions help make ProxmoxVE more accessible and powerful for Mac hardware users. Every contribution, whether it's code, documentation, testing, or community support, is valuable and appreciated.

For questions about contributing, please open a GitHub Issue or join the community discussions.

---

*This contributing guide is part of the ProxmoxVE Community Scripts project - making ProxmoxVE better through community collaboration.*