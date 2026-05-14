#!/bin/bash
# Test suite for Advanced Coding Agent scripts
# Run from repository root: ./tests/test_scripts.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
TESTS_DIR="${SCRIPT_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
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

# Change to repo directory
cd "${REPO_DIR}"

section "Script Syntax Tests"

# Test bash syntax for all scripts
info "Testing build-opencode.sh syntax..."
if bash -n "${REPO_DIR}/build-opencode.sh" 2>/dev/null; then
    pass "build-opencode.sh syntax valid"
else
    fail "build-opencode.sh syntax invalid"
fi

info "Testing build-openclaude.sh syntax..."
if bash -n "${REPO_DIR}/build-openclaude.sh" 2>/dev/null; then
    pass "build-openclaude.sh syntax valid"
else
    fail "build-openclaude.sh syntax invalid"
fi

info "Testing start-opencode.sh syntax..."
if bash -n "${REPO_DIR}/start-opencode.sh" 2>/dev/null; then
    pass "start-opencode.sh syntax valid"
else
    fail "start-opencode.sh syntax invalid"
fi

info "Testing start-openclaude.sh syntax..."
if bash -n "${REPO_DIR}/start-openclaude.sh" 2>/dev/null; then
    pass "start-openclaude.sh syntax valid"
else
    fail "start-openclaude.sh syntax invalid"
fi

section "File Existence Tests"

info "Checking Dockerfile.opencode exists..."
if [[ -f "${REPO_DIR}/Dockerfile.opencode" ]]; then
    pass "Dockerfile.opencode exists"
else
    fail "Dockerfile.opencode missing"
fi

info "Checking Dockerfile.openclaude exists..."
if [[ -f "${REPO_DIR}/Dockerfile.openclaude" ]]; then
    pass "Dockerfile.openclaude exists"
else
    fail "Dockerfile.openclaude missing"
fi

info "Checking agents.json exists..."
if [[ -f "${REPO_DIR}/agents.json" ]]; then
    pass "agents.json exists"
else
    fail "agents.json missing"
fi

info "Checking tools.md exists..."
if [[ -f "${REPO_DIR}/tools.md" ]]; then
    pass "tools.md exists"
else
    fail "tools.md missing"
fi

info "Checking .env.example exists..."
if [[ -f "${REPO_DIR}/.env.example" ]]; then
    pass ".env.example exists"
else
    fail ".env.example missing"
fi

section "Template Tests"

info "Checking templates directory exists..."
if [[ -d "${REPO_DIR}/templates" ]]; then
    pass "templates directory exists"
else
    fail "templates directory missing"
fi

info "Checking AGENTS.md template exists..."
if [[ -f "${REPO_DIR}/templates/AGENTS.md" ]]; then
    pass "AGENTS.md template exists"
else
    fail "AGENTS.md template missing"
fi

info "Checking AGENTS.md-python template exists..."
if [[ -f "${REPO_DIR}/templates/AGENTS.md-python" ]]; then
    pass "AGENTS.md-python template exists"
else
    fail "AGENTS.md-python template missing"
fi

info "Checking Python template has uv commands..."
if grep -q "uv add" "${REPO_DIR}/templates/AGENTS.md-python" 2>/dev/null; then
    pass "Python template includes uv commands"
else
    fail "Python template missing uv commands"
fi

info "Checking Python template has ruff..."
if grep -q "ruff" "${REPO_DIR}/templates/AGENTS.md-python" 2>/dev/null; then
    pass "Python template includes ruff"
else
    fail "Python template missing ruff"
fi

section "Documentation Tests"

info "Checking README.md exists..."
if [[ -f "${REPO_DIR}/README.md" ]]; then
    pass "README.md exists"
else
    fail "README.md missing"
fi

info "Checking docs directory exists..."
if [[ -d "${REPO_DIR}/docs" ]]; then
    pass "docs directory exists"
else
    fail "docs directory missing"
fi

info "Checking CONFIGURATION.md exists..."
if [[ -f "${REPO_DIR}/docs/CONFIGURATION.md" ]]; then
    pass "CONFIGURATION.md exists"
else
    fail "CONFIGURATION.md missing"
fi

info "Checking SCRIPTS.md exists..."
if [[ -f "${REPO_DIR}/docs/SCRIPTS.md" ]]; then
    pass "SCRIPTS.md exists"
else
    fail "SCRIPTS.md missing"
fi

section "GitLab CI/CD Tests"

info "Checking .gitlab-ci.yml exists..."
if [[ -f "${REPO_DIR}/.gitlab-ci.yml" ]]; then
    pass ".gitlab-ci.yml exists"
else
    fail ".gitlab-ci.yml missing"
fi

info "Validating .gitlab-ci.yml YAML syntax..."
if python3 -c "import yaml; yaml.safe_load(open('${REPO_DIR}/.gitlab-ci.yml'))" 2>/dev/null; then
    pass ".gitlab-ci.yml YAML syntax valid"
else
    fail ".gitlab-ci.yml YAML syntax invalid"
fi

info "Checking .gitlab-ci.yml has pages job..."
if grep -q "pages:" "${REPO_DIR}/.gitlab-ci.yml" 2>/dev/null; then
    pass ".gitlab-ci.yml has pages job"
else
    fail ".gitlab-ci.yml missing pages job"
fi

info "Checking .gitlab-ci.yml has manual triggers..."
if grep -q "when: manual" "${REPO_DIR}/.gitlab-ci.yml" 2>/dev/null; then
    pass ".gitlab-ci.yml has manual triggers"
else
    fail ".gitlab-ci.yml missing manual triggers"
fi

section "Python Generation Script Tests"

info "Checking scripts/generate-pages.py exists..."
if [[ -f "${REPO_DIR}/scripts/generate-pages.py" ]]; then
    pass "generate-pages.py exists"
else
    fail "generate-pages.py missing"
fi

info "Checking generate-pages.py is valid Python..."
if python3 -m py_compile "${REPO_DIR}/scripts/generate-pages.py" 2>/dev/null; then
    pass "generate-pages.py syntax valid"
else
    fail "generate-pages.py syntax invalid"
fi

section "Script Permissions Tests"

info "Checking build-opencode.sh is executable..."
if [[ -x "${REPO_DIR}/build-opencode.sh" ]]; then
    pass "build-opencode.sh is executable"
else
    fail "build-opencode.sh not executable"
fi

info "Checking build-openclaude.sh is executable..."
if [[ -x "${REPO_DIR}/build-openclaude.sh" ]]; then
    pass "build-openclaude.sh is executable"
else
    fail "build-openclaude.sh not executable"
fi

info "Checking start-opencode.sh is executable..."
if [[ -x "${REPO_DIR}/start-opencode.sh" ]]; then
    pass "start-opencode.sh is executable"
else
    fail "start-opencode.sh not executable"
fi

info "Checking start-openclaude.sh is executable..."
if [[ -x "${REPO_DIR}/start-openclaude.sh" ]]; then
    pass "start-openclaude.sh is executable"
else
    fail "start-openclaude.sh not executable"
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
