# Test Suite

Automated tests for the Advanced Coding Agent repository.

## Quick Start

### Run All Tests

```bash
./tests/run_tests.sh
```

### Run Specific Test Suite

```bash
# Script tests only
./tests/run_tests.sh scripts

# Docker tests only
./tests/run_tests.sh docker
```

### Run Individual Test File

```bash
# Script tests
./tests/test_scripts.sh

# Docker tests (requires Docker)
./tests/test_docker.sh
```

---

## Test Suites

### test_scripts.sh

Comprehensive tests for scripts, files, and configuration.

**Tests included (28 total):**

#### Script Syntax Tests
- ✅ build-opencode.sh syntax
- ✅ build-openclaude.sh syntax
- ✅ start-opencode.sh syntax
- ✅ start-openclaude.sh syntax

#### File Existence Tests
- ✅ Dockerfile.opencode
- ✅ Dockerfile.openclaude
- ✅ agents.json
- ✅ tools.md
- ✅ .env.example

#### Template Tests
- ✅ templates/ directory
- ✅ AGENTS.md template
- ✅ AGENTS.md-python template
- ✅ Python template has uv commands
- ✅ Python template has ruff

#### Documentation Tests
- ✅ README.md
- ✅ docs/ directory
- ✅ CONFIGURATION.md
- ✅ SCRIPTS.md

#### GitLab CI/CD Tests
- ✅ .gitlab-ci.yml exists
- ✅ .gitlab-ci.yml YAML syntax
- ✅ .gitlab-ci.yml has pages job
- ✅ .gitlab-ci.yml has manual triggers

#### Python Generation Script Tests
- ✅ scripts/generate-pages.py exists
- ✅ scripts/generate-pages.py syntax

#### Script Permissions Tests
- ✅ build-opencode.sh executable
- ✅ build-openclaude.sh executable
- ✅ start-opencode.sh executable
- ✅ start-openclaude.sh executable

---

### test_docker.sh

Docker-related tests (requires Docker daemon).

**Tests included:**

#### Docker Environment Tests
- ✅ Docker is installed
- ✅ Docker daemon is running

#### Docker Build Tests
- ✅ Dockerfile.opencode syntax
- ✅ Dockerfile.openclaude syntax
- ✅ OpenCode image exists (if built)
- ✅ OpenClaude image exists (if built)

#### Container Configuration Tests
- ✅ agents.json is valid JSON
- ✅ agents.json has required fields

---

### run_tests.sh

Main test runner that orchestrates all test suites.

**Features:**
- Runs all tests by default
- Supports selective test execution
- Color-coded output
- Summary with pass/fail counts
- Exit codes for CI/CD integration

**Usage:**
```bash
./tests/run_tests.sh        # Run all tests
./tests/run_tests.sh scripts  # Script tests only
./tests/run_tests.sh docker   # Docker tests only
```

---

## CI/CD Integration

Tests are automatically run in GitLab CI/CD:

### Merge Requests
- `test` stage runs automatically
- Fails pipeline if tests fail

### Manual Triggers
```bash
# In GitLab UI: CI/CD → Pipelines → Run pipeline
# Set variable: MANUAL_TEST=true
```

### .gitlab-ci.yml
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

---

## Test Output

### Success

```
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

---

## Adding New Tests

### Add to test_scripts.sh

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

# Your tests here
# Use pass() and fail() helpers
```

Add to run_tests.sh:
```bash
case "${TEST_TYPE}" in
    new_feature)
        bash "${SCRIPT_DIR}/test_new_feature.sh"
        ;;
```

---

## Troubleshooting

### Tests Fail with "command not found"

Ensure scripts are executable:
```bash
chmod +x tests/*.sh
```

### Docker Tests Fail

Check if Docker is running:
```bash
docker info
```

### YAML Syntax Errors

Validate YAML:
```bash
python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml'))"
```

---

## Best Practices

1. **Run tests before committing**
   ```bash
   ./tests/run_tests.sh
   ```

2. **Add tests for new features**
   - Script tests for new scripts
   - File existence tests for new files
   - Configuration tests for new configs

3. **Keep tests fast**
   - Avoid long-running tests
   - Docker tests can be skipped if Docker unavailable

4. **Use meaningful test names**
   - Clear pass/fail messages
   - Helpful error information

---

**Related:**
- [Scripts Documentation](../docs/SCRIPTS.md)
- [Configuration Guide](../docs/CONFIGURATION.md)
- [GitLab Pages Setup](../docs/ENABLE_GITLAB_PAGES.md)
