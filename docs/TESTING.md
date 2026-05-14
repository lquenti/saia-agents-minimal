# Testing Guide

Comprehensive testing for the Advanced Coding Agent repository.

---

## Overview

The repository includes an automated test suite that validates:

- ✅ Script syntax and permissions
- ✅ File existence and configuration
- ✅ Template completeness
- ✅ Documentation presence
- ✅ GitLab CI/CD configuration
- ✅ Python script validity
- ✅ Docker builds (optional)

**Total tests:** 28 script tests + 10 Docker tests

---

## Quick Start

### Run All Tests

```bash
./tests/run_tests.sh
```

### Run Specific Test Suite

```bash
# Script tests only
./tests/run_tests.sh scripts

# Docker tests only (requires Docker)
./tests/run_tests.sh docker
```

### Run Individual Test File

```bash
# Script tests (28 tests)
./tests/test_scripts.sh

# Docker tests (10 tests)
./tests/test_docker.sh
```

---

## Test Suites

### test_scripts.sh

**Purpose:** Validates scripts, files, templates, and configuration

**Tests:** 28 total

#### Script Syntax Tests (4)
- ✅ build-opencode.sh syntax
- ✅ build-openclaude.sh syntax
- ✅ start-opencode.sh syntax
- ✅ start-openclaude.sh syntax

#### File Existence Tests (5)
- ✅ Dockerfile.opencode
- ✅ Dockerfile.openclaude
- ✅ agents.json
- ✅ tools.md
- ✅ .env.example

#### Template Tests (5)
- ✅ templates/ directory
- ✅ AGENTS.md template
- ✅ AGENTS.md-python template
- ✅ Python template has uv commands
- ✅ Python template has ruff

#### Documentation Tests (4)
- ✅ README.md
- ✅ docs/ directory
- ✅ CONFIGURATION.md
- ✅ SCRIPTS.md

#### GitLab CI/CD Tests (4)
- ✅ .gitlab-ci.yml exists
- ✅ .gitlab-ci.yml YAML syntax
- ✅ .gitlab-ci.yml has pages job
- ✅ .gitlab-ci.yml has manual triggers

#### Python Generation Script Tests (2)
- ✅ scripts/generate-pages.py exists
- ✅ scripts/generate-pages.py syntax

#### Script Permissions Tests (4)
- ✅ build-opencode.sh executable
- ✅ build-openclaude.sh executable
- ✅ start-opencode.sh executable
- ✅ start-openclaude.sh executable

---

### test_docker.sh

**Purpose:** Validates Docker builds and container configuration

**Tests:** 10 total (requires Docker daemon)

#### Docker Environment Tests (2)
- ✅ Docker is installed
- ✅ Docker daemon is running

#### Docker Build Tests (4)
- ✅ Dockerfile.opencode syntax
- ✅ Dockerfile.openclaude syntax
- ✅ OpenCode image exists (if built)
- ✅ OpenClaude image exists (if built)

#### Container Configuration Tests (2)
- ✅ agents.json is valid JSON
- ✅ agents.json has required fields

---

### run_tests.sh

**Purpose:** Main test runner that orchestrates all test suites

**Features:**
- Runs all tests by default
- Supports selective test execution
- Color-coded output
- Summary with pass/fail counts
- Exit codes for CI/CD integration

---

## CI/CD Integration

### Automatic Test Execution

Tests run automatically in GitLab CI/CD:

```yaml
test:
  stage: test
  script:
    - chmod +x tests/*.sh
    - bash tests/test_scripts.sh
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
    - if: $CI_PIPELINE_SOURCE == 'web' && $MANUAL_TEST == 'true'
  allow_failure: false
```

### When Tests Run

| Trigger | Tests Run | Fails Pipeline |
|---------|-----------|----------------|
| Merge Request | ✅ Yes | ✅ Yes |
| Push to main | ❌ No | - |
| Manual trigger | ✅ Yes (if `$MANUAL_TEST=true`) | ✅ Yes |
| Scheduled | ❌ No | - |

### Manual Test Trigger

In GitLab UI:
1. Go to **CI/CD → Pipelines**
2. Click **Run pipeline**
3. Set variable: `MANUAL_TEST=true`
4. Click **Run pipeline**

---

## Test Output

### Success

```
═══════════════════════════════════════════════════════════
  Script Syntax Tests
═══════════════════════════════════════════════════════════
→ Testing build-opencode.sh syntax...
✓ build-opencode.sh syntax valid
...

═══════════════════════════════════════════════════════════
  TEST SUMMARY
═══════════════════════════════════════════════════════════

  Tests run:    28
  Tests passed: 28
  Tests failed: 0

✓ All tests passed!
```

### Failure

```
═══════════════════════════════════════════════════════════
  TEST SUMMARY
═══════════════════════════════════════════════════════════

  Tests run:    28
  Tests passed: 27
  Tests failed: 1

✗ 1 test(s) failed
```

**Exit code:** Non-zero (causes CI/CD failure)

---

## Adding New Tests

### Add to Existing Test Suite

Edit `tests/test_scripts.sh`:

```bash
section "New Test Section"

info "Testing new feature..."
if [[ condition ]]; then
    pass "Feature works"
else
    fail "Feature broken"
fi
```

### Create New Test File

