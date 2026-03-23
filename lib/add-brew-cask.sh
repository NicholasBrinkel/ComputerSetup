#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/brew-config.json"

add_brew_cask() {
    local cask="$1"

    if jq -e --arg cask "$cask" '.casks[] | select(. == $cask)' "$CONFIG_FILE" &>/dev/null; then
        echo "Cask '$cask' already in brew-config.json"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)
    jq --arg cask "$cask" '.casks += [$cask]' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
    echo "Added cask: $cask"
}

add_brew_cask "${1:-}"
