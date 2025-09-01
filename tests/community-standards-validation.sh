#!/usr/bin/env bash

# Community Standards Validation Test for T2 Mac Manager
# Tests compliance with ProxmoxVE community script standards

set -e

SCRIPT_PATH="/Users/sicruse/Development/RESEARCH/ProxmoxVE/tools/pve/t2mac-manager.sh"
PASS_COUNT=0
FAIL_COUNT=0

print_result() {
    local test_name="$1"
    local result="$2"
    
    if [ "$result" = "PASS" ]; then
        echo "✓ $test_name: PASS"
        ((PASS_COUNT++))
    else
        echo "✗ $test_name: FAIL"
        ((FAIL_COUNT++))
    fi
}

echo "=== Community Standards Validation Test ==="
echo "Testing script: $SCRIPT_PATH"
echo ""

# Test 1: Script has proper shebang
echo "Running Test 1: Shebang validation..."
if head -1 "$SCRIPT_PATH" | grep -q "#!/usr/bin/env bash"; then
    print_result "Shebang Format" "PASS"
else
    print_result "Shebang Format" "FAIL"
fi

# Test 2: Community function sourcing
echo "Running Test 2: Community function sourcing..."
if grep -q "source <(curl.*community-scripts.*core.func" "$SCRIPT_PATH"; then
    print_result "Community Function Source" "PASS"
else
    print_result "Community Function Source" "FAIL"
fi

# Test 3: Copyright and license header
echo "Running Test 3: Header compliance..."
if grep -q "Copyright.*tteck.*Si Cruse" "$SCRIPT_PATH" && grep -q "License: MIT" "$SCRIPT_PATH"; then
    print_result "Copyright/License Header" "PASS"
else
    print_result "Copyright/License Header" "FAIL"
fi

# Test 4: Community messaging functions
echo "Running Test 4: Community messaging functions..."
if grep -q "msg_info\|msg_ok\|msg_error\|msg_warn" "$SCRIPT_PATH" && ! grep -q "print_message" "$SCRIPT_PATH"; then
    print_result "Community Messaging Functions" "PASS"
else
    print_result "Community Messaging Functions" "FAIL"
fi

# Test 5: Error handling framework
echo "Running Test 5: Error handling framework..."
if grep -q "catch_errors" "$SCRIPT_PATH"; then
    print_result "Error Handling Framework" "PASS"
else
    print_result "Error Handling Framework" "FAIL"
fi

# Test 6: Input validation functions
echo "Running Test 6: Input validation..."
if grep -q "validate_input" "$SCRIPT_PATH" && grep -q "validate_version" "$SCRIPT_PATH"; then
    print_result "Input Validation Functions" "PASS"
else
    print_result "Input Validation Functions" "FAIL"
fi

# Test 7: Dependency validation
echo "Running Test 7: Dependency validation..."
if grep -q "validate_community_dependencies" "$SCRIPT_PATH"; then
    print_result "Dependency Validation" "PASS"
else
    print_result "Dependency Validation" "FAIL"
fi

# Test 8: Function documentation
echo "Running Test 8: Function documentation..."
if grep -q "^##$" "$SCRIPT_PATH" && grep -q "# Description:" "$SCRIPT_PATH"; then
    print_result "Function Documentation" "PASS"
else
    print_result "Function Documentation" "FAIL"
fi

# Test 9: Consistent exit codes
echo "Running Test 9: Exit code standards..."
if grep -q "EXIT_SUCCESS\|EXIT_FAILURE\|EXIT_INVALID_INPUT" "$SCRIPT_PATH"; then
    print_result "Consistent Exit Codes" "PASS"
else
    print_result "Consistent Exit Codes" "FAIL"
fi

# Test 10: Syntax validation
echo "Running Test 10: Script syntax validation..."
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    print_result "Script Syntax" "PASS"
else
    print_result "Script Syntax" "FAIL"
fi

echo ""
echo "=== Test Results ==="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Total: $((PASS_COUNT + FAIL_COUNT))"

if [ $FAIL_COUNT -eq 0 ]; then
    echo ""
    echo "🎉 All community standards validation tests passed!"
    exit 0
else
    echo ""
    echo "❌ Some tests failed. Please review and fix the issues."
    exit 1
fi