```bash
#!/bin/bash
# tests/test_new_feature.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

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

# Your tests here
info "Testing new feature..."
if [[ condition ]]; then
    pass "Feature works"
else
    fail "Feature broken"
fi

# Summary
echo ""
echo "  Tests run:    ${TESTS_RUN}"
echo "  Tests passed: ${TESTS_PASSED}"
echo "  Tests failed: ${TESTS_FAILED}"

[[ ${TESTS_FAILED} -eq 0 ]] && exit 0 || exit 1
```

### Add to Test Runner

Edit `tests/run_tests.sh`:

```bash
case "${TEST_TYPE}" in
    new_feature)
        section "Running New Feature Tests..."
        bash "${SCRIPT_DIR}/test_new_feature.sh"
        ;;
    
    all|*)
        # ... existing tests ...
        
        # Add new test suite
        info "Running new feature tests..."
        if bash "${SCRIPT_DIR}/test_new_feature.sh"; then
            pass "New feature tests passed"
        else
            fail "New feature tests failed"
        fi
        ;;
esac
```

---

## Best Practices

### 1. Run Tests Before Committing

```bash
# Before git commit
./tests/run_tests.sh

# If tests fail, fix issues first
git add .
git commit -m "feat: ..."
```

### 2. Add Tests for New Features

When adding new scripts or files:

```bash
# Add file existence test
info "Checking new-feature.sh exists..."
if [[ -f "${REPO_DIR}/new-feature.sh" ]]; then
    pass "new-feature.sh exists"
else
    fail "new-feature.sh missing"
fi

# Add syntax test
info "Testing new-feature.sh syntax..."
if bash -n "${REPO_DIR}/new-feature.sh"; then
    pass "new-feature.sh syntax valid"
else
    fail "new-feature.sh syntax invalid"
fi
```

### 3. Keep Tests Fast

- Avoid long-running tests
- Docker tests can be skipped if Docker unavailable
- Use `set -e` to fail fast on errors

### 4. Use Meaningful Test Names

```bash
# Good
pass "build-opencode.sh syntax valid"

# Bad
pass "ok"
```

### 5. Test Edge Cases

```bash
# Test file exists
if [[ -f "${REPO_DIR}/file.txt" ]]; then
    pass "file.txt exists"
else
    fail "file.txt missing"
fi

# Test file is not empty
if [[ -s "${REPO_DIR}/file.txt" ]]; then
    pass "file.txt is not empty"
else
    fail "file.txt is empty"
fi

# Test file has content
if grep -q "expected content" "${REPO_DIR}/file.txt"; then
    pass "file.txt has expected content"
else
    fail "file.txt missing expected content"
fi
```

---

## Troubleshooting

### Tests Fail with "command not found"

**Problem:** Scripts not executable

**Solution:**
```bash
chmod +x tests/*.sh
```

### Docker Tests Fail

**Problem:** Docker not installed or not running

**Solution:**
```bash
# Check Docker
docker --version
docker info

# Start Docker daemon (if stopped)
sudo systemctl start docker
```

### YAML Syntax Errors

**Problem:** Invalid YAML in `.gitlab-ci.yml`

**Solution:**
```bash
# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml'))"

# Fix syntax errors and re-run tests
```

### Test Count Mismatch

**Problem:** Test summary shows different count than actual tests

**Solution:**
Ensure all test functions use `pass()` and `fail()` helpers consistently:

```bash
# Correct
pass "test passed"
fail "test failed"

# Incorrect (doesn't update counters)
echo "✓ test passed"
```

---

## Test Coverage Matrix

| Component | Script Tests | Docker Tests | CI/CD |
|-----------|--------------|--------------|-------|
| Build Scripts | ✅ | ✅ | ✅ |
| Start Scripts | ✅ | ✅ | ✅ |
| Dockerfiles | ❌ | ✅ | ❌ |
| Templates | ✅ | ❌ | ❌ |
| Documentation | ✅ | ❌ | ❌ |
| GitLab CI/CD | ✅ | ❌ | ✅ |
| Python Scripts | ✅ | ❌ | ❌ |
| Configuration | ❌ | ✅ | ❌ |

---

## Related Documentation

- [Scripts Guide](SCRIPTS.md) - Build/start script documentation
- [Configuration Guide](CONFIGURATION.md) - API keys and providers
- [Security Guide](SECURITY.md) - Container hardening
- [GitLab Pages Setup](ENABLE_GITLAB_PAGES.md) - CI/CD pipeline
- [Test Suite README](../tests/README.md) - Detailed test documentation

---

## Quick Reference

### Common Commands

```bash
# Run all tests
./tests/run_tests.sh

# Run script tests only
./tests/run_tests.sh scripts

# Run Docker tests only
./tests/run_tests.sh docker

# Check test script syntax
bash -n tests/test_scripts.sh

# Make scripts executable
chmod +x tests/*.sh

# View test source
cat tests/test_scripts.sh
```

### Test Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed |

### CI/CD Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `MANUAL_TEST` | Trigger manual test run | Not set |
| `CI_PIPELINE_SOURCE` | Pipeline trigger type | Auto |
| `CI_COMMIT_BRANCH` | Current branch | Auto |

---

**WAAAGH! Test everything, break nothing!** 🪓👊
