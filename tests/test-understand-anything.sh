#!/bin/bash
# Test script to verify Understand-Anything skill integration

set -e

# Get script directory and change to it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "${SCRIPT_DIR}"

echo "Working directory: $(pwd)"
echo "Script directory: ${SCRIPT_DIR}"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Understanding-Anything Skill Test${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Test 1: Check skill directory exists
echo -e "${YELLOW}Test 1: Checking skill directory...${NC}"
if [[ -d "skills/addy-osmani/skills/understand-anything" ]]; then
    echo -e "${GREEN}✓ Skill directory exists${NC}"
else
    echo -e "${RED}✗ Skill directory not found${NC}"
    exit 1
fi

# Test 2: Check SKILL.md exists
echo -e "${YELLOW}Test 2: Checking SKILL.md file...${NC}"
if [[ -f "skills/addy-osmani/skills/understand-anything/SKILL.md" ]]; then
    echo -e "${GREEN}✓ SKILL.md exists ($(wc -l < skills/addy-osmani/skills/understand-anything/SKILL.md) lines)${NC}"
else
    echo -e "${RED}✗ SKILL.md not found${NC}"
    exit 1
fi

# Test 3: Check documentation files
echo -e "${YELLOW}Test 3: Checking documentation files...${NC}"
DOCS_OK=true

if [[ -f "docs/UNDERSTAND_ANYTHING_INTEGRATION.md" ]]; then
    echo -e "${GREEN}✓ UNDERSTAND_ANYTHING_INTEGRATION.md exists${NC}"
else
    echo -e "${RED}✗ UNDERSTAND_ANYTHING_INTEGRATION.md not found${NC}"
    DOCS_OK=false
fi

if [[ -f "docs/SKILLS.md" ]]; then
    echo -e "${GREEN}✓ SKILLS.md exists${NC}"
else
    echo -e "${RED}✗ SKILLS.md not found${NC}"
    DOCS_OK=false
fi

if [[ ! $DOCS_OK ]]; then
    exit 1
fi

# Test 4: Check README.md was updated
echo -e "${YELLOW}Test 4: Checking README.md updates...${NC}"
if grep -q "understand-anything" README.md; then
    echo -e "${GREEN}✓ README.md mentions understand-anything${NC}"
else
    echo -e "${RED}✗ README.md doesn't mention understand-anything${NC}"
    exit 1
fi

# Test 5: Check SKILLS.md was updated
echo -e "${YELLOW}Test 5: Checking SKILLS.md updates...${NC}"
if grep -q "/understand" docs/SKILLS.md; then
    echo -e "${GREEN}✓ SKILLS.md includes /understand command${NC}"
else
    echo -e "${RED}✗ SKILLS.md doesn't include /understand${NC}"
    exit 1
fi

# Test 6: Check Dockerfile includes skills
echo -e "${YELLOW}Test 6: Checking Dockerfile configuration...${NC}"
if grep -q "skills/addy-osmani" Dockerfile.opencode && grep -q "skills/matt-pocock" Dockerfile.opencode; then
    echo -e "${GREEN}✓ Dockerfile copies skills directories${NC}"
else
    echo -e "${RED}✗ Dockerfile doesn't copy skills${NC}"
    exit 1
fi

# Test 7: Verify skill structure
echo -e "${YELLOW}Test 7: Verifying skill structure...${NC}"
REQUIRED_FILES=(
    "skills/addy-osmani/skills/understand-anything/SKILL.md"
)

STRUCTURE_OK=true
for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}  ✓ $file${NC}"
    else
        echo -e "${RED}  ✗ $file not found${NC}"
        STRUCTURE_OK=false
    fi
done

if [[ ! $STRUCTURE_OK ]]; then
    exit 1
fi

# Test 8: Check installation instructions in SKILL.md
echo -e "${YELLOW}Test 8: Checking installation instructions...${NC}"
if grep -q "install.sh" skills/addy-osmani/skills/understand-anything/SKILL.md; then
    echo -e "${GREEN}✓ Installation instructions present${NC}"
else
    echo -e "${RED}✗ Installation instructions missing${NC}"
    exit 1
fi

# Test 9: Check command documentation
echo -e "${YELLOW}Test 9: Checking command documentation...${NC}"
COMMANDS=("/understand" "/understand-dashboard" "/understand-chat" "/understand-explain")

COMMANDS_OK=true
for cmd in "${COMMANDS[@]}"; do
    if grep -q "$cmd" skills/addy-osmani/skills/understand-anything/SKILL.md; then
        echo -e "${GREEN}  ✓ $cmd documented${NC}"
    else
        echo -e "${RED}  ✗ $cmd not documented${NC}"
        COMMANDS_OK=false
    fi
done

if [[ ! $COMMANDS_OK ]]; then
    exit 1
fi

# Test 10: Check integration guide
echo -e "${YELLOW}Test 10: Checking integration guide...${NC}"
if [[ -f "docs/UNDERSTAND_ANYTHING_INTEGRATION.md" ]]; then
    if grep -q "Option 1: Install Outside Container" docs/UNDERSTAND_ANYTHING_INTEGRATION.md; then
        echo -e "${GREEN}✓ Integration guide has installation options${NC}"
    else
        echo -e "${RED}✗ Integration guide incomplete${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Integration guide not found${NC}"
    exit 1
fi

# Summary
echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}  ✓ ALL TESTS PASSED!${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo -e "  • Skill directory: ${GREEN}✓${NC}"
echo -e "  • SKILL.md: ${GREEN}✓${NC} ($(wc -l < skills/addy-osmani/skills/understand-anything/SKILL.md) lines)"
echo -e "  • Documentation: ${GREEN}✓${NC}"
echo -e "  • README updates: ${GREEN}✓${NC}"
echo -e "  • Dockerfile config: ${GREEN}✓${NC}"
echo -e "  • Installation guide: ${GREEN}✓${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Start Docker (if not running)"
echo -e "  2. Build image: ${GREEN}./build-opencode.sh${NC}"
echo -e "  3. Start container: ${GREEN}./start-opencode.sh${NC}"
echo -e "  4. Install skill in container: ${GREEN}curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash${NC}"
echo -e "  5. Test: ${GREEN}/understand --help${NC}"
echo ""
