#!/bin/bash
# Realistic Opencode Mount Test
# Tests volume mounting WITHOUT pre-chowning (real-world scenario)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
TEST_PROJECT_DIR="/home/cloud/test-projects/realistic-opencode-test"
IMAGE_NAME="advanced-coding-agent-opencode:latest"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Realistic Opencode Mount Test${NC}"
echo -e "${BLUE}  (No pre-chown - real-world scenario)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Create test directory (owned by current user - UID 1000)
echo -e "${YELLOW}[1/4] Creating test project (owned by UID $(id -u))...${NC}"
rm -rf "${TEST_PROJECT_DIR}"
mkdir -p "${TEST_PROJECT_DIR}"

echo "# Realistic Test Project" > "${TEST_PROJECT_DIR}/README.md"
echo "Test file" > "${TEST_PROJECT_DIR}/test.txt"

echo -e "${GREEN}✓ Created: ${TEST_PROJECT_DIR}${NC}"
echo -e "${BLUE}  Ownership: $(ls -ld ${TEST_PROJECT_DIR} | awk '{print $3":"$4}')${NC}"

# Check if image exists
echo -e "${YELLOW}[2/4] Checking Docker image...${NC}"
if ! sudo docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
    echo -e "${RED}✗ Image not found: ${IMAGE_NAME}${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Image exists${NC}"

# Test: Try to create .local WITHOUT pre-chown
echo -e "${YELLOW}[3/4] Testing .local creation (expected to FAIL without proper permissions)...${NC}"

if sudo docker run --rm -v "${TEST_PROJECT_DIR}:/home/agent/workspace/projects/test" "${IMAGE_NAME}" /bin/bash -c "cd /home/agent/workspace/projects/test && mkdir -p .local && echo 'SUCCESS'" 2>&1; then
    echo -e "${GREEN}✓ .local created successfully (directory permissions allow it)${NC}"
    echo -e "${YELLOW}  Note: This means host directory permissions are permissive${NC}"
else
    echo -e "${RED}✗ .local creation failed (expected if host dir is owned by different UID)${NC}"
    echo -e "${YELLOW}  This is NORMAL if host directory is owned by UID 1000${NC}"
    echo -e "${YELLOW}  Solution: Either:${NC}"
    echo -e "${YELLOW}    1. chown directory to UID 999 before mounting${NC}"
    echo -e "${YELLOW}    2. Use Docker user namespaces${NC}"
    echo -e "${YELLOW}    3. Mount with :ro (read-only) if write not needed${NC}"
fi

# Test: Show what permissions ARE needed
echo ""
echo -e "${YELLOW}[4/4] Demonstrating correct setup...${NC}"
echo -e "${BLUE}  Setting ownership to UID 999 (container agent user)...${NC}"
sudo chown -R 999:999 "${TEST_PROJECT_DIR}"

if sudo docker run --rm -v "${TEST_PROJECT_DIR}:/home/agent/workspace/projects/test" "${IMAGE_NAME}" /bin/bash -c "cd /home/agent/workspace/projects/test && mkdir -p .local && echo 'Written by container' > container-test.txt && echo 'SUCCESS'"; then
    echo -e "${GREEN}✓ With correct ownership, container can write!${NC}"
    echo -e "${BLUE}  Files on host:${NC}"
    sudo ls -la "${TEST_PROJECT_DIR}/"
else
    echo -e "${RED}✗ Still failing - check Docker configuration${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}  KEY FINDING:${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Container's agent user = UID 999${NC}"
echo -e "${YELLOW}Host directory MUST be owned by UID 999 for writes${NC}"
echo -e "${YELLOW}Or use Docker user namespace mapping${NC}"
echo ""
echo -e "${GREEN}Recommendation:${NC}"
echo -e "  Add to your container start script:"
echo -e "    sudo chown -R 999:999 /path/to/project"
echo -e "  BEFORE running docker run -v ..."
echo ""
echo -e "${GREEN}WAAAGH! Test complete!${NC} 👊🪓"
