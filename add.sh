#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

add_to_config() {
    local input="$1"
    local parsed
    parsed=$("${SCRIPT_DIR}/parse.sh" "$input")
    
    local intent
    local value
    intent=$(echo "$parsed" | jq -r '.intent')
    value=$(echo "$parsed" | jq -r '.value')

    if [[ "$intent" == "Invalid" ]]; then
        echo "Error: Unable to parse intent from '$input'" >&2
        exit 1
    fi

    local config_file=""
    local added=false

    case "$intent" in
        Brew-Cask)
            config_file="brew-config.json"
            "${SCRIPT_DIR}/lib/add-brew-cask.sh" "$value" && added=true
            ;;
        Brew-Formula)
            config_file="brew-config.json"
            "${SCRIPT_DIR}/lib/add-brew-formula.sh" "$value" && added=true
            ;;
        System-Setting)
            config_file="system-config.json"
            "${SCRIPT_DIR}/lib/add-system-setting.sh" "$value" && added=true
            ;;
        Env-Variable)
            config_file="path-config.json"
            "${SCRIPT_DIR}/lib/add-env-variable.sh" "$value" && added=true
            ;;
        Shell-Config)
            config_file="path-config.json"
            "${SCRIPT_DIR}/lib/add-shell-config.sh" "$value" && added=true
            ;;
        Command)
            config_file="path-config.json"
            "${SCRIPT_DIR}/lib/add-command.sh" "$input" && added=true
            ;;
        *)
            echo "Error: Unknown intent: $intent" >&2
            exit 1
            ;;
    esac

    if $added; then
        jq -n --arg intent "$intent" --arg value "$value" --arg file "$config_file" \
            '{"intent": $intent, "value": $value, "file": $file}'
    fi
}

add_to_config "${1:-}"
