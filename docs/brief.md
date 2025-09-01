# Project Brief: T2 Mac Custom Kernel Management for ProxmoxVE

## Executive Summary

**Product Concept:** A specialized script integration that enables ProxmoxVE users with Apple T2 Mac hardware to easily install, manage, and configure custom Linux kernels optimized for T2 Macs, extending the existing ProxmoxVE helper scripts ecosystem.

**Primary Problem:** ProxmoxVE users running on Apple T2 Mac hardware face significant challenges managing specialized kernels required for proper hardware functionality (fan control, sensors, hardware compatibility), with no standardized tooling within the ProxmoxVE community scripts ecosystem.

**Target Market:** ProxmoxVE administrators and enthusiasts specifically running Proxmox on Apple T2 Mac hardware who need reliable kernel management and hardware-specific configuration tools.

**Key Value Proposition:** Seamless integration of T2-specific kernel management into the trusted ProxmoxVE community scripts collection, providing automated installation, version checking, hardware detection, and fan control configuration with a user-friendly interface.

## Problem Statement

**Current State and Pain Points:**

ProxmoxVE users running on Apple T2 Mac hardware currently face a fragmented and manual approach to kernel management. The specialized T2 Edge Kernel from AdityaGarg8's repository requires users to:

- Manually discover and download kernel packages from GitHub releases
- Perform complex hardware detection to verify T2 compatibility
- Navigate installation procedures without integrated tooling
- Configure fan control and sensor management through separate, unrelated processes
- Manually track version updates and maintain system compatibility

**Impact of the Problem:**

- **Time Investment:** Users spend 2-4 hours per kernel update cycle researching, downloading, and configuring
- **Risk Exposure:** Manual processes increase likelihood of system instability, improper hardware configuration, or failed installations
- **Knowledge Barrier:** Technical expertise required excludes less experienced users from utilizing T2 Mac hardware with ProxmoxVE
- **Community Fragmentation:** Lack of standardized tooling means solutions aren't shared, documented, or maintained collectively

**Why Existing Solutions Fall Short:**

- **No Integration:** Current solutions exist as isolated GitHub repositories without connection to the broader ProxmoxVE ecosystem
- **Manual Processes:** Each step requires individual user intervention and technical knowledge
- **Limited Hardware Detection:** Basic detection methods may fail to identify T2 hardware correctly
- **No Version Management:** Users must manually track updates and compatibility across multiple repositories

**Urgency and Importance:**

With growing adoption of Apple Silicon and T2 Mac hardware in homelab and enterprise virtualization scenarios, the lack of integrated tooling creates a significant gap in the ProxmoxVE ecosystem. The timing is critical as the T2 Edge Kernel project has matured and proven stable, making integration both feasible and valuable.

## Proposed Solution

**Core Concept and Approach:**

Integration of the proven T2 Mac kernel management tool (`t2man`) into the ProxmoxVE community scripts ecosystem as a standardized helper script. The solution transforms an existing standalone script into a community-maintained tool that follows established patterns and conventions of the ProxmoxVE helper scripts project.

**Key Technical Components:**

- **Automated Hardware Detection:** Multi-layered T2 Mac hardware identification using DMI data, ACPI devices, SMC presence, and T2-specific hardware markers
- **Version Management:** Automated checking against GitHub API for latest kernel releases with intelligent version comparison
- **Installation Pipeline:** Streamlined download and installation of T2 Edge Kernel packages with dependency resolution
- **Hardware Configuration:** Integrated sensor detection and fan control setup specifically for T2 Mac thermal management
- **User Experience:** Interactive menu-driven interface with colored output, confirmation prompts, and comprehensive status reporting

**Key Differentiators from Existing Solutions:**

1. **Community Integration:** Unlike standalone scripts, this becomes part of the trusted ProxmoxVE community scripts collection with established maintenance and quality standards
2. **Comprehensive Hardware Support:** Goes beyond simple kernel installation to include thermal management and sensor configuration
3. **Intelligent Detection:** Advanced hardware detection prevents installation on incompatible systems
4. **Automated Updates:** Built-in version checking and update capabilities reduce manual maintenance
5. **Recovery Options:** Includes removal and rollback functionality for failed installations

