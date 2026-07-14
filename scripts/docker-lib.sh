#!/bin/bash
# =============================================================================
# Advanced Coding Agent - Docker Image Management Library
# =============================================================================
# Shared functions for Docker build and start script management
# =============================================================================

# -----------------------------------------------------------------------------
# Color Definitions
# -----------------------------------------------------------------------------
declare -gr RED='\033[0;31m'
declare -gr GREEN='\033[0;32m'
declare -gr YELLOW='\033[1;33m'
declare -gr BLUE='\033[0;34m'
declare -gr NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Discover extension Dockerfiles for a given runtime
# Returns array of discovered extensions
# Usage: extensions=($(discover_extensions "opencode"))
# Note: Extensions can now be shared between runtimes via BASE_IMAGE ARG
# -----------------------------------------------------------------------------
discover_extensions() {
    local runtime="$1"
    local script_dir="$2"
    local dockerfiles_dir="${script_dir}/dockerfiles"
    local extensions=()
    
    if [[ ! -d "${dockerfiles_dir}" ]]; then
        echo "${extensions[@]}"
        return
    fi
    
    # Find all Dockerfiles in dockerfiles/ directory
    for dockerfile in "${dockerfiles_dir}"/Dockerfile.*; do
        # Skip if no files match
        [[ ! -f "${dockerfile}" ]] && continue
        
        local filename=$(basename "${dockerfile}")
        local extension_name="${filename#Dockerfile.}"
        
        # Skip invalid filenames
        if [[ "${filename}" == "${extension_name}" ]]; then
            continue
        fi
        
        # All extensions are now valid for all runtimes
        # The BASE_IMAGE will be provided via build argument
        extensions+=("${extension_name}")
    done
    
    echo "${extensions[@]}"
}

# -----------------------------------------------------------------------------
# Extract FROM instruction from a Dockerfile
# Usage: base_image=$(extract_from_instruction "path/to/Dockerfile")
# -----------------------------------------------------------------------------
extract_from_instruction() {
    local dockerfile="$1"
    local base_image=""
    
    # Check for ARG BASE_IMAGE pattern first
    base_image=$(grep -i '^ARG.*BASE_IMAGE' "${dockerfile}" | head -1)
    if [[ -n "${base_image}" ]]; then
        # Extract the value from the ARG instruction
        base_image=$(echo "${base_image}" | sed 's/.*BASE_IMAGE=\([^[:space:]]*\).*/\1/')
        echo "${base_image}"
        return
    fi
    
    # Extract the first FROM instruction
    base_image=$(grep -i '^FROM' "${dockerfile}" | head -1)
    if [[ -n "${base_image}" ]]; then
        base_image=$(echo "${base_image}" | sed 's/^FROM\s*//i')
        # Handle variable substitutions in FROM
        base_image=$(echo "${base_image}" | sed 's/\${BASE_IMAGE}//g')
    fi
    
    # Clean up the base image (remove trailing comments, whitespace)
    base_image=$(echo "${base_image}" | sed 's/#.*$//;s/[[:space:]]*$//')
    
    echo "${base_image}"
}

# -----------------------------------------------------------------------------
# Discover built Docker images for a given runtime
# Returns array of available images
# Usage: images=($(discover_built_images "opencode"))
# -----------------------------------------------------------------------------
discover_built_images() {
    local runtime="$1"
    local images=()
    
    # Get all images matching the runtime pattern
    local pattern="advanced-coding-agent-${runtime}"
    
    while IFS= read -r line; do
        local repository=$line
        local tag="latest"
        
        # Handle both "repo:tag" and plain "repo" formats
        if [[ "${repository}" =~ : ]]; then
            tag="${repository##*:}"
            repository="${repository%:*}"
        fi
        
        # Remove localhost/ prefix if present
        repository="${repository#localhost/}"
        
        # Check if matches our pattern
        if [[ "${repository}" == "${pattern}"* ]]; then
            images+=("${repository}:${tag}")
        fi
    done < <(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null)
    
    echo "${images[@]}"
}

# -----------------------------------------------------------------------------
# Parse image name to extract runtime and extension
# Usage: parse_image_name "advanced-coding-agent-opencode-latex:latest"
# Returns: "opencode:latex"
# -----------------------------------------------------------------------------
parse_image_name() {
    local full_image="$1"
    local image_name="${full_image%:*}"
    local runtime
    local extension
    
    # Remove base prefix
    local base_name="${image_name#advanced-coding-agent-}"
    
    # Extract runtime (opencode or openclaude)
    if [[ "${base_name}" =~ ^opencode ]]; then
        runtime="opencode"
        base_name="${base_name#opencode}"
    elif [[ "${base_name}" =~ ^openclaude ]]; then
        runtime="openclaude"
        base_name="${base_name#openclaude}"
    else
        echo "unknown:unknown"
        return
    fi
    
    # Extract extension (everything after the dash)
    if [[ "${base_name}" =~ ^-(.+) ]]; then
        extension="${base_name#-}"
    else
        extension="base"
    fi
    
    echo "${runtime}:${extension}"
}

