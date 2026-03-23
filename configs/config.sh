#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_DIR="${SCRIPT_DIR}/configs/active"

new_config() {
    local name="$1"
    local config_dir="${ACTIVE_DIR}/${name}"

    if [[ -d "$config_dir" ]]; then
        echo "Config '$name' already exists at $config_dir"
        open_editor "$config_dir/config.json"
        return 0
    fi

    mkdir -p "${config_dir}/files"

    cat > "${config_dir}/config.json" <<EOF
{
    "name": "${name}",
    "description": "optional description",
    "setup-script": "${name}-setup.sh"
}
EOF

    cat > "${config_dir}/${name}-setup.sh" <<EOF
#!/bin/bash
set -euo pipefail

CONFIG_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up ${name}..."

# Add your setup commands here
# Copy config files:
# cp -R "\${CONFIG_DIR}/files/"* ~/\${HOME}/

echo "${name} setup complete"
EOF

    chmod +x "${config_dir}/${name}-setup.sh"

    echo "Created config directory: $config_dir"
    echo "  - config.json"
    echo "  - ${name}-setup.sh"
    echo "  - files/"

    open_editor "${config_dir}/config.json"
}

open_editor() {
    local file="$1"
    local editor_choice=""
    
    while [[ -z "$editor_choice" ]]; do
        read -p "Open in TextEdit or \$EDITOR? [t/e]: " editor_choice
        case "$editor_choice" in
            t|T)
                open -a "TextEdit" "$file"
                ;;
            e|E)
                if [[ -n "${EDITOR:-}" ]]; then
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
