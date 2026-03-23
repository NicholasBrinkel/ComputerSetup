#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/path-config.json"
USER_SCRIPTS_DIR="${SCRIPT_DIR}/user-scripts"

add_command() {
    local input="$1"
    local target_path=""
    local cmd_name=""

    if [[ -f "${SCRIPT_DIR}/${input}" ]]; then
        target_path="$input"
        cmd_name=$(basename "$input" .sh)
    elif [[ -f "$input" ]]; then
        local filename
        filename=$(basename "$input")
        local dest="${USER_SCRIPTS_DIR}/${filename}"

        if [[ ! -d "$USER_SCRIPTS_DIR" ]]; then
            mkdir -p "$USER_SCRIPTS_DIR"
        fi

        read -p "Script '$input' not in repo. Copy (c), Move (m), or Reference (r)? [c/m/r]: " action
        action="${action:-c}"

        case "$action" in
            m|M)
                mv "$input" "$dest"
                chmod +x "$dest"
                target_path="user-scripts/${filename}"
                ;;
            r|R)
                target_path="$input"
                ;;
            *)
                cp "$input" "$dest"
                chmod +x "$dest"
                target_path="user-scripts/${filename}"
                ;;
        esac

        cmd_name=$(basename "$target_path" .sh)
    else
        echo "Error: Script not found: $input"
        return 1
    fi

    if jq -e --arg cmd "$cmd_name" '.commands.values[$cmd]' "$CONFIG_FILE" &>/dev/null; then
        echo "Command '$cmd_name' already in path-config.json"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)
    jq --arg cmd "$cmd_name" --arg path "$target_path" '.commands.values[$cmd] = $path' "$CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$CONFIG_FILE"
    echo "Added command: $cmd_name -> $target_path"
}

add_command "${1:-}"
