#!/bin/bash
# =============================================================================
# OpenCode Config Generator
# =============================================================================
# Generates auth.json and opencode.json from .env file
# =============================================================================

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
OPENCODE_DIR="${SCRIPT_DIR}/.opencode"

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}✓ OpenCode Config Generator${NC}"
echo ""

# -----------------------------------------------------------------------------
# Check .env
# -----------------------------------------------------------------------------
if [[ ! -f "${ENV_FILE}" ]]; then
    echo -e "${RED}✗ ERROR: .env file not found${NC}"
    echo -e "${YELLOW}  Please copy .env.example to .env and configure${NC}"
    exit 1
fi

source "${ENV_FILE}"
echo -e "${GREEN}✓ Loaded .env file${NC}"

# -----------------------------------------------------------------------------
# Create .opencode Directory
# -----------------------------------------------------------------------------
mkdir -p "${OPENCODE_DIR}"
echo -e "${GREEN}✓ Created .opencode directory${NC}"

# -----------------------------------------------------------------------------
# Generate auth.json
# -----------------------------------------------------------------------------
if [[ ! -f "${OPENCODE_DIR}/auth.json" ]]; then
    echo -e "${YELLOW}⚠ No auth.json found, generating...${NC}"
    
    PROVIDER_NAME="${PROVIDER_NAME:-gwdg}"
    API_KEY="${OPENAI_API_KEY:-${OPENCODE_API_KEY}}"
    
    if [[ -z "${API_KEY}" ]]; then
        echo -e "${RED}✗ ERROR: No API key found in .env${NC}"
        exit 1
    fi
    
    cat > "${OPENCODE_DIR}/auth.json" << EOF
{
  "${PROVIDER_NAME}": {
    "type": "api",
    "key": "${API_KEY}"
  }
}
EOF
    echo -e "${GREEN}✓ Created auth.json at .opencode/auth.json${NC}"
else
    echo -e "${GREEN}✓ auth.json already exists${NC}"
fi

# -----------------------------------------------------------------------------
# Generate opencode.json
# -----------------------------------------------------------------------------
if [[ ! -f "${OPENCODE_DIR}/opencode.json" ]]; then
    echo -e "${YELLOW}⚠ No opencode.json found, generating...${NC}"
    
    BASE_URL="${OPENAI_BASE_URL:-https://chat-ai.academiccloud.de/v1}"
    PROVIDER_NAME="${PROVIDER_NAME:-gwdg}"
    API_KEY="${OPENAI_API_KEY:-${OPENCODE_API_KEY}}"
    
    echo -e "${YELLOW}🔍 Fetching models from ${BASE_URL}/models...${NC}"
    
    MODELS_JSON=""
    if [[ -n "${API_KEY}" ]]; then
        MODELS_JSON=$(curl -s -X GET "${BASE_URL}/models" \
            -H "Authorization: Bearer ${API_KEY}" \
            -H "Content-Type: application/json" 2>/dev/null || true)
    fi
    
    if [[ -z "${MODELS_JSON}" ]]; then
        echo -e "${YELLOW}⚠ Could not fetch models, using default${NC}"
        AVAILABLE_MODELS='["chat-ai-academiccloud-de/qwen3.5-122b-a10b"]'
    else
        AVAILABLE_MODELS=$(echo "${MODELS_JSON}" | jq -c '[.data[].id]' 2>/dev/null || echo '["chat-ai-academiccloud-de/qwen3.5-122b-a10b"]')
    fi
    
    cat > "${OPENCODE_DIR}/opencode.json" << EOF
{
  "provider": {
    "${PROVIDER_NAME}": {
      "type": "openai",
      "options": {
        "baseURL": "${BASE_URL}",
        "apiKey": "${API_KEY}"
      }
    }
  },
  "model": "${MODEL:-chat-ai-academiccloud-de/qwen3.5-122b-a10b}",
  "share": "disabled",
  "small_model": "${SMALL_MODEL:-${MODEL:-chat-ai-academiccloud-de/qwen3.5-122b-a10b}}",
  "available_models": ${AVAILABLE_MODELS}
}
EOF
    echo -e "${GREEN}✓ Created opencode.json at .opencode/opencode.json${NC}"
else
    echo -e "${GREEN}✓ opencode.json already exists${NC}"
fi

echo ""
echo -e "${GREEN}✓ OpenCode config generation complete${NC}"