**Why This Solution Will Succeed:**

- **Proven Foundation:** Built upon existing, tested codebase with real-world usage validation
- **Community Ecosystem:** Leverages the established ProxmoxVE helper scripts distribution and maintenance model
- **Specialized Focus:** Addresses specific T2 Mac needs rather than attempting generic Apple hardware support
- **User-Centric Design:** Maintains interactive approach that builds user confidence through clear feedback and confirmation steps

**High-Level Product Vision:**

Transform T2 Mac + ProxmoxVE from a complex, manual configuration process into a "just works" experience where users can confidently deploy and maintain their systems using community-supported tooling that integrates seamlessly with their existing ProxmoxVE management workflows.

## Target Users

### Primary User Segment: T2 Mac Homelab Enthusiasts

**Demographic/Firmographic Profile:**
- Technical enthusiasts and hobbyists running home virtualization labs
- Own Apple T2 Mac hardware (2018-2020 MacBook Pro, Mac Mini, iMac, iMac Pro)
- Age range: 25-45, typically software developers, IT professionals, or advanced hobbyists
- Geographic: Global, with concentration in North America and Europe
- Budget-conscious users repurposing existing Mac hardware for virtualization

**Current Behaviors and Workflows:**
- Regularly maintain and update ProxmoxVE environments through web interface and command line
- Follow ProxmoxVE community forums, Reddit communities, and YouTube tutorials for configuration guidance
- Comfortable with Linux command line but prefer automated solutions for complex procedures
- Typically manage 1-5 node clusters with mixed hardware configurations
- Update systems monthly or quarterly during planned maintenance windows

**Specific Needs and Pain Points:**
- Need reliable kernel updates without risking system stability
- Require proper thermal management to prevent overheating during intensive workloads
- Want integration with existing ProxmoxVE management workflows
- Need confidence that updates won't break existing VM configurations
- Require clear status information about kernel versions and hardware compatibility

**Goals They're Trying to Achieve:**
- Maximize performance and stability of T2 Mac hardware under ProxmoxVE
- Maintain up-to-date security patches and kernel improvements
- Minimize manual maintenance overhead while retaining control
- Build reliable, long-term virtualization infrastructure using existing hardware

### Secondary User Segment: Small Business IT Administrators

**Demographic/Firmographic Profile:**
- IT administrators in small businesses (10-50 employees)
- Organizations that standardized on Mac hardware and want to leverage existing assets
- Budget constraints that make repurposing Mac hardware attractive
- Limited IT staff (1-3 people) managing infrastructure

**Current Behaviors and Workflows:**
- Manage ProxmoxVE as part of broader infrastructure responsibilities
- Prefer standardized, documented procedures for system maintenance
- Balance between cost savings and operational reliability
- Update systems during planned maintenance windows with minimal downtime tolerance

**Specific Needs and Pain Points:**
- Need reliable, tested solutions that minimize risk to business operations
- Require clear documentation and support pathways
- Want automated solutions that reduce manual intervention requirements
- Need assurance that changes can be rolled back if problems occur

**Goals They're Trying to Achieve:**
- Extend useful life of existing Mac hardware investments
- Maintain reliable virtualization infrastructure with minimal overhead
- Ensure business continuity while optimizing infrastructure costs
- Access enterprise-grade virtualization capabilities within budget constraints

## Goals & Success Metrics

### Business Objectives

- **Community Adoption:** Achieve 50+ downloads within first 3 months of integration into ProxmoxVE community scripts
- **Code Quality:** Maintain 100% compatibility with ProxmoxVE community scripts standards and pass all automated testing
- **User Satisfaction:** Achieve 90% positive feedback in community forums and issue tracking within 6 months
- **Maintenance Burden:** Reduce average user setup time from 2-4 hours to under 30 minutes for T2 kernel management
- **Project Integration:** Successfully merge script into main ProxmoxVE community scripts repository within 60 days

### User Success Metrics

- **Installation Success Rate:** 95% of users complete T2 kernel installation without requiring manual intervention or troubleshooting
- **Update Compliance:** 80% of users maintain current T2 kernel versions within 30 days of release
- **Hardware Configuration Success:** 90% of users successfully configure fan control and sensor monitoring on first attempt
- **User Retention:** 85% of users continue using the tool for subsequent kernel updates rather than reverting to manual processes
- **Error Recovery:** 100% of users can successfully recover from failed installations using built-in removal functionality

