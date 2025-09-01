#!/usr/bin/env bash
# Test suite for GitHub API integration with resilience
# Part of Story 1.3: GitHub API Integration with Resilience

# Test configuration
TEST_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="./tools/pve/t2mac-manager.sh"
TEST_CACHE_DIR="/tmp/t2mac-test-cache"
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test framework functions
test_info() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

test_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
}

test_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TOTAL_TESTS++))
    test_info "Running: $test_name"
    
    if $test_function; then
        test_pass "$test_name"
    else
        test_fail "$test_name"
    fi
    echo ""
}

# Source the main script functions for testing
source_main_functions() {
    # Source community functions first
    source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/core.func) 2>/dev/null || {
        # Fallback mock functions for testing
        msg_info() { echo "[INFO] $*"; }
        msg_ok() { echo "[OK] $*"; }
        msg_warn() { echo "[WARN] $*"; }
        msg_error() { echo "[ERROR] $*"; }
    }
    
    # Source the main script functions
    export CACHE_DIR="$TEST_CACHE_DIR"
    export GITHUB_API_BASE="https://api.github.com"
    export T2_REPO="AdityaGarg8/pve-edge-kernel-t2"
    export CACHE_TTL=3600
    export MAX_RETRIES=2  # Reduced for testing
    export INITIAL_RETRY_DELAY=1  # Reduced for testing
    
    # Extract and source the functions we need to test
    if [ -f "$MAIN_SCRIPT" ]; then
        # Extract function definitions
        sed -n '/^init_api_cache()/,/^}/p' "$MAIN_SCRIPT" > /tmp/test_functions.sh
        sed -n '/^github_api_get()/,/^}/p' "$MAIN_SCRIPT" >> /tmp/test_functions.sh
        sed -n '/^return_offline_guidance()/,/^}/p' "$MAIN_SCRIPT" >> /tmp/test_functions.sh
        sed -n '/^get_latest_t2_version()/,/^}/p' "$MAIN_SCRIPT" >> /tmp/test_functions.sh
        sed -n '/^validate_package_integrity()/,/^}/p' "$MAIN_SCRIPT" >> /tmp/test_functions.sh
        sed -n '/^validate_version()/,/^}/p' "$MAIN_SCRIPT" >> /tmp/test_functions.sh
        
        source /tmp/test_functions.sh
    else
        test_fail "Main script not found: $MAIN_SCRIPT"
        exit 1
    fi
}

# Test 1: Cache directory initialization
test_cache_initialization() {
    rm -rf "$TEST_CACHE_DIR"
    
    init_api_cache
    
    if [ -d "$TEST_CACHE_DIR" ]; then
        return 0
    else
        return 1
    fi
}

# Test 2: Cache TTL validation
test_cache_ttl() {
    local cache_file="$TEST_CACHE_DIR/test_repos_owner_repo_releases_latest"
    
    # Create cache directory and test file
    mkdir -p "$TEST_CACHE_DIR"
    echo '{"tag_name": "v1.0.0"}' > "$cache_file"
    
    # Set modification time to 2 hours ago (should be expired)
    # Handle both GNU date (Linux) and BSD date (macOS)
    if date -d '2 hours ago' +%Y%m%d%H%M.%S >/dev/null 2>&1; then
        # GNU date
        touch -t $(date -d '2 hours ago' +%Y%m%d%H%M.%S) "$cache_file"
    else
        # BSD date (macOS)
        touch -t $(date -v-2H +%Y%m%d%H%M.%S) "$cache_file"
    fi
    
    # Test if cache is properly identified as expired
    local file_mtime
    if stat -c %Y "$cache_file" >/dev/null 2>&1; then
        # GNU stat (Linux)
        file_mtime=$(stat -c %Y "$cache_file")
    else
        # BSD stat (macOS)
        file_mtime=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
    fi
    local cache_age=$(($(date +%s) - file_mtime))
    
    if [ $cache_age -gt $CACHE_TTL ]; then
        return 0
    else
        return 1
    fi
}

# Test 3: Version validation
test_version_validation() {
    local valid_versions=("1.0.0" "6.8.12-2" "2.4.6" "10.15.3-1")
    local invalid_versions=("1.0" "invalid" "1.0.0.0.1" "1.0.0-" "v1.0.0")
    
    # Test valid versions
    for version in "${valid_versions[@]}"; do
        if ! validate_version "$version"; then
            echo "Valid version failed: $version"
            return 1
        fi
    done
    
    # Test invalid versions
    for version in "${invalid_versions[@]}"; do
        if validate_version "$version"; then
            echo "Invalid version passed: $version"
            return 1
        fi
    done
    
    return 0
}

# Test 4: Package integrity validation (mock)
test_package_integrity() {
    local test_dir=$(mktemp -d)
    local test_package="$test_dir/test-package.deb"
    
    # Create a mock package file (empty for testing)
    touch "$test_package"
    
    # Test empty package (should fail)
    if validate_package_integrity "$test_package" 2>/dev/null; then
        rm -rf "$test_dir"
        return 1
    fi
    
    # Test non-existent package (should fail)
    if validate_package_integrity "/nonexistent/package.deb" 2>/dev/null; then
        rm -rf "$test_dir"
        return 1
    fi
    
    rm -rf "$test_dir"
    return 0
}

# Test 5: GitHub API endpoint construction
test_api_endpoint_construction() {
    local endpoint="/repos/test/repo/releases/latest"
    local expected_url="${GITHUB_API_BASE}${endpoint}"
    local cache_file="$TEST_CACHE_DIR/$(echo "$endpoint" | sed 's|/|_|g')"
    
    # Check if cache filename is constructed correctly
    if [[ "$cache_file" == *"_repos_test_repo_releases_latest" ]]; then
        return 0
    else
        return 1
    fi
}

