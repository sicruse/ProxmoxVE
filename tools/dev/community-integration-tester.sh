#!/bin/bash
# community-integration-tester.sh

# Community Scripts Integration Testing Framework

# Source community functions safely
source_community_functions() {
    local repo_path="${1:-$HOME/proxmoxve-community}"
    
    if [[ ! -d "$repo_path" ]]; then
        echo "❌ Community repository not found at: $repo_path"
        return 1
    fi
    
    # Source core functions
    if [[ -f "$repo_path/misc/core.func" ]]; then
        source "$repo_path/misc/core.func"
        echo "✅ Community core functions loaded"
    else
        echo "❌ core.func not found"
        return 1
    fi
    
    # Source additional function libraries
    for func_file in "$repo_path/misc"/*.func; do
        if [[ -f "$func_file" && "$func_file" != "$repo_path/misc/core.func" ]]; then
            source "$func_file"
            echo "✅ Loaded $(basename "$func_file")"
        fi
    done
}

# Test community messaging patterns
test_community_messaging() {
    echo "=== Testing Community Messaging Patterns ==="
    
    # Test msg_info function
    if command -v msg_info >/dev/null 2>&1; then
        msg_info "Testing info message display"
        echo "✅ msg_info function available"
    else
        echo "❌ msg_info function not available"
    fi
    
    # Test msg_ok function
    if command -v msg_ok >/dev/null 2>&1; then
        msg_ok "Testing success message display"
        echo "✅ msg_ok function available"
    else
        echo "❌ msg_ok function not available"
    fi
    
    # Test msg_error function
    if command -v msg_error >/dev/null 2>&1; then
        msg_error "Testing error message display"
        echo "✅ msg_error function available"
    else
        echo "❌ msg_error function not available"
    fi
}

# Test community header integration
test_community_headers() {
    echo "=== Testing Community Header Integration ==="
    
    local repo_path="${1:-$HOME/proxmoxve-community}"
    local headers_dir="$repo_path/ct/headers"
    
    if [[ -d "$headers_dir" ]]; then
        echo "✅ Community headers directory found"
        
        # Count available headers
        header_count=$(ls -1 "$headers_dir" | wc -l)
        echo "📊 Available headers: $header_count"
        
        # Test header display (using existing header as template)
        if [[ -f "$headers_dir/docker" ]]; then
            echo "✅ Header template available for reference"
        else
            echo "⚠️ No header template found for reference"
        fi
    else
        echo "❌ Community headers directory not found"
    fi
}

# Test community build tools
test_community_build_tools() {
    echo "=== Testing Community Build Tools ==="
    
    local repo_path="${1:-$HOME/proxmoxve-community}"
    
    # Test build function availability
    if [[ -f "$repo_path/misc/build.func" ]]; then
        source "$repo_path/misc/build.func"
        echo "✅ Build functions available"
    else
        echo "❌ Build functions not found"
    fi
    
    # Test API function availability
    if [[ -f "$repo_path/misc/api.func" ]]; then
        source "$repo_path/misc/api.func"
        echo "✅ API functions available"
    else
        echo "❌ API functions not found"
    fi
    
    # Test tools function availability
    if [[ -f "$repo_path/misc/tools.func" ]]; then
        source "$repo_path/misc/tools.func"
        echo "✅ Tools functions available"
    else
        echo "❌ Tools functions not found"
    fi
}

# Test local community patterns without affecting production
test_local_community_patterns() {
    echo "=== Testing Local Community Patterns ==="
    
    # Create isolated testing directory
    mkdir -p ~/.t2mac-dev/testing/community-patterns
    cd ~/.t2mac-dev/testing/community-patterns
    
    # Copy community functions for local testing
    local repo_path="${1:-$HOME/proxmoxve-community}"
    cp "$repo_path/misc"/*.func ./
    
    # Test function loading in isolation
    source ./core.func
    load_functions
    
    if command -v msg_info >/dev/null 2>&1; then
        msg_info "Local community pattern testing successful"
        echo "✅ Local community patterns functional"
    else
        echo "❌ Local community patterns failed to load"
    fi
    
    # Return to original directory
    cd - >/dev/null
}

# Comprehensive community integration test
run_full_community_test() {
    local repo_path="${1:-$HOME/proxmoxve-community}"
    
    echo "=== Full Community Integration Test ==="
    
    # Test 1: Source community functions
    source_community_functions "$repo_path"
    
    # Test 2: Test messaging patterns
    test_community_messaging
    
    # Test 3: Test header integration
    test_community_headers "$repo_path"
    
    # Test 4: Test build tools
    test_community_build_tools "$repo_path"
    
    # Test 5: Test local patterns
    test_local_community_patterns "$repo_path"
    
    echo "=== Community Integration Test Complete ==="
}

# Usage information
show_usage() {
    echo "Community Integration Tester Usage:"
    echo "  source_community_functions [repo_path]  - Load community functions"
    echo "  test_community_messaging                 - Test msg_* functions"
    echo "  test_community_headers [repo_path]       - Test header system"
    echo "  test_community_build_tools [repo_path]   - Test build tools"
    echo "  test_local_community_patterns [repo_path] - Test local patterns"
    echo "  run_full_community_test [repo_path]      - Run all tests"
    echo ""
    echo "Default repo_path: \$HOME/proxmoxve-community"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "test-messaging")
            source_community_functions "$2"
            test_community_messaging
            ;;
        "test-headers")
            test_community_headers "$2"
            ;;
        "test-build")
            test_community_build_tools "$2"
            ;;
        "test-local")
            test_local_community_patterns "$2"
            ;;
        "full-test")
            run_full_community_test "$2"
            ;;
        "help"|"--help"|"-h"|"")
            show_usage
            ;;
        *)
            echo "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
fi