### Key Performance Indicators (KPIs)

- **Script Reliability:** Successful execution rate across different T2 Mac hardware models and ProxmoxVE versions (Target: >95%)
- **Community Engagement:** Number of GitHub issues, feature requests, and community contributions (Target: 5+ meaningful contributions within 6 months)
- **Documentation Quality:** User-reported documentation gaps or confusion points (Target: <2 per quarter after initial release)
- **Performance Impact:** Script execution time for complete kernel installation and configuration (Target: <15 minutes on typical hardware)
- **Support Burden:** Number of support requests requiring manual intervention (Target: <5% of total usage)
- **Hardware Coverage:** Percentage of T2 Mac models successfully supported (Target: 100% of common models: 2018-2020 MacBook Pro, Mac Mini, iMac)

## MVP Scope

### Core Features (Must Have)

- **Multi-Method Hardware Detection:** Comprehensive T2 Mac identification using DMI manufacturer data, system product names, Apple SMC detection, ACPI device presence, and T2-specific hardware markers to ensure accurate hardware compatibility validation
- **Automated Kernel Management:** Download, install, and version management of T2 Edge Kernels directly from AdityaGarg8's GitHub releases with automatic .deb package handling and dependency resolution
- **Interactive Menu System:** User-friendly command-line interface with colored output, clear status information, confirmation prompts, and comprehensive system information display including current kernel, hardware status, and available updates
- **Fan Control Integration:** Complete sensor detection using lm-sensors, automatic /etc/modules configuration, t2fanrd service installation and management, with guided setup process for thermal management
- **Version Intelligence:** Real-time checking against GitHub API for latest releases, semantic version comparison to determine update necessity, and clear status reporting for current vs. available versions
- **Safe Installation/Removal:** Complete installation pipeline with proper cleanup, removal functionality for rollback scenarios, and kernel unpinning support using proxmox-boot-tool when available
- **Community Standards Compliance:** Full adherence to ProxmoxVE community scripts formatting, error handling, logging, and user experience standards

### Out of Scope for MVP

- Support for non-T2 Apple hardware (M1, M2, or pre-T2 Macs)
- Graphical user interface or web-based management
- Automatic kernel updates without user confirmation
- Custom kernel compilation or modification features
- Integration with ProxmoxVE web interface
- Multi-node cluster kernel management
- Backup and restore of kernel configurations
- Performance optimization beyond standard T2 kernel features

### MVP Success Criteria

**The MVP will be considered successful when:**

1. **Technical Functionality:** Script executes successfully on all common T2 Mac hardware models (2018-2020 MacBook Pro, Mac Mini, iMac) running ProxmoxVE 8.x
2. **User Experience:** Average user can complete full kernel installation and configuration in under 30 minutes without external documentation
3. **Reliability:** 95% success rate for installations across different hardware configurations and system states
4. **Community Integration:** Script passes ProxmoxVE community scripts review process and is accepted into the main repository
5. **Recovery Capability:** 100% of failed installations can be cleanly reverted using the built-in removal functionality

## Post-MVP Vision

### Phase 2 Features

**Extended Apple Hardware Support:** Expand compatibility to include Apple Silicon (M1/M2) Macs and pre-T2 Apple hardware, requiring research into different kernel requirements and hardware-specific drivers for broader Mac ecosystem coverage.

**ProxmoxVE Web Interface Integration:** Develop web UI components that integrate with ProxmoxVE's existing interface, providing kernel status dashboards, update notifications, and one-click management capabilities directly within the familiar ProxmoxVE web environment.

**Automated Update Scheduling:** Implement configurable automatic kernel updates with maintenance window scheduling, rollback automation, and integration with ProxmoxVE's existing update mechanisms for hands-off kernel management.

**Multi-Node Cluster Support:** Extend functionality to manage T2 kernels across ProxmoxVE clusters, including coordinated rolling updates, cluster-wide status reporting, and centralized configuration management.

