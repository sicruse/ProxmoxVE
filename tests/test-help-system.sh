#!/usr/bin/env bash

# Test file: test-help-system.sh
# Description: Tests for the T2 Mac Manager inline help system functionality
# Author: Dev Agent (Story 1.4 Implementation)

# Set strict error handling
set -euo pipefail

# Test configuration  
TEST_SCRIPT="tools/pve/t2mac-manager.sh"
readonly TEST_NAME="T2 Mac Manager Help System Tests"
readonly TEMP_DIR=$(mktemp -d)

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

##
# test_assert - Simple test assertion function
#
# Parameters:
#   $1: Expected value
#   $2: Actual value  
#   $3: Test description
##
test_assert() {
    local expected="$1"
    local actual="$2" 
    local description="$3"
    
    ((TESTS_TOTAL++))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ PASS: $description"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $description"
        echo "   Expected: $expected"
        echo "   Actual: $actual"
        ((TESTS_FAILED++))
    fi
}

##
# test_contains - Test if output contains expected string
#
# Parameters:
#   $1: Output to check
#   $2: Expected string
#   $3: Test description
##
test_contains() {
    local output="$1"
    local expected="$2"
    local description="$3"
    
    ((TESTS_TOTAL++))
    
    if [[ "$output" == *"$expected"* ]]; then
        echo "✅ PASS: $description"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $description"
        echo "   Expected to contain: $expected"
        echo "   Actual output: ${output:0:200}..."
        ((TESTS_FAILED++))
    fi
}

##
# extract_help_functions - Extract help functions from the script
##
extract_help_functions() {
    local script_path="$1"
    local temp_file="$TEMP_DIR/help_functions.sh"
    
    # Extract help functions and their dependencies
    cat << 'EOF' > "$temp_file"
#!/usr/bin/env bash

# Mock community functions for testing
msg_info() { echo "INFO: $*"; }
msg_ok() { echo "OK: $*"; }
msg_warn() { echo "WARN: $*"; }
msg_error() { echo "ERROR: $*"; }

EOF
    
    # Extract help functions from the main script
    sed -n '/^show_help_/,/^}/p' "$script_path" >> "$temp_file"
    
    # Make executable
    chmod +x "$temp_file"
    
    echo "$temp_file"
}

##
# test_help_function_existence - Test that help functions are defined
##
test_help_function_existence() {
    echo "Testing help function existence..."
    
    local script_content
    script_content=$(<"$TEST_SCRIPT")
    
    # Test for each required help function
    local help_functions=(
        "show_help_main"
        "show_help_install"
        "show_help_fan_control" 
        "show_help_hardware"
        "show_help_removal"
    )
    
    for func in "${help_functions[@]}"; do
        if [[ "$script_content" == *"$func() {"* ]]; then
            test_assert "found" "found" "$func function is defined"
        else
            test_assert "found" "missing" "$func function is defined"
        fi
    done
}

##
# test_help_function_output - Test help function output content
##
test_help_function_output() {
    echo "Testing help function output content..."
    
    local help_script
    help_script=$(extract_help_functions "$TEST_SCRIPT")
    
    # Test show_help_main output
    local main_help_output
    main_help_output=$(bash -c "source '$help_script' && show_help_main" 2>/dev/null || echo "ERROR_RUNNING")
    
    test_contains "$main_help_output" "T2 Mac Kernel Manager - Help" "Main help contains title"
    test_contains "$main_help_output" "OVERVIEW:" "Main help contains overview section"
    test_contains "$main_help_output" "MAIN MENU OPTIONS:" "Main help contains menu options"
    test_contains "$main_help_output" "SYSTEM REQUIREMENTS:" "Main help contains system requirements"
    test_contains "$main_help_output" "SUPPORTED HARDWARE:" "Main help contains supported hardware"
    
    # Test show_help_install output
    local install_help_output
    install_help_output=$(bash -c "source '$help_script' && show_help_install" 2>/dev/null || echo "ERROR_RUNNING")
    
    test_contains "$install_help_output" "T2 Kernel Installation Help" "Install help contains title"
    test_contains "$install_help_output" "INSTALLATION PROCESS:" "Install help contains process section"
    test_contains "$install_help_output" "WHAT GETS INSTALLED:" "Install help contains installation details"
    test_contains "$install_help_output" "SAFETY FEATURES:" "Install help contains safety information"
    test_contains "$install_help_output" "TROUBLESHOOTING:" "Install help contains troubleshooting"
    
    # Test show_help_fan_control output
    local fan_help_output
    fan_help_output=$(bash -c "source '$help_script' && show_help_fan_control" 2>/dev/null || echo "ERROR_RUNNING")
    
    test_contains "$fan_help_output" "Fan Control Configuration Help" "Fan help contains title"
    test_contains "$fan_help_output" "FAN CONTROL OVERVIEW:" "Fan help contains overview"
    test_contains "$fan_help_output" "CONFIGURATION PROCESS:" "Fan help contains configuration steps"
    test_contains "$fan_help_output" "REQUIRED COMPONENTS:" "Fan help contains components list"
    
    # Test show_help_hardware output  
    local hardware_help_output
    hardware_help_output=$(bash -c "source '$help_script' && show_help_hardware" 2>/dev/null || echo "ERROR_RUNNING")
    
    test_contains "$hardware_help_output" "Hardware Compatibility Guide" "Hardware help contains title"
    test_contains "$hardware_help_output" "FULLY SUPPORTED:" "Hardware help contains supported section"
    test_contains "$hardware_help_output" "MacBook Pro" "Hardware help contains MacBook Pro info"
    test_contains "$hardware_help_output" "DETECTION METHODS:" "Hardware help contains detection methods"
    
    # Test show_help_removal output
    local removal_help_output
    removal_help_output=$(bash -c "source '$help_script' && show_help_removal" 2>/dev/null || echo "ERROR_RUNNING")
    
    test_contains "$removal_help_output" "T2 Kernel Removal Help" "Removal help contains title"
    test_contains "$removal_help_output" "REMOVAL OVERVIEW:" "Removal help contains overview"
    test_contains "$removal_help_output" "REMOVAL PROCESS:" "Removal help contains process steps"
    test_contains "$removal_help_output" "WHAT GETS REMOVED:" "Removal help contains removal details"
}