# -----------------------------------------------------------------------------
# Validate that a base image exists and is buildable
# Usage: validate_base_image "opencode" "/path/to/script/directory"
# -----------------------------------------------------------------------------
validate_base_image() {
    local runtime="$1"
    local script_dir="$2"
    local base_dockerfile="${script_dir}/Dockerfile.${runtime}"
    
    if [[ ! -f "${base_dockerfile}" ]]; then
        echo -e "${RED}✗ ERROR: Base Dockerfile not found: ${base_dockerfile}${NC}"
        return 1
    fi
    
    return 0
}

# -----------------------------------------------------------------------------
# Display build menu and get user selection
# Usage: selection=$(display_build_menu "opencode" "extension1" "extension2")
# Returns: "base", "extension1", "all", or "exit"
# Note: Visual output goes to stderr, only selection is sent to stdout
# -----------------------------------------------------------------------------
display_build_menu() {
    local runtime="$1"
    shift
    local extensions=("$@")
    
    # All visual output goes to stderr so it doesn't interfere with the return value
    echo "" >&2
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}" >&2
    echo -e "${GREEN}  Build Options for ${runtime^} Runtime${NC}" >&2
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}" >&2
    echo "" >&2
    
    if [[ ${#extensions[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No extension Dockerfiles found${NC}" >&2
        echo "" >&2
    else
        echo -e "${BLUE}ℹ Extensions are available to both runtimes${NC}" >&2
        echo "" >&2
    fi
    
    echo -e "${YELLOW}Available Options:${NC}" >&2
    echo "" >&2
    echo -e "${YELLOW}1)${NC} Base Image Only (Dockerfile.${runtime})" >&2
    local option_num=2
    
    for ext in "${extensions[@]}"; do
        echo -e "${YELLOW}${option_num})${NC} Base + ${ext^} Support (Dockerfile.${ext})" >&2
        ((option_num++))
    done
    
    local all_option_num="${option_num}"
    echo -e "${YELLOW}${option_num})${NC} Build All Images" >&2
    ((option_num++))
    
    local exit_option_num="${option_num}"
    echo -e "${YELLOW}${option_num})${NC} Exit" >&2
    echo "" >&2
    
    while true; do
        read -p "Select option [1-${option_num}]: " selection
        
        if [[ "${selection}" == "1" ]]; then
            echo "base"
            return
        elif [[ "${selection}" == "${all_option_num}" ]]; then
            echo "all"
            return
        elif [[ "${selection}" == "${exit_option_num}" ]]; then
            echo "exit"
            return
        elif [[ "${selection}" =~ ^[0-9]+$ ]] && [[ "${selection}" -ge 2 ]] && [[ "${selection}" -lt "${all_option_num}" ]]; then
            local ext_index=$((selection - 2))
            if [[ "${ext_index}" -ge 0 ]] && [[ "${ext_index}" -lt "${#extensions[@]}" ]]; then
                echo "${extensions[ext_index]}"
                return
            else
                echo -e "${RED}✗ Invalid option. Please try again.${NC}" >&2
            fi
        else
            echo -e "${RED}✗ Invalid option. Please try again.${NC}" >&2
        fi
    done
}

# -----------------------------------------------------------------------------
# Display start menu and get user selection
# Usage: selection=$(display_start_menu "opencode" "base" "latex")
# Returns: selected image name or "exit"
# Note: Visual output goes to stderr, only selection is sent to stdout
# -----------------------------------------------------------------------------
display_start_menu() {
    local runtime="$1"
    shift
    local images=("$@")
    
    # All visual output goes to stderr so it doesn't interfere with the return value
    echo "" >&2
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}" >&2
    echo -e "${GREEN}  Available Images for ${runtime^} Runtime${NC}" >&2
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}" >&2
    echo "" >&2
    
    if [[ ${#images[@]} -eq 0 ]]; then
        echo -e "${RED}✗ No images found${NC}" >&2
        echo -e "${YELLOW}  Build images first: ./build-${runtime}.sh${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}Available Options:${NC}" >&2
        echo "" >&2
        echo -e "${YELLOW}1) Exit${NC}" >&2
        echo "" >&2
        
        while true; do
            read -p "Select option [1]: " selection
            if [[ "${selection}" == "1" ]]; then
                echo "exit"
                return
            else
                echo -e "${RED}✗ Invalid option. Please try again.${NC}" >&2
            fi
        done
    fi
    
    local option_num=1
    echo -e "${YELLOW}Available Images:${NC}" >&2
    echo "" >&2
    for image in "${images[@]}"; do
        local parsed=$(parse_image_name "${image}")
        local img_runtime="${parsed%%:*}"
        local extension="${parsed##*:}"
        
        local display_name="Base Only"
        if [[ "${extension}" != "base" ]]; then
            display_name="Base + ${extension^}"
        fi
        
        echo -e "${YELLOW}${option_num})${NC} ${display_name}: ${image}" >&2
        ((option_num++))
    done
    
    echo -e "${YELLOW}${option_num})${NC} Exit" >&2
    echo "" >&2
    
    while true; do
        read -p "Select image to start [1-${option_num}]: " selection
        
        if [[ "${selection}" =~ ^[0-9]+$ ]] && [[ "${selection}" -ge 1 ]] && [[ "${selection}" -le "${option_num}" ]]; then
            if [[ "${selection}" == "${option_num}" ]]; then
                echo "exit"
                return
            else
                local index=$((selection - 1))
                echo "${images[index]}"
                return
            fi
        else
            echo -e "${RED}✗ Invalid option. Please try again.${NC}" >&2
        fi
    done
}