**Advanced Hardware Monitoring:** Enhanced sensor monitoring with historical data collection, alerting thresholds, thermal performance analytics, and integration with ProxmoxVE's existing monitoring infrastructure.

### Long-term Vision

**Complete Apple Hardware Ecosystem Integration:** Transform ProxmoxVE into the premier virtualization platform for repurposing Apple hardware, with comprehensive support across all Mac models, automated hardware optimization, and specialized configurations for different Apple hardware generations.

**Community-Driven Hardware Support:** Establish a framework where community members can contribute hardware-specific scripts and configurations, creating a comprehensive library of specialized tools for various hardware platforms beyond just Apple.

**Intelligent Infrastructure Management:** Develop AI-assisted recommendations for kernel updates, hardware optimization suggestions, and predictive maintenance alerts based on hardware performance patterns and community usage data.

### Expansion Opportunities

**Hardware Vendor Partnerships:** Potential collaboration with other specialized hardware vendors (ARM-based systems, edge computing devices, embedded platforms) to create similar integrated management tools within the ProxmoxVE ecosystem.

**Enterprise Distribution:** Package as enterprise-supported addon for organizations standardizing on repurposed Mac hardware, with professional support, SLA guarantees, and enterprise-grade monitoring and reporting capabilities.

**Educational/Research Markets:** Target academic institutions and research organizations that commonly repurpose Mac hardware for compute clusters, providing specialized educational documentation and research-focused configurations.

**Cloud Integration:** Hybrid cloud capabilities that allow T2 Mac-based ProxmoxVE nodes to integrate seamlessly with cloud providers, enabling burst computing and hybrid infrastructure scenarios.

## Technical Considerations

### Platform Requirements

- **Target Platforms:** Linux-based ProxmoxVE 8.x environments running on Apple T2 Mac hardware (2018-2020 MacBook Pro, Mac Mini, iMac, iMac Pro)
- **Browser/OS Support:** Command-line interface accessible via SSH, local terminal, or ProxmoxVE shell - no browser dependencies required
- **Performance Requirements:** Minimal system resource impact during execution, temporary disk space requirement of ~500MB for kernel package downloads, network bandwidth for GitHub API calls and package downloads

### Technology Preferences

- **Frontend:** Bash-based command-line interface with colored terminal output using ANSI escape codes for status indication and user experience enhancement
- **Backend:** Native Linux system tools (bash, curl, wget, dpkg, apt, systemctl) with minimal external dependencies to ensure compatibility across ProxmoxVE installations
- **Database:** No persistent database required - relies on system package manager state, GitHub API for version information, and filesystem-based configuration
- **Hosting/Infrastructure:** Distributed as single executable script through ProxmoxVE community scripts repository, no additional hosting infrastructure required

### Architecture Considerations

**Repository Structure:**
- Single-file bash script following ProxmoxVE community scripts naming conventions
- Integration into existing community-scripts repository structure under appropriate hardware-specific category
- Maintenance through standard GitHub pull request workflow with community review process

**Service Architecture:**
- Standalone script execution model - no persistent services or daemons required
- Integration with existing system services (systemctl) for fan control daemon management
- Leverages ProxmoxVE's existing package management and boot configuration infrastructure

**Integration Requirements:**
- GitHub API integration for release version checking and package download links
- ProxmoxVE package management system compatibility (apt/dpkg)
- System hardware detection interfaces (dmidecode, sysfs, ACPI)
- Integration with proxmox-boot-tool for kernel pinning/unpinning operations

**Security/Compliance:**
- Root privilege requirement for system-level kernel and package operations
- Secure temporary file handling with proper cleanup procedures
- Input validation and command injection prevention for user-supplied data
- Network security considerations for GitHub API calls and package downloads

**Documentation Requirements:**
- **Community Standards Compliance:** Comprehensive inline script documentation following ProxmoxVE community standards with clear function descriptions and usage examples
- **Website Integration:** Integration with community-scripts.github.io/ProxmoxVE/ website documentation structure including script description, compatibility matrix, and usage instructions
- **Repository Documentation:** GitHub repository documentation including detailed README with installation steps, troubleshooting guide, and hardware compatibility information  
- **Contribution Guidelines:** Community contribution guidelines compliance with standardized pull request templates, issue reporting procedures, and code review requirements
- **Interactive Help System:** Built-in help system within script providing usage guidance, option explanations, and troubleshooting steps accessible via menu system
- **Compatibility Documentation:** Clear documentation for ProxmoxVE 8.x+ compatibility requirements and bash/curl dependency specifications as per community standards
- **Community Channels:** Integration with GitHub Discussions for user questions and Discord server for real-time community support