##
# test_help_menu_integration - Test help menu integration
##
test_help_menu_integration() {
    echo "Testing help menu integration..."
    
    local script_content
    script_content=$(<"$TEST_SCRIPT")
    
    # Check for help menu option in main menu
    test_contains "$script_content" "h) Help & Documentation" "Help menu option exists in main menu"
    
    # Check for help menu case handling
    test_contains "$script_content" "h|H)" "Help menu case handling exists"
    
    # Check for help submenu options
    test_contains "$script_content" "Select help topic:" "Help submenu prompt exists"
    test_contains "$script_content" "Main Help - Overview" "Main help option in submenu"
    test_contains "$script_content" "Installation Help" "Installation help option in submenu"
    test_contains "$script_content" "Fan Control Help" "Fan control help option in submenu"
    test_contains "$script_content" "Hardware Compatibility" "Hardware help option in submenu"
    test_contains "$script_content" "Removal Help" "Removal help option in submenu"
}

##
# test_help_function_structure - Test help function structure and formatting
##
test_help_function_structure() {
    echo "Testing help function structure and formatting..."
    
    local help_script
    help_script=$(extract_help_functions "$TEST_SCRIPT")
    
    # Test that help functions use proper box drawing characters
    local main_help_output
    main_help_output=$(bash -c "source '$help_script' && show_help_main" 2>/dev/null || echo "ERROR_RUNNING")
    
    test_contains "$main_help_output" "╭" "Main help uses proper box drawing top-left"
    test_contains "$main_help_output" "╮" "Main help uses proper box drawing top-right"
    test_contains "$main_help_output" "╰" "Main help uses proper box drawing bottom-left"
    test_contains "$main_help_output" "╯" "Main help uses proper box drawing bottom-right"
    
    # Test bullet point formatting
    test_contains "$main_help_output" "•" "Main help uses bullet points"
    
    # Test that functions don't produce errors
    local functions_to_test=(
        "show_help_main"
        "show_help_install"
        "show_help_fan_control"
        "show_help_hardware"
        "show_help_removal"
    )
    
    for func in "${functions_to_test[@]}"; do
        local output
        output=$(bash -c "source '$help_script' && $func" 2>&1)
        local exit_code=$?
        
        test_assert "0" "$exit_code" "$func executes without errors"
        
        # Test that output is not empty
        if [[ -n "$output" ]]; then
            test_assert "non-empty" "non-empty" "$func produces output"
        else
            test_assert "non-empty" "empty" "$func produces output"
        fi
    done
}

##
# test_documentation_compliance - Test community documentation compliance
##
test_documentation_compliance() {
    echo "Testing community documentation compliance..."
    
    local script_content
    script_content=$(<"$TEST_SCRIPT")
    
    # Test function documentation format
    test_contains "$script_content" "# show_help_main - Display main help information" "Main help function has proper documentation header"
    test_contains "$script_content" "# Description:" "Help functions use standard description format"
    
    # Test that help functions follow community patterns
    local help_script
    help_script=$(extract_help_functions "$TEST_SCRIPT")
    
    local main_help_output
    main_help_output=$(bash -c "source '$help_script' && show_help_main" 2>/dev/null || echo "ERROR_RUNNING")
    
    # Test for community links
    test_contains "$main_help_output" "github.com/community-scripts/ProxmoxVE" "Contains community GitHub link"
    test_contains "$main_help_output" "ProxmoxVE" "References ProxmoxVE"
    
    # Test for proper formatting
    test_contains "$main_help_output" "T2 security chip" "Contains T2 chip reference"
    test_contains "$main_help_output" "2018-2020" "Contains supported year range"
}

##
# run_all_tests - Execute all test suites
##
run_all_tests() {
    echo "🧪 Starting $TEST_NAME"
    echo "======================================"
    
    # Check if test script exists
    if [[ ! -f "$TEST_SCRIPT" ]]; then
        echo "❌ ERROR: Test script not found at $TEST_SCRIPT"
        exit 1
    fi
    
    # Run test suites
    test_help_function_existence
    echo ""
    
    test_help_function_output
    echo ""
    
    test_help_menu_integration
    echo ""
    
    test_help_function_structure  
    echo ""
    
    test_documentation_compliance
    echo ""
    
    # Display results
    echo "======================================"
    echo "📊 Test Results Summary:"
    echo "   Total Tests: $TESTS_TOTAL"
    echo "   Passed: $TESTS_PASSED"
    echo "   Failed: $TESTS_FAILED"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✅ All tests passed!"
        return 0
    else
        echo "❌ $TESTS_FAILED test(s) failed."
        return 1
    fi
}

# Main execution
main() {
    # Change to repository root and set TEST_SCRIPT
    local script_path
    if [[ -f "tools/pve/t2mac-manager.sh" ]]; then
        script_path="tools/pve/t2mac-manager.sh"
    elif [[ -f "../tools/pve/t2mac-manager.sh" ]]; then
        cd ..
        script_path="tools/pve/t2mac-manager.sh"
    else
        echo "❌ ERROR: Could not find t2mac-manager.sh script"
        exit 1
    fi
    
    # Set TEST_SCRIPT for testing
    TEST_SCRIPT="$script_path"
    
    run_all_tests
}

# Execute if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi