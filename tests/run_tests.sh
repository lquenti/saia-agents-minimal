#!/bin/bash
# Main test runner for Advanced Coding Agent
# Run from repository root: ./tests/run_tests.sh
# Or with specific test: ./tests/run_tests.sh scripts
# Or: ./tests/run_tests.sh docker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TOTAL_RUN=0
TOTAL_PASSED=0
TOTAL_FAILED=0

pass() {
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
    TOTAL_RUN=$((TOTAL_RUN + 1))
}

fail() {
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    TOTAL_RUN=$((TOTAL_RUN + 1))
}

info() {
    echo -e "${BLUE}→${NC} $1"
}

section() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
}

banner() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Advanced Coding Agent - Test Suite                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

cd "${REPO_DIR}"

banner

# Parse arguments
TEST_TYPE="${1:-all}"

case "${TEST_TYPE}" in
    scripts)
        section "Running Script Tests..."
        if [[ -x "${SCRIPT_DIR}/test_scripts.sh" ]]; then
            bash "${SCRIPT_DIR}/test_scripts.sh"
        else
            echo -e "${RED}✗ test_scripts.sh not found or not executable${NC}"
            exit 1
        fi
        ;;
    
    docker)
        section "Running Docker Tests..."
        if [[ -x "${SCRIPT_DIR}/test_docker.sh" ]]; then
            bash "${SCRIPT_DIR}/test_docker.sh"
        else
            echo -e "${RED}✗ test_docker.sh not found or not executable${NC}"
            exit 1
        fi
        ;;
    
    all|*)
        section "Running All Tests..."
        
        # Script tests (always run)
        info "Running script syntax and file tests..."
        if [[ -x "${SCRIPT_DIR}/test_scripts.sh" ]]; then
            if bash "${SCRIPT_DIR}/test_scripts.sh"; then
                pass "Script tests passed"
            else
                fail "Script tests failed"
            fi
        else
            fail "test_scripts.sh not found"
        fi
        
        # Docker tests (only if Docker is available)
        info "Running Docker tests..."
        if command -v docker &>/dev/null && docker info &>/dev/null; then
            if [[ -x "${SCRIPT_DIR}/test_docker.sh" ]]; then
                if bash "${SCRIPT_DIR}/test_docker.sh"; then
                    pass "Docker tests passed"
                else
                    fail "Docker tests failed"
                fi
            else
                fail "test_docker.sh not found"
            fi
        else
            info "  Docker not available, skipping Docker tests"
        fi
        ;;
esac

# Final summary
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                     FINAL SUMMARY                         ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Total tests:  ${GREEN}${TOTAL_RUN}${NC}"
echo -e "  Passed:       ${GREEN}${TOTAL_PASSED}${NC}"
echo -e "  Failed:       ${RED}${TOTAL_FAILED}${NC}"
echo ""

if [[ ${TOTAL_FAILED} -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ ${TOTAL_FAILED} test(s) failed${NC}"
    echo ""
    exit 1
fi
