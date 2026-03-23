#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/path-config.json"

add_to_shell_config() {
    local rc_file="$HOME/.zshrc"
    [[ -n "${BASH_VERSION:-}" ]] && rc_file="$HOME/.bashrc"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Config file not found: $CONFIG_FILE"
        exit 1
    fi

    local section_header="# ComputerSetup"

    if grep -q "$section_header" "$rc_file" 2>/dev/null; then
        echo "ComputerSetup already configured in $rc_file"
        return 0
    fi

    echo "" >> "$rc_file"
    echo "$section_header" >> "$rc_file"

    jq --arg script_dir "$SCRIPT_DIR" -r '.exports.values // {} | to_entries[] | "export \(.key)=\(.value | gsub("\\{SCRIPT_DIR\\}"; $script_dir))"' "$CONFIG_FILE" >> "$rc_file"

    while IFS= read -r line; do
        [[ -n "$line" ]] && echo "$line" >> "$rc_file"
    done < <(jq -r '.shell_configs.values[] // []' "$CONFIG_FILE" 2>/dev/null)

    while IFS='=' read -r cmd script; do
        [[ -z "$cmd" ]] && continue
        echo "${cmd}() { \"${SCRIPT_DIR}/${script}\" \"\$@\"; }" >> "$rc_file"
    done < <(jq -r '.commands.values // {} | to_entries[] | "\(.key)=\(.value)"' "$CONFIG_FILE" 2>/dev/null)

    echo "Added configuration to $rc_file"
    echo "Restart your terminal or run: source $rc_file"
}

add_to_shell_config