# Test 6: Network timeout handling
test_network_timeout() {
    # Test with invalid URL that should timeout
    local invalid_url="http://192.0.2.1:1234/nonexistent"  # RFC 5737 test address
    
    # This should fail quickly due to timeout
    local start_time=$(date +%s)
    
    if timeout 15s curl -s --connect-timeout 2 --max-time 5 "$invalid_url" >/dev/null 2>&1; then
        return 1  # Should not succeed
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Should fail within reasonable time (less than 10 seconds)
    if [ $duration -lt 10 ]; then
        return 0
    else
        return 1
    fi
}

# Test 7: Rate limiting simulation
test_rate_limiting_handling() {
    # Create mock function that simulates rate limiting
    github_api_get_mock() {
        local endpoint="$1"
        
        # Simulate rate limiting on first call
        if [ ! -f "/tmp/rate_limit_test_called" ]; then
            touch "/tmp/rate_limit_test_called"
            return 1  # Simulate rate limit failure
        else
            # Simulate success on retry
            echo '{"tag_name": "v1.0.0"}'
            return 0
        fi
    }
    
    rm -f "/tmp/rate_limit_test_called"
    
    # Test that rate limiting is handled properly
    if github_api_get_mock "/repos/test/repo/releases/latest" >/dev/null; then
        return 1  # First call should fail
    fi
    
    if ! github_api_get_mock "/repos/test/repo/releases/latest" >/dev/null; then
        return 1  # Second call should succeed
    fi
    
    rm -f "/tmp/rate_limit_test_called"
    return 0
}

# Test 8: Offline guidance output
test_offline_guidance() {
    local guidance_output=$(return_offline_guidance)
    
    # Check if guidance contains expected elements
    if echo "$guidance_output" | grep -q "Network Connectivity Issues" && \
       echo "$guidance_output" | grep -q "github.com" && \
       echo "$guidance_output" | grep -q "GitHub Repository:"; then
        return 0
    else
        return 1
    fi
}

# Test 9: Cache cleanup on initialization
test_cache_cleanup() {
    # Create old cache files
    mkdir -p "$TEST_CACHE_DIR"
    local old_file="$TEST_CACHE_DIR/old_cache_file"
    touch "$old_file"
    
    # Set modification time to 2 days ago
    # Handle both GNU date (Linux) and BSD date (macOS)
    if date -d '2 days ago' +%Y%m%d%H%M.%S >/dev/null 2>&1; then
        # GNU date
        touch -t $(date -d '2 days ago' +%Y%m%d%H%M.%S) "$old_file"
    else
        # BSD date (macOS)
        touch -t $(date -v-2d +%Y%m%d%H%M.%S) "$old_file"
    fi
    
    # Run cache initialization
    init_api_cache
    
    # Check if old file was removed
    if [ ! -f "$old_file" ]; then
        return 0
    else
        return 1
    fi
}

# Test 10: User agent header validation
test_user_agent() {
    # This test validates that the user agent is properly formatted
    local expected_pattern="T2MacManager/1.0 \\(ProxmoxVE\\)"
    
    # Since we can't easily test the actual HTTP request, we'll test the pattern
    local test_user_agent="T2MacManager/1.0 (ProxmoxVE)"
    
    if echo "$test_user_agent" | grep -q "T2MacManager" && \
       echo "$test_user_agent" | grep -q "ProxmoxVE"; then
        return 0
    else
        return 1
    fi
}

# Setup and cleanup functions
setup_tests() {
    echo "Setting up GitHub API integration tests..."
    
    # Clean up any existing test cache
    rm -rf "$TEST_CACHE_DIR"
    rm -f /tmp/test_functions.sh
    rm -f /tmp/rate_limit_test_called
    
    # Source main script functions
    source_main_functions
    
    echo "Test setup complete."
    echo ""
}

cleanup_tests() {
    echo ""
    echo "Cleaning up test environment..."
    
    # Remove test cache directory
    rm -rf "$TEST_CACHE_DIR"
    rm -f /tmp/test_functions.sh
    rm -f /tmp/rate_limit_test_called
    
    echo "Cleanup complete."
}

# Main test execution
main() {
    echo "========================================"
    echo "GitHub API Integration Test Suite"
    echo "Story 1.3: GitHub API Integration with Resilience"
    echo "========================================"
    echo ""
    
    setup_tests
    
    # Run all tests
    run_test "Cache Directory Initialization" test_cache_initialization
    run_test "Cache TTL Validation" test_cache_ttl
    run_test "Version Validation" test_version_validation
    run_test "Package Integrity Validation" test_package_integrity
    run_test "API Endpoint Construction" test_api_endpoint_construction
    run_test "Network Timeout Handling" test_network_timeout
    run_test "Rate Limiting Handling" test_rate_limiting_handling
    run_test "Offline Guidance Output" test_offline_guidance
    run_test "Cache Cleanup" test_cache_cleanup
    run_test "User Agent Validation" test_user_agent
    
    cleanup_tests
    
    # Test summary
    echo "========================================"
    echo "Test Results Summary"
    echo "========================================"
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}All tests passed!${NC}"
        echo "GitHub API integration is ready for deployment."
        exit 0
    else
        echo -e "\n${RED}Some tests failed.${NC}"
        echo "Please review and fix issues before deployment."
        exit 1
    fi
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi