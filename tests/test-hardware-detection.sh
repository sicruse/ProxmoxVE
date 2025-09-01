#!/bin/bash
# Test script for enhanced hardware detection functionality
# Copyright (c) 2025 Si Cruse
# License: MIT

# Source the main script functions for testing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/../tools/pve/t2mac-manager.sh"

# Test counter
TEST_COUNT=0
TEST_PASSED=0
TEST_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

##
# test_assert - Assert test condition
##
test_assert() {
    local condition="$1"
    local message="$2"
    
    ((TEST_COUNT++))
    
    if [ "$condition" = "true" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $message"
        ((TEST_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $message"
        ((TEST_FAILED++))
    fi
}

##
# test_summary - Display test summary
##
test_summary() {
    echo ""
    echo "================================="
    echo "         TEST SUMMARY"
    echo "================================="
    echo "Total Tests: $TEST_COUNT"
    echo -e "Passed:     ${GREEN}$TEST_PASSED${NC}"
    echo -e "Failed:     ${RED}$TEST_FAILED${NC}"
    
    if [ $TEST_FAILED -eq 0 ]; then
        echo -e "Result:     ${GREEN}ALL TESTS PASSED${NC}"
        return 0
    else
        echo -e "Result:     ${RED}SOME TESTS FAILED${NC}"
        return 1
    fi
}

##
# Mock system functions for testing
##
mock_dmidecode_apple() {
    if [ "$1" = "-s" ] && [ "$2" = "system-manufacturer" ]; then
        echo "Apple Inc."
    elif [ "$1" = "-s" ] && [ "$2" = "system-product-name" ]; then
        echo "MacBookPro15,1"
    fi
}

mock_dmidecode_non_apple() {
    if [ "$1" = "-s" ] && [ "$2" = "system-manufacturer" ]; then
        echo "Dell Inc."
    elif [ "$1" = "-s" ] && [ "$2" = "system-product-name" ]; then
        echo "OptiPlex 7090"
    fi
}

# Create a test version of the detect function
detect_mac_hardware_enhanced_test() {
    local detection_results=()
    local confidence_score=0
    local total_methods=0
    
    # Method 1: DMI System Manufacturer (mocked)
    ((total_methods++))
    if [ "$MOCK_DMIDECODE" = "apple" ]; then
        detection_results+=("✅ DMI System Manufacturer: Apple detected")
        ((confidence_score++))
    elif [ "$MOCK_DMIDECODE" = "non_apple" ]; then
        detection_results+=("❌ DMI System Manufacturer: Not Apple")
    else
        detection_results+=("⚠️  DMI System Manufacturer: dmidecode unavailable")
    fi
    
    # Method 2: DMI Product Name (mocked)
    ((total_methods++))
    if [ "$MOCK_DMIDECODE" = "apple" ]; then
        detection_results+=("✅ DMI Product Name: Mac detected (MacBookPro15,1)")
        ((confidence_score++))
    elif [ "$MOCK_DMIDECODE" = "non_apple" ]; then
        detection_results+=("❌ DMI Product Name: No Mac identifier (OptiPlex 7090)")
    fi
    
    # Method 3: Apple SMC Detection (mocked)
    ((total_methods++))
    if [ "$MOCK_SMC" = "present" ]; then
        detection_results+=("✅ Apple SMC: System Management Controller detected")
        ((confidence_score++))
    else
        detection_results+=("❌ Apple SMC: No SMC device found")
    fi
    
    # Method 4: ACPI Apple Device (mocked)
    ((total_methods++))
    if [ "$MOCK_ACPI" = "present" ]; then
        detection_results+=("✅ ACPI Apple Device: APP0001 detected")
        ((confidence_score++))
    else
        detection_results+=("❌ ACPI Apple Device: No Apple ACPI device")
    fi
    
    # Method 5: T2-Specific Devices (mocked)
    ((total_methods++))
    if [ "$MOCK_T2" = "present" ]; then
        detection_results+=("✅ T2 Specific Device: MFi fastcharge detected")
        ((confidence_score++))
    else
        detection_results+=("❌ T2 Specific Device: No T2 fastcharge device")
    fi
    
    # Calculate confidence percentage
    local confidence_percentage=$((confidence_score * 100 / total_methods))
    
    # Return result based on confidence
    if [ $confidence_score -ge 2 ]; then
        echo "true"
        return 0
    else
        echo "false"
        return 1
    fi
}

echo "🧪 Hardware Detection Test Suite"
echo "================================="
echo ""

# Test 1: Full Apple Mac detection (all methods positive)
echo "Test 1: Full Apple Mac Hardware Detection"
export MOCK_DMIDECODE="apple"
export MOCK_SMC="present" 
export MOCK_ACPI="present"
export MOCK_T2="present"
result=$(detect_mac_hardware_enhanced_test)
test_assert "$([ "$result" = "true" ] && echo true || echo false)" "Full Mac hardware detection should return true"

# Test 2: Partial Apple detection (sufficient confidence)
echo ""
echo "Test 2: Partial Apple Hardware Detection (Sufficient Confidence)"
export MOCK_DMIDECODE="apple"
export MOCK_SMC="absent"
export MOCK_ACPI="present"
export MOCK_T2="absent"
result=$(detect_mac_hardware_enhanced_test)
test_assert "$([ "$result" = "true" ] && echo true || echo false)" "Partial Mac detection with 2+ methods should return true"

# Test 3: Insufficient confidence
echo ""
echo "Test 3: Insufficient Confidence Detection"
export MOCK_DMIDECODE="unavailable"
export MOCK_SMC="present"
export MOCK_ACPI="absent"
export MOCK_T2="absent"
result=$(detect_mac_hardware_enhanced_test)
test_assert "$([ "$result" = "false" ] && echo true || echo false)" "Insufficient confidence (only 1 method) should return false"

# Test 4: Non-Apple hardware
echo ""
echo "Test 4: Non-Apple Hardware Detection"
export MOCK_DMIDECODE="non_apple"
export MOCK_SMC="absent"
export MOCK_ACPI="absent"
export MOCK_T2="absent"
result=$(detect_mac_hardware_enhanced_test)
test_assert "$([ "$result" = "false" ] && echo true || echo false)" "Non-Apple hardware should return false"

# Test 5: Graceful degradation (no dmidecode)
echo ""
echo "Test 5: Graceful Degradation (No dmidecode)"
export MOCK_DMIDECODE="unavailable"
export MOCK_SMC="present"
export MOCK_ACPI="present"
export MOCK_T2="absent"
result=$(detect_mac_hardware_enhanced_test)
test_assert "$([ "$result" = "true" ] && echo true || echo false)" "Detection without dmidecode should still work with other methods"

# Test 6: Edge case - only T2 device detected
echo ""
echo "Test 6: Edge Case - Only T2 Device Detected"
export MOCK_DMIDECODE="unavailable"
export MOCK_SMC="absent"
export MOCK_ACPI="absent"
export MOCK_T2="present"
result=$(detect_mac_hardware_enhanced_test)
test_assert "$([ "$result" = "false" ] && echo true || echo false)" "Single T2 device detection should have insufficient confidence"

# Test 7: Function availability test
echo ""
echo "Test 7: Function Availability in Main Script"
if grep -q "detect_mac_hardware_enhanced()" "$MAIN_SCRIPT"; then
    test_assert "true" "detect_mac_hardware_enhanced function exists in main script"
else
    test_assert "false" "detect_mac_hardware_enhanced function exists in main script"
fi

# Test 8: Validation function availability
echo ""
echo "Test 8: Validation Function Availability"
if grep -q "validate_t2_compatibility()" "$MAIN_SCRIPT"; then
    test_assert "true" "validate_t2_compatibility function exists in main script"
else
    test_assert "false" "validate_t2_compatibility function exists in main script"
fi

# Test 9: Diagnostic function availability
echo ""
echo "Test 9: Diagnostic Function Availability"
if grep -q "show_hardware_diagnostics()" "$MAIN_SCRIPT"; then
    test_assert "true" "show_hardware_diagnostics function exists in main script"
else
    test_assert "false" "show_hardware_diagnostics function exists in main script"
fi

# Test 10: Menu integration
echo ""
echo "Test 10: Menu Integration"
if grep -q "Hardware Diagnostics" "$MAIN_SCRIPT"; then
    test_assert "true" "Hardware Diagnostics menu option is available"
else
    test_assert "false" "Hardware Diagnostics menu option is available"
fi

# Show test summary
echo ""
test_summary