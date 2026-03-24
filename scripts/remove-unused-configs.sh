#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/logging.sh"

info() {
    echo "[INFO] $1"
}

is_in_brew_config() {
    local item="$1"
    jq -r '.formulas[] // empty' "${SCRIPT_DIR}/brew-config.json" | grep -qx "$item"
}

is_in_cask_config() {
    local item="$1"
    jq -r '.casks[] // empty' "${SCRIPT_DIR}/brew-config.json" | grep -qx "$item"
}

is_in_path_exports() {
    local key="$1"
    local result
    result=$(jq -r ".exports.values | has(\"$key\")" "${SCRIPT_DIR}/path-config.json" 2>/dev/null)
    [[ "$result" == "true" ]]
}

is_in_path_shell_configs() {
    local config="$1"
    jq -r '.shell_configs.values[] // empty' "${SCRIPT_DIR}/path-config.json" | grep -qx "$config"
}

remove_config() {
    local config_name="${1:-}"
    
    if [[ -z "$config_name" ]]; then
        echo "Usage: setup config remove <appname>"
        echo "Example: setup config remove neovim"
        exit 1
    fi

    local config_file="${SCRIPT_DIR}/configs/enabled/${config_name}/config.json"
    
    if [[ ! -f "$config_file" ]]; then
        error "Config not found: $config_name"
        exit 1
    fi

    info "Removing config: $config_name"

    # Remove formulas defined in this config (only if not in brew-config.json)
    while IFS= read -r formula; do
        [[ -n "$formula" ]] || continue
        if ! is_in_brew_config "$formula"; then
            if brew list "$formula" &>/dev/null; then
                info "Uninstalling formula: $formula"
                brew uninstall "$formula" 2>/dev/null || true
            fi
        else
            info "Skipping formula (in brew-config.json): $formula"
        fi
    done < <(jq -r '.formulas[] // empty' "$config_file")

    # Remove casks defined in this config (only if not in brew-config.json)
    while IFS= read -r cask; do
        [[ -n "$cask" ]] || continue
        if ! is_in_cask_config "$cask"; then
            if brew list --cask "$cask" &>/dev/null; then
                info "Uninstalling cask: $cask"
                brew uninstall --cask "$cask" 2>/dev/null || true
            fi
        else
            info "Skipping cask (in brew-config.json): $cask"
        fi
    done < <(jq -r '.casks[] // empty' "$config_file")

    # Remove exports defined in this config (only if not in path-config.json)
    local setup_file="${HOME}/.computer-setup"
    if [[ -f "$setup_file" ]]; then
        while IFS= read -r key; do
            [[ -n "$key" ]] || continue
            if ! is_in_path_exports "$key"; then
                if grep -q "^export $key=" "$setup_file" 2>/dev/null; then
                    info "Removing export: $key"
                    sed -i '' "/^export $key=/d" "$setup_file"
                fi
            else
                info "Skipping export (in path-config.json): $key"
            fi
        done < <(jq -r '.exports | to_entries[] | .key' "$config_file")
    fi

    # Remove shell_configs defined in this config (only if not in path-config.json)
    if [[ -f "$setup_file" ]]; then
        while IFS= read -r shell_config; do
            [[ -n "$shell_config" ]] || continue
            if ! is_in_path_shell_configs "$shell_config"; then
                if grep -q "^${shell_config}$" "$setup_file" 2>/dev/null; then
                    info "Removing shell config: $shell_config"
                    sed -i '' "/^${shell_config}$/d" "$setup_file"
                fi
            else
                info "Skipping shell config (in path-config.json): $shell_config"
            fi
        done < <(jq -r '.shell_configs[] // empty' "$config_file")
    fi

    success "Removed config: $config_name"
}

remove_config "$@"