## Constraints & Assumptions

### Constraints

**Budget:** Zero direct budget allocation - development relies on volunteer community contributions and existing ProxmoxVE infrastructure without additional hosting or development costs

**Timeline:** Target integration within 60 days from project approval, constrained by community review cycles, testing requirements across multiple hardware configurations, and volunteer development availability

**Resources:** Single developer (contributor) with community review support, limited to testing hardware availability, dependency on community beta testers for comprehensive Mac hardware model validation

**Technical:** 
- Must maintain compatibility with ProxmoxVE 8.x+ baseline requirements
- Limited to bash scripting environment with standard Linux tools (no additional runtime dependencies)
- GitHub API rate limiting constraints for version checking functionality
- AdityaGarg8's T2 kernel repository availability and release cadence dependencies
- Apple T2 hardware-specific limitations and driver compatibility constraints

### Key Assumptions

- **Hardware Adoption:** T2 Mac usage in ProxmoxVE environments represents sufficient user base (estimated 50+ potential users) to justify specialized tooling development and maintenance overhead

- **Community Acceptance:** ProxmoxVE community scripts maintainers will accept hardware-specific tools as valuable additions to the ecosystem rather than niche implementations

- **Upstream Stability:** AdityaGarg8's pve-edge-kernel-t2 project will continue active development and maintain compatibility with current ProxmoxVE versions

- **User Technical Proficiency:** Target users possess sufficient Linux administration skills to handle root-level kernel modifications and troubleshoot basic system configuration issues

- **Network Reliability:** Users have reliable internet connectivity for GitHub API access and package downloads during kernel management operations

- **Hardware Lifecycle:** Apple T2 Mac hardware will remain viable for ProxmoxVE deployment for 2-3 years minimum, justifying development investment

- **Community Infrastructure:** GitHub-based community scripts distribution model will remain stable and continue serving as primary deployment mechanism

- **Maintenance Sustainability:** Community-driven maintenance model will provide sufficient ongoing support without requiring dedicated maintainer resources

## Risks & Open Questions

### Key Risks

- **Hardware Detection False Positives:** Multi-method detection logic could incorrectly identify non-T2 systems as compatible, leading to kernel installation failures or system instability on incompatible hardware

- **Upstream Dependency Failure:** AdityaGarg8's T2 kernel project discontinuation or breaking changes could render the entire tool non-functional without alternative kernel sources or migration paths

- **Community Maintenance Burden:** Complex hardware-specific tooling may exceed community volunteer capacity for ongoing maintenance, testing, and support as hardware and software ecosystems evolve

- **System Recovery Complications:** Kernel-level modifications carry inherent risk of creating unbootable systems, potentially requiring advanced recovery procedures beyond typical ProxmoxVE user expertise

- **Version Compatibility Matrix:** Rapid evolution of ProxmoxVE versions combined with T2 kernel development could create unsustainable compatibility testing and validation requirements

### Open Questions

- What is the actual size of the T2 Mac + ProxmoxVE user community and is it sufficient to justify specialized tooling development and maintenance?

- How will the script handle edge cases like mixed-hardware clusters where only some nodes are T2 Macs?

- Should the tool include automated rollback mechanisms for failed kernel installations, and how complex should these be?

- What level of logging and diagnostic information should be captured to support community troubleshooting?

- How should the script handle network-restricted environments where GitHub API access may be limited or blocked?

- What is the optimal update notification strategy that balances user awareness with avoiding update fatigue?

- Should the tool integrate with existing ProxmoxVE backup mechanisms to create recovery points before kernel changes?

### Areas Needing Further Research

- **Community Size Validation:** Survey or analysis of ProxmoxVE forums, Reddit communities, and GitHub discussions to quantify T2 Mac user base and validate market demand

