#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/path-config.json"
SETUP_FILE="$HOME/.computer-setup"

add_to_shell_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Config file not found: $CONFIG_FILE"
        exit 1
    fi

    echo "# ComputerSetup - $(date '+%Y-%m-%d')" > "$SETUP_FILE"
    echo "" >> "$SETUP_FILE"

    jq --arg script_dir "$SCRIPT_DIR" -r '.exports.values // {} | to_entries[] | "export \(.key)=\(.value | gsub("\\{SCRIPT_DIR\\}"; $script_dir))"' "$CONFIG_FILE" >> "$SETUP_FILE"

    while IFS= read -r line; do
        [[ -n "$line" ]] && echo "$line" >> "$SETUP_FILE"
    done < <(jq -r '.shell_configs.values[] // []' "$CONFIG_FILE" 2>/dev/null)

    while IFS='=' read -r cmd script; do
        [[ -z "$cmd" ]] && continue
        echo "${cmd}() { \"${SCRIPT_DIR}/${script}\" \"\$@\"; }" >> "$SETUP_FILE"
    done < <(jq -r '.commands.values // {} | to_entries[] | "\(.key)=\(.value)"' "$CONFIG_FILE" 2>/dev/null)

    echo "" >> "$SETUP_FILE"
    echo "# End ComputerSetup" >> "$SETUP_FILE"

    add_source_to_rc

    echo "Created $SETUP_FILE with your configuration"
    echo "Restart your terminal or run: source ~/.zshrc"
}

add_source_to_rc() {
    local rc_file="$HOME/.zshrc"
    [[ -n "${BASH_VERSION:-}" ]] && rc_file="$HOME/.bashrc"

    local source_line="source ~/.computer-setup"
    local section_header="# ComputerSetup"

    if grep -q "$source_line" "$rc_file" 2>/dev/null; then
        return 0
    fi

    echo "" >> "$rc_file"
    echo "$section_header" >> "$rc_file"
    echo "$source_line" >> "$rc_file"
}

add_to_shell_config
