# Opencode Container Mount Test Pipeline

This test pipeline verifies that the opencode container can properly:
1. Mount host directories with write access
2. Create `.local` directories without permission errors
3. Run opencode without EACCES errors
4. Write files to mounted volumes that are accessible on the host

## Quick Test

```bash
cd /home/cloud/test-projects/opencode-test
./test-opencode-mount.sh
```

## Important: Running start-opencode.sh

The `start-opencode.sh` script now automatically fixes directory ownership, but **requires sudo**:

```bash
# Recommended: Run with sudo
sudo ./start-opencode.sh

# Or manually fix ownership first
sudo chown -R 999:999 /path/to/your/project
./start-opencode.sh
```

**Why sudo is needed:**
- Container's agent user = UID 999
- Your project directory likely owned by UID 1000 (your user)
- Rootless Docker cannot map UIDs between host and container
- Script uses `sudo chown` to fix this before starting container

## Test Results ✅

All tests **PASSED** on 2026-06-08:

- ✅ Container can create `.local` directory in mounted volume
- ✅ Opencode runs without permission errors (no EACCES)
- ✅ Container can write to mounted volume
- ✅ Host can read files written by container

## What It Tests

### Test 1: `.local` Directory Creation
- Creates a `.local` directory in the mounted project folder
- Verifies no EACCES permission errors
- Checks directory ownership (UID 999 - container agent user)

### Test 2: Opencode Initialization
- Runs opencode in the mounted project directory
- Verifies opencode starts without errors
- Checks for permission-related failures

### Test 3: Volume Write Access
- Creates a test file from inside the container
- Verifies the file exists on the host after container exits
- Confirms bidirectional read/write access

## Test Project Structure

```
/home/cloud/test-projects/opencode-test/
├── test-opencode-mount.sh    # Main test script
├── README.md                 # This file
└── dummy-project/            # Created by test script
    ├── README.md
    ├── test-file.txt
    ├── .local/               # Created by container
    ├── container-write-test.txt  # Created by container
    └── test-write.txt        # Created by container
```

## Important Notes

### UID/GID Matching
The container's `agent` user has UID/GID **999**. The test script:
1. Creates the test directory
2. Changes ownership to UID 999:999
3. Creates files with sudo to maintain correct ownership

This ensures the container's agent user can write to the mounted volume.

### Volume Mount Syntax
The test uses Docker's `-v` flag for volume mounting:
```bash
-v /host/path:/container/path
```

### Permission Handling
- Host directory must be owned by UID 999 for container writes
- Files created by container will have UID 999 ownership
- Use `sudo` to read/write files if running as different user

## Manual Testing

If you want to test manually:

```bash
# Build the image (if not already built)
cd /home/cloud/advanced-coding-agent
sudo docker build -f Dockerfile.opencode -t advanced-coding-agent-opencode:latest .

# Create test directory with correct ownership
mkdir -p /home/cloud/test-projects/opencode-test/dummy-project
sudo chown -R 999:999 /home/cloud/test-projects/opencode-test/dummy-project

# Run container with mounted volume
sudo docker run -it --rm \
  -v /home/cloud/test-projects/opencode-test/dummy-project:/home/agent/workspace/projects/dummy-project \
  advanced-coding-agent-opencode:latest \
  /bin/bash

# Inside container:
cd /home/agent/workspace/projects/dummy-project
mkdir -p .local
ls -la .local
opencode --help
echo "Test from container" > test.txt
exit

# Check on host:
sudo ls -la /home/cloud/test-projects/opencode-test/dummy-project/
sudo cat /home/cloud/test-projects/opencode-test/dummy-project/test.txt
```

## Expected Output

All tests should pass with output like:
```
✓ Test 1 PASSED: .local directory created successfully
✓ Test 2 PASSED: Opencode runs without permission errors
✓ Test 3 PASSED: Container successfully wrote to mounted volume

ALL TESTS PASSED! 🎉
```

## Troubleshooting

### EACCES Permission Errors
If you see `EACCES: permission denied` errors:
1. Check Dockerfile.opencode has the `.local` directory creation
2. Verify `chown -R agent:agent` is set for workspace and .local
3. Ensure Docker image was rebuilt after changes
4. Check host directory ownership matches container UID (999)

### Volume Mount Issues
If container can't write to mounted volume:
1. Check host directory permissions: `ls -la /home/cloud/test-projects/opencode-test/`
2. Ensure directory is owned by UID 999: `sudo chown -R 999:999 <directory>`
3. Verify Docker is running with proper permissions
4. Try running test with `sudo` if needed

### UID Mismatch
If files are created with wrong ownership:
- Container agent user = UID 999
- Host user should match or use sudo for access
- Set directory ownership before mounting: `sudo chown -R 999:999 <dir>`

## Integration with CI/CD

Add this test to your CI pipeline:

```yaml
test-opencode:
  stage: test
  script:
    - cd /home/cloud/advanced-coding-agent
    - sudo docker build -f Dockerfile.opencode -t advanced-coding-agent-opencode:latest .
    - cd /home/cloud/test-projects/opencode-test
    - ./test-opencode-mount.sh
```

## Related

- Main project: `/home/cloud/advanced-coding-agent/`
- Dockerfile: `Dockerfile.opencode`
- Build script: `build-opencode.sh`
- Start script: `start-opencode.sh`
- Fix commit: `1305334` - "fix: Add .local directory with proper ownership to prevent EACCES errors"

## Test History

| Date | Status | Notes |
|------|--------|-------|
| 2026-06-08 | ✅ PASS | All tests passed with UID 999 ownership |
