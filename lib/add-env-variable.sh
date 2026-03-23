#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/path-config.json"

add_env_variable() {
    local export_line="$1"

    if [[ "$export_line" =~ ^export\ ([^=]+)=(.+)$ ]]; then
        local var_name="${BASH_REMATCH[1]}"
        local var_value="${BASH_REMATCH[2]}"

        if jq -e --arg var "$var_name" '.exports.values[$var]' "$CONFIG_FILE" &>/dev/null; then
            echo "Variable '$var_name' already in path-config.json"
            return 1
        fi

        local temp_file
        temp_file=$(mktemp)
        jq --arg var "$var_name" --arg val "$var_value" '.exports.values[$var] = $val' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
        echo "Added env variable: $var_name"
    else
        echo "Error: Invalid export format: $export_line"
        return 1
    fi
}

add_env_variable "${1:-}"
