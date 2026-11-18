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

    DEFAULT_MODEL="qwen3.5-397b-a17b"

    MODELS_JSON=""
    if [[ -n "${API_KEY}" ]]; then
        MODELS_JSON=$(curl -s -X GET "${BASE_URL}/models" \
            -H "Authorization: Bearer ${API_KEY}" \
            -H "Content-Type: application/json" 2>/dev/null || true)
    fi

    # OpenCode expects provider.<name>.models as an object map keyed by model id
    MODELS_MAP=$(echo "${MODELS_JSON}" \
        | jq -c '[.data[].id] | map({key: ., value: {name: .}}) | from_entries' 2>/dev/null \
        || true)

    if [[ -z "${MODELS_MAP}" || "${MODELS_MAP}" == "null" || "${MODELS_MAP}" == "{}" ]]; then
        echo -e "${YELLOW}⚠ Could not fetch models, using default: ${DEFAULT_MODEL}${NC}"
        MODELS_MAP=$(jq -cn --arg m "${DEFAULT_MODEL}" '{($m): {name: $m}}')
    else
        echo -e "${GREEN}✓ Discovered $(echo "${MODELS_MAP}" | jq 'length') models${NC}"
    fi

    # model/small_model must be "provider/model"; tolerate either form in .env
    SELECTED_MODEL="${MODEL:-${DEFAULT_MODEL}}"
    SELECTED_SMALL_MODEL="${SMALL_MODEL:-${SELECTED_MODEL}}"
    SELECTED_MODEL="${PROVIDER_NAME}/${SELECTED_MODEL#${PROVIDER_NAME}/}"
    SELECTED_SMALL_MODEL="${PROVIDER_NAME}/${SELECTED_SMALL_MODEL#${PROVIDER_NAME}/}"

    jq -n \
        --arg provider "${PROVIDER_NAME}" \
        --arg baseURL "${BASE_URL}" \
        --arg apiKey "${API_KEY}" \
        --arg model "${SELECTED_MODEL}" \
        --arg smallModel "${SELECTED_SMALL_MODEL}" \
        --argjson models "${MODELS_MAP}" \
        '{
          "$schema": "https://opencode.ai/config.json",
          provider: {
            ($provider): {
              npm: "@ai-sdk/openai-compatible",
              name: $provider,
              options: { baseURL: $baseURL, apiKey: $apiKey },
              models: $models
            }
          },
          model: $model,
          small_model: $smallModel,
          share: "disabled"
        }' > "${OPENCODE_DIR}/opencode.json"

    echo -e "${GREEN}✓ Created opencode.json at .opencode/opencode.json${NC}"
else
    echo -e "${GREEN}✓ opencode.json already exists${NC}"
fi

echo ""
echo -e "${GREEN}✓ OpenCode config generation complete${NC}"
