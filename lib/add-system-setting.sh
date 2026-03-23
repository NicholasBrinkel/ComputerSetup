#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/system-config.json"

add_system_setting() {
    local setting="$1"

    if [[ "$setting" =~ defaults\ write\ com\.apple\.finder\ AppleShowAllFiles ]]; then
        local key="show_hidden_files"
        local temp_file
        temp_file=$(mktemp)
        jq --arg key "$key" '.[$key] = true' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
        echo "Added system setting: show hidden files"
    else
        local temp_file
        temp_file=$(mktemp)
        jq -r --arg setting "$setting" '.custom_settings += [$setting]' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
        echo "Added system setting: $setting"
    fi
}

add_system_setting "${1:-}"
