#!/bin/bash
# =============================================================================
# OpenCode Config Generator
# =============================================================================
# Writes .opencode/auth.json and .opencode/opencode.json from .env.
# The model list is discovered from the provider's /models endpoint.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
OPENCODE_DIR="${SCRIPT_DIR}/.opencode"
DEFAULT_MODEL="qwen3.5-397b-a17b"

# -----------------------------------------------------------------------------
# Inputs
# -----------------------------------------------------------------------------
[[ -f "${ENV_FILE}" ]] || {
    echo "ERROR: .env not found (copy .env.example to .env)" >&2
    exit 1
}
command -v jq >/dev/null || {
    echo "ERROR: jq is required" >&2
    exit 1
}

set -a
source "${ENV_FILE}"
set +a

PROVIDER_NAME="${PROVIDER_NAME:-gwdg}"
BASE_URL="${OPENAI_BASE_URL:-https://chat-ai.academiccloud.de/v1}"
API_KEY="${OPENAI_API_KEY:-${OPENCODE_API_KEY}}"

[[ -n "${API_KEY}" ]] || {
    echo "ERROR: no API key in .env (set OPENCODE_API_KEY)" >&2
    exit 1
}

mkdir -p "${OPENCODE_DIR}"

# -----------------------------------------------------------------------------
# auth.json
# -----------------------------------------------------------------------------
if [[ ! -f "${OPENCODE_DIR}/auth.json" ]]; then
    jq -n --arg p "${PROVIDER_NAME}" --arg k "${API_KEY}" \
        '{($p): {type: "api", key: $k}}' > "${OPENCODE_DIR}/auth.json"
fi

# -----------------------------------------------------------------------------
# opencode.json (provider + discovered models)
# -----------------------------------------------------------------------------
if [[ ! -f "${OPENCODE_DIR}/opencode.json" ]]; then
    MODELS=$(curl -s "${BASE_URL}/models" \
        -H "Authorization: Bearer ${API_KEY}" \
        | jq -c '[.data[].id] | map({key: ., value: {name: .}}) | from_entries' \
            2>/dev/null || true)

    if [[ -z "${MODELS}" || "${MODELS}" == "null" || "${MODELS}" == "{}" ]]; then
        echo "WARN: could not fetch models from ${BASE_URL}/models; using ${DEFAULT_MODEL}" >&2
        MODELS=$(jq -cn --arg m "${DEFAULT_MODEL}" '{($m): {name: $m}}')
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
        --argjson models "${MODELS}" \
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
fi
