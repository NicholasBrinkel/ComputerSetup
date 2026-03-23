#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/brew-config.json"

add_brew_formula() {
    local formula="$1"

    if jq -e --arg formula "$formula" '.formulas[] | select(. == $formula)' "$CONFIG_FILE" &>/dev/null; then
        echo "Formula '$formula' already in brew-config.json"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)
    jq --arg formula "$formula" '.formulas += [$formula]' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
    echo "Added formula: $formula"
}

add_brew_formula "${1:-}"
