# T2 Mac Kernel Manager

A ProxmoxVE community script for managing T2 Mac kernels and fan control on Apple hardware.

## Overview

The T2 Mac Kernel Manager provides seamless kernel management for ProxmoxVE installations running on Apple Mac hardware with T2 security chips. This tool automates the installation, configuration, and maintenance of T2-compatible kernels while providing comprehensive fan control for optimal system performance.

## Quick Start

### Prerequisites
- Apple Mac hardware with T2 security chip (2018-2020 models)
- ProxmoxVE 8.0 or later
- Root/sudo access
- Internet connection for kernel downloads

### Installation
```bash
# Download and run the T2 Mac Kernel Manager
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/tools/pve/t2mac-manager.sh)"
```

### Basic Usage
1. **Hardware Check**: Verify T2 compatibility
2. **Install Kernel**: Download and install latest T2 kernel  
3. **Configure Fans**: Set up fan control for optimal cooling
4. **Reboot**: Restart system to activate new kernel

## Hardware Compatibility

### Fully Supported
| Model | Year | Identifier | Status |
|-------|------|------------|--------|
| MacBook Pro 13" | 2018-2020 | MacBookPro15,2/16,2 | ✅ Tested |
| MacBook Pro 15" | 2018-2019 | MacBookPro15,1 | ✅ Tested |
| MacBook Pro 16" | 2019-2020 | MacBookPro16,1 | ✅ Tested |
| Mac Mini | 2018 | Macmini8,1 | ✅ Tested |
| iMac 21.5" | 2019 | iMac19,2 | ✅ Tested |
| iMac 27" | 2019-2020 | iMac19,1/20,1 | ✅ Tested |
| iMac Pro | 2017-2020 | iMacPro1,1 | ✅ Tested |

### Not Supported
- Apple Silicon Macs (M1/M2/M3)
- Intel Macs without T2 chip
- Virtualized or emulated environments

## Features

### Kernel Management
- **Automated Updates**: Check and install latest T2 kernels
- **Version Intelligence**: Smart version comparison and recommendations
- **Safe Installation**: Backup and rollback capabilities
- **GitHub Integration**: Direct integration with T2 kernel repository

### Fan Control
- **Sensor Detection**: Automatic hardware sensor identification
- **Service Management**: T2 fan daemon configuration and control
- **Temperature Monitoring**: Real-time thermal management
- **Custom Profiles**: Adjustable fan curves for different use cases

### System Integration
- **ProxmoxVE Native**: Built for ProxmoxVE infrastructure
- **Community Standards**: Follows established coding and UX patterns
- **Web UI Integration**: Available through ProxmoxVE helper scripts interface
- **Comprehensive Logging**: Detailed operation logging for troubleshooting

### Documentation & Help System
- **Inline Help**: Comprehensive help accessible through menu interface
- **Hardware Diagnostics**: Multi-method hardware detection and reporting
- **Community Integration**: Follows ProxmoxVE community documentation standards
- **Self-Service Support**: Reduces maintenance burden while improving user experience

## Troubleshooting

### Common Issues

#### Hardware Not Detected
```bash
# Run hardware diagnostics
./t2mac-manager.sh
# Select option 4 for Hardware Diagnostics

# Check detection methods manually
dmidecode -s system-manufacturer
ls /sys/devices/platform/applesmc
```

#### Network Connectivity Issues
```bash
# Test GitHub connectivity
curl -I https://api.github.com/repos/AdityaGarg8/pve-edge-kernel-t2/releases/latest

# Check DNS resolution
nslookup github.com
```

#### Kernel Installation Failures
```bash
# Check available disk space
df -h /

# Validate package integrity
dpkg --info /path/to/kernel.deb

# Check system logs
journalctl -xe | grep -i kernel
```

### Getting Help

1. **Built-in Help**: Use option 'h' in the main menu for comprehensive help
2. **Hardware Diagnostics**: Run option 4 for compatibility check
3. **Community Support**: GitHub Issues and community forums
4. **Documentation**: Comprehensive guides and troubleshooting

## Contributing

We welcome contributions from the community! Here's how you can help:

### Reporting Issues
- Use GitHub Issues for bug reports
- Include hardware model and ProxmoxVE version
- Provide diagnostic output when possible
- Follow the issue template for consistency

### Contributing Code
- Fork the repository and create feature branches
- Follow existing code style and patterns
- Include comprehensive tests for new functionality
- Update documentation for any user-facing changes

### Testing and Validation
- Test on different Mac hardware models
- Validate against different ProxmoxVE versions
- Report compatibility results
- Help expand hardware support matrix

### Documentation
- Improve existing documentation
- Add troubleshooting guides
- Create hardware-specific guides
- Translate documentation to other languages

## Technical Details

### Detection Methods
The tool uses multiple hardware detection methods for maximum compatibility:
1. **DMI/SMBIOS Detection**: System manufacturer and product identification
2. **Apple SMC Detection**: System Management Controller presence
3. **ACPI Detection**: Apple-specific device detection
4. **T2-Specific Devices**: Bridge controller and T2 chip detection

### GitHub API Integration
- **Rate Limiting Protection**: Intelligent retry with exponential backoff
- **Caching**: Local caching reduces API calls and improves performance  
- **Offline Support**: Graceful degradation when network unavailable
- **Error Handling**: Comprehensive error recovery and user guidance

### Safety Features
- **Hardware Validation**: Prevents installation on incompatible systems
- **Input Sanitization**: Prevents command injection attacks
- **Rollback Capability**: Safe kernel removal and restoration
- **Backup Creation**: System state preservation before changes

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **AdityaGarg8**: T2 Edge Kernel development and maintenance
- **ProxmoxVE Community**: Infrastructure and community support
- **T2Linux Community**: Hardware compatibility research and testing

## Support

- **GitHub Issues**: https://github.com/community-scripts/ProxmoxVE/issues
- **Community Forum**: https://forum.proxmox.com/
- **T2 Kernel Repository**: https://github.com/AdityaGarg8/pve-edge-kernel-t2
- **Built-in Help**: Access comprehensive help through the tool's menu system

---

*Part of the ProxmoxVE Community Scripts project - making ProxmoxVE more accessible and powerful for everyone.*