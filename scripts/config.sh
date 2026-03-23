#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/configs/enabled"

new_config() {
    local name="$1"
    local file="${CONFIG_DIR}/${name}.json"

    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
    fi

    cat > "$file" <<EOF
{
    "name": "${name}",
    "description": "optional description",
    "settings": {
        "formulas": [],
        "casks": [],
        "exports": {},
        "shell_configs": [],
        "commands": {},
        "system_settings": []
    }
}
EOF

    echo "Created $file"

    local editor_choice=""
    local editor=""
    
    while [[ -z "$editor_choice" ]]; do
        read -p "Open in TextEdit or \$EDITOR? [t/e]: " editor_choice
        case "$editor_choice" in
            t|T)
                editor="TextEdit"
                open -a "TextEdit" "$file"
                ;;
            e|E)
                if [[ -n "${EDITOR:-}" ]]; then
                    editor="$EDITOR"
                    eval "$EDITOR \"$file\""
                else
                    echo "EDITOR env variable not set"
                    editor_choice=""
                fi
                ;;
            *)
                echo "Invalid choice"
                editor_choice=""
                ;;
        esac
    done
}

new_config "${1:-}"
