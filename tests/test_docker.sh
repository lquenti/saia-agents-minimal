#!/bin/bash
# Docker build tests for Advanced Coding Agent
# Requires Docker to be running
# Run from repository root: ./tests/test_docker.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_RUN=$((TESTS_RUN + 1))
}

info() {
    echo -e "${YELLOW}→${NC} $1"
}

section() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
}

cd "${REPO_DIR}"

section "Docker Environment Tests"

info "Checking Docker is installed..."
if command -v docker &>/dev/null; then
    pass "Docker is installed"
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    info "  Docker version: ${DOCKER_VERSION}"
else
    fail "Docker is not installed"
    echo "  Skipping Docker build tests"
    exit 0
fi

info "Checking Docker daemon is running..."
if docker info &>/dev/null; then
    pass "Docker daemon is running"
else
    fail "Docker daemon is not running"
    echo "  Skipping Docker build tests"
    exit 0
fi

section "Docker Build Tests (Quick)"

# Test that Dockerfiles are syntactically valid (don't actually build)
info "Checking Dockerfile.opencode syntax..."
if docker build -f "${REPO_DIR}/Dockerfile.opencode" --dry-run "${REPO_DIR}" 2>&1 | grep -q "ERROR\|error" 2>/dev/null; then
    fail "Dockerfile.opencode has syntax errors"
else
    pass "Dockerfile.opencode syntax valid"
fi

info "Checking Dockerfile.openclaude syntax..."
if docker build -f "${REPO_DIR}/Dockerfile.openclaude" --dry-run "${REPO_DIR}" 2>&1 | grep -q "ERROR\|error" 2>/dev/null; then
    fail "Dockerfile.openclaude has syntax errors"
else
    pass "Dockerfile.openclaude syntax valid"
fi

# Check if images already exist (from previous builds)
info "Checking if OpenCode image exists..."
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^advanced-coding-agent:latest$"; then
    pass "OpenCode image exists"
    IMAGE_ID=$(docker images --format '{{.ID}}' advanced-coding-agent:latest | head -1)
    info "  Image ID: ${IMAGE_ID}"
else
    info "  OpenCode image not built yet (run ./build-opencode.sh)"
fi

info "Checking if OpenClaude image exists..."
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^advanced-coding-agent:openclaude$"; then
    pass "OpenClaude image exists"
    IMAGE_ID=$(docker images --format '{{.ID}}' advanced-coding-agent:openclaude | head -1)
    info "  Image ID: ${IMAGE_ID}"
else
    info "  OpenClaude image not built yet (run ./build-openclaude.sh)"
fi

section "Container Configuration Tests"

info "Checking agents.json is valid JSON..."
if python3 -c "import json; json.load(open('${REPO_DIR}/agents.json'))" 2>/dev/null; then
    pass "agents.json is valid JSON"
else
    fail "agents.json is not valid JSON"
fi

info "Checking agents.json has required fields..."
if python3 -c "
import json
data = json.load(open('${REPO_DIR}/agents.json'))
assert 'agent' in data, 'Missing agent field'
assert 'skills' in data, 'Missing skills field'
assert 'security' in data, 'Missing security field'
" 2>/dev/null; then
    pass "agents.json has required fields"
else
    fail "agents.json missing required fields"
fi

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  TEST SUMMARY${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Tests run:    ${GREEN}${TESTS_RUN}${NC}"
echo -e "  Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "  Tests failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [[ ${TESTS_FAILED} -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ ${TESTS_FAILED} test(s) failed${NC}"
    exit 1
fi