- **Hardware Compatibility Matrix:** Comprehensive testing across all T2 Mac models (2018-2020 MacBook Pro variants, Mac Mini configurations, iMac/iMac Pro models) to establish definitive compatibility data

- **ProxmoxVE Integration Patterns:** Research existing community scripts for established patterns around system-level modifications, error handling, and user experience conventions

- **Recovery Mechanism Design:** Investigation of ProxmoxVE boot recovery options, backup integration possibilities, and safe kernel rollback procedures specific to T2 hardware

- **Alternative Kernel Sources:** Research backup kernel sources or compilation options in case primary upstream becomes unavailable

- **Performance Impact Analysis:** Benchmarking T2 kernel performance characteristics compared to standard ProxmoxVE kernels across different workload types

- **Regulatory and Licensing Considerations:** Review of kernel licensing, redistribution requirements, and any Apple hardware-specific licensing implications

## Appendices

### A. Research Summary

**Existing Script Analysis:**
Analysis of the current `t2man` script reveals a mature, functional implementation with comprehensive hardware detection, interactive user experience, and robust error handling. The script demonstrates proven effectiveness in real-world T2 Mac environments with sophisticated version comparison logic and multi-layered hardware validation.

**Community Context Research:**
Investigation of ProxmoxVE community scripts ecosystem shows active development with 300+ existing scripts, established contribution workflows through GitHub, and strong community engagement via Discord and forums. The project welcomes hardware-specific tools and maintains compatibility standards for ProxmoxVE 8.x environments.

**Technical Feasibility Assessment:**
The T2 Edge Kernel project by AdityaGarg8 maintains active development with regular releases, stable API structure, and proven compatibility with ProxmoxVE environments. Integration requirements align with existing community script patterns and technical constraints.

### B. Stakeholder Input

**Primary Developer Insights:**
Original script author (Si Cruse) has validated functionality across multiple T2 Mac models and identified key integration requirements for community adoption, including documentation standards, testing procedures, and maintenance considerations.

**Community Scripts Project Alignment:**
Research indicates strong alignment with ProxmoxVE community scripts mission of simplifying environment setup and management, with established processes for accepting hardware-specific contributions and maintaining quality standards.

### C. References

**Technical Resources:**
- AdityaGarg8/pve-edge-kernel-t2 GitHub Repository: https://github.com/AdityaGarg8/pve-edge-kernel-t2
- ProxmoxVE Community Scripts: https://github.com/community-scripts/ProxmoxVE
- ProxmoxVE Helper Scripts Website: https://community-scripts.github.io/ProxmoxVE/

**Documentation Standards:**
- ProxmoxVE Community Scripts Contribution Guidelines
- GitHub API Documentation for release management integration
- T2 Mac Hardware Specifications and Compatibility References

**Community Channels:**
- ProxmoxVE Community Scripts Discord Server
- GitHub Discussions for technical questions and community feedback
- ProxmoxVE Forums for broader community engagement and support

## Next Steps

### Immediate Actions

1. **Refactor Existing Script for Community Standards** - Adapt current `t2man` script to align with ProxmoxVE community scripts formatting, naming conventions, and documentation requirements

2. **Create Comprehensive Testing Plan** - Develop testing matrix covering T2 Mac hardware models (2018-2020 MacBook Pro, Mac Mini, iMac variants) and ProxmoxVE versions (8.0, 8.1, 8.2+)

3. **Engage ProxmoxVE Community for Validation** - Post in GitHub Discussions and Discord to validate community interest, gather feedback on approach, and identify potential beta testers

4. **Draft Community Scripts Pull Request** - Prepare initial pull request with refactored script, documentation, and testing evidence following community contribution guidelines

5. **Establish Beta Testing Program** - Recruit 5-10 community members with T2 Mac hardware for comprehensive testing across different configurations and use cases

### PM Handoff

This Project Brief provides the full context for **T2 Mac Custom Kernel Management for ProxmoxVE**. Please start in 'PRD Generation Mode', review the brief thoroughly to work with the user to create the PRD section by section as the template indicates, asking for any necessary clarification or suggesting improvements.

The project is ready to move from strategic planning to detailed product requirements definition, with clear scope boundaries, success metrics, and implementation considerations established through this comprehensive brief.