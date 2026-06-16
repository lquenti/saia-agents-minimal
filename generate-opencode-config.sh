#!/bin/bash
# Generate OpenCode config files from .env
# Creates auth.json and opencode.json in .opencode/ directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
OPENCODE_DIR="${SCRIPT_DIR}/.opencode"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}✓ OpenCode Config Generator${NC}"
echo ""

# Check if .env exists
if [[ ! -f "${ENV_FILE}" ]]; then
    echo -e "${RED}✗ ERROR: .env file not found${NC}"
    echo -e "${YELLOW}  Please copy .env.example to .env and configure it${NC}"
    exit 1
fi

# Load .env
source "${ENV_FILE}"
echo -e "${GREEN}✓ Loaded .env file${NC}"

# Create .opencode directory
mkdir -p "${OPENCODE_DIR}"
echo -e "${GREEN}✓ Created .opencode directory${NC}"

# Check if auth.json exists
if [[ ! -f "${OPENCODE_DIR}/auth.json" ]]; then
    echo -e "${YELLOW}⚠ No auth.json found, generating from .env...${NC}"
    
    # Determine provider name from .env or use default
    PROVIDER_NAME="${PROVIDER_NAME:-gwdg}"
    API_KEY="${OPENAI_API_KEY:-${OPENCODE_API_KEY}}"
    
    if [[ -z "${API_KEY}" ]]; then
        echo -e "${RED}✗ ERROR: No API key found in .env${NC}"
        echo -e "${YELLOW}  Please set OPENAI_API_KEY or OPENCODE_API_KEY in .env${NC}"
        exit 1
    fi
    
    # Generate auth.json
    cat > "${OPENCODE_DIR}/auth.json" << EOF
{
  "${PROVIDER_NAME}": {
    "type": "api",
    "key": "${API_KEY}"
  }
}
EOF
    echo -e "${GREEN}✓ Created auth.json${NC}"
else
    echo -e "${GREEN}✓ auth.json already exists${NC}"
fi

# Check if opencode.json exists
if [[ ! -f "${OPENCODE_DIR}/opencode.json" ]]; then
    echo -e "${YELLOW}⚠ No opencode.json found, generating...${NC}"
    
    # Get base URL from .env
    BASE_URL="${OPENAI_BASE_URL:-https://chat-ai.academiccloud.de/v1}"
    PROVIDER_NAME="${PROVIDER_NAME:-gwdg}"
    
    # Fetch available models from /models endpoint
    echo -e "${YELLOW}🔍 Fetching available models from ${BASE_URL}/models...${NC}"
    
    MODELS_JSON=$(curl -s -X GET "${BASE_URL}/models" -H "Authorization: Bearer ${API_KEY}" 2>/dev/null || echo "")
    
    if [[ -z "${MODELS_JSON}" ]] || echo "${MODELS_JSON}" | grep -q "error"; then
        echo -e "${YELLOW}⚠ Could not fetch models from API, using default list${NC}"
        # Default model list
        DEFAULT_MODELS='{
      "glm-4.7": { "name": "glm-4.7" },
      "devstral-2-123b-instruct-2512": { "name": "devstral-2-123b-instruct-2512" },
      "qwen3-30b-a3b-instruct-2507": { "name": "qwen3-30b-a3b-instruct-2507" },
      "gpt-4.1": { "name": "OpenAI gpt-4.1" },
      "claude-opus-4-6": { "name": "claude-opus-4-6" }
    }'
    else
        # Parse models from API response
        echo -e "${GREEN}✓ Found models, presenting options...${NC}"
        
        # Extract model IDs from response (assuming OpenAI-compatible format)
        MODEL_LIST=$(echo "${MODELS_JSON}" | jq -r '.data[].id' 2>/dev/null || echo "")
        
        if [[ -z "${MODEL_LIST}" ]]; then
            echo -e "${YELLOW}⚠ Could not parse models from API response${NC}"
            MODEL_LIST="glm-4.7 devstral-2-123b-instruct-2512 qwen3-30b-a3b-instruct-2507 gpt-4.1 claude-opus-4-6"
        fi
    fi
    
    # Present model selection via TUI-like menu
    echo ""
    echo -e "${YELLOW}Select a model (enter number):${NC}"
    echo ""
    
    # Build model array for selection
    IFS=' ' read -ra MODELS <<< "${MODEL_LIST:-glm-4.7 devstral-2-123b-instruct-2512 qwen3-30b-a3b-instruct-2507 gpt-4.1 claude-opus-4-6}"
    
    counter=1
    declare -a MODEL_OPTIONS
    for model in "${MODELS[@]}"; do
        echo -e "  ${GREEN}${counter}${NC}) ${model}"
        MODEL_OPTIONS+=("${model}")
        ((counter++))
    done
    echo ""
    
    read -p "  Selection [1-${#MODEL_OPTIONS[@]}]: " -r
    echo
    
    # Validate selection
    if [[ -z "${REPLY}" ]] || [[ ! "${REPLY}" =~ ^[0-9]+$ ]] || [[ "${REPLY}" -lt 1 ]] || [[ "${REPLY}" -gt "${#MODEL_OPTIONS[@]}" ]]; then
        echo -e "${YELLOW}⚠ Invalid selection, using first model${NC}"
        SELECTED_MODEL="${MODEL_OPTIONS[0]}"
    else
        SELECTED_MODEL="${MODEL_OPTIONS[$((REPLY-1))]}"
    fi
    
    echo -e "${GREEN}✓ Selected model: ${SELECTED_MODEL}${NC}"
    echo ""
    
    # Generate opencode.json
    cat > "${OPENCODE_DIR}/opencode.json" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "${PROVIDER_NAME}/${SELECTED_MODEL}",
  "autoupdate": false,
  "provider": {
    "${PROVIDER_NAME}": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "${PROVIDER_NAME^}",
      "options": {
        "baseURL": "${BASE_URL}"
      },
      "models": {
        "${SELECTED_MODEL}": {
          "name": "${SELECTED_MODEL}"
        }
      }
    }
  }
}
EOF
    echo -e "${GREEN}✓ Created opencode.json${NC}"
else
    echo -e "${GREEN}✓ opencode.json already exists${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Config files generated successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Files created:"
echo -e "    ${YELLOW}${OPENCODE_DIR}/auth.json${NC}"
echo -e "    ${YELLOW}${OPENCODE_DIR}/opencode.json${NC}"
echo ""
echo -e "  Next: Run ./start-opencode.sh to start the container"
echo ""
