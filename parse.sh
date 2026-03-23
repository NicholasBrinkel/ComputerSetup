#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

parse_input() {
    local input="$1"
    local intent=""
    local value=""

    if [[ "$input" =~ ^brew\ install\ (.+)$ ]]; then
        local pkg="${BASH_REMATCH[1]}"

        if brew info --cask "$pkg" &>/dev/null; then
            intent="Brew-Cask"
            value="$pkg"
        else
            intent="Brew-Formula"
            value="$pkg"
        fi

    elif [[ "$input" =~ ^defaults\ write\ (.+)$ ]]; then
        intent="System-Setting"
        value="$input"

    elif [[ "$input" =~ ^export\ (.+)$ ]]; then
        intent="Env-Variable"
        value="$input"

    elif [[ "$input" =~ ^alias\ (.+)$ ]]; then
        intent="Shell-Config"
        value="$input"

    elif [[ -f "${SCRIPT_DIR}/${input}" ]]; then
        intent="Command"
        value="$input"

    elif [[ -f "$input" ]]; then
        intent="Command"
        value="$input"

    else
        intent="Invalid"
        value=""
    fi

    jq -n --arg intent "$intent" --arg value "$value" '{"intent": $intent, "value": $value}'
}

parse_input "${1:-}"
