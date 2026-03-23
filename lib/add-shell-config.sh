#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/path-config.json"

add_shell_config() {
    local config="$1"

    if jq -e --arg config "$config" '.shell_configs.values[] | select(. == $config)' "$CONFIG_FILE" &>/dev/null; then
        echo "Shell config already in path-config.json"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)
    jq --arg config "$config" '.shell_configs.values += [$config]' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
    echo "Added shell config: $config"
}

add_shell_config "${1:-}"
