#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/configs/enabled"

source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/logging.sh"

info() {
    echo "[INFO] $1"
}

sync_configs() {
    info "Syncing app configs..."

    if [[ ! -d "$CONFIG_DIR" ]]; then
        info "No enabled configs directory found"
        return 0
    fi

    for config_dir in "$CONFIG_DIR"/*/; do
        [[ -d "$config_dir" ]] || continue

        local name
        name=$(basename "$config_dir")
        local config_file="${config_dir}config.json"

        if [[ ! -f "$config_file" ]]; then
            info "Skipping $name (no config.json)"
            continue
        fi

        info "Processing config: $name"

        local display_name
        display_name=$(jq -r --arg name "$name" '.name // $name' "$config_file")
        banner "App Config: $display_name"

        while IFS= read -r formula; do
            [[ -n "$formula" ]] || continue
            if brew list "$formula" &>/dev/null; then
                info "Skipping (already installed): $formula"
            else
                info "Installing formula: $formula"
                brew install "$formula" || info "Failed to install: $formula (continuing)"
            fi
        done < <(jq -r '.formulas[] // empty' "$config_file")

        while IFS= read -r cask; do
            [[ -n "$cask" && "$cask" != "[]" ]] || continue
            if brew list --cask "$cask" &>/dev/null; then
                info "Skipping (already installed): $cask"
            else
                info "Installing cask: $cask"
                brew install --cask "$cask" || info "Failed to install: $cask (continuing)"
            fi
        done < <(jq -r '.casks[] // empty' "$config_file")

        while IFS='=' read -r key value; do
            [[ -n "$key" ]] || continue
            info "Adding export: $key"
            "${SCRIPT_DIR}/lib/add-env-variable.sh" "export $key=$value" 2>/dev/null || true
        done < <(jq -r '.exports // {} | to_entries[] | "\(.key)=\(.value)"' "$config_file")

        while IFS= read -r shell_config; do
            [[ -n "$shell_config" ]] || continue
            info "Adding shell config: $shell_config"
            "${SCRIPT_DIR}/lib/add-shell-config.sh" "$shell_config" 2>/dev/null || true
        done < <(jq -r '.shell_configs[] // empty' "$config_file")

        while IFS= read -r setting; do
            [[ -n "$setting" ]] || continue
            info "Applying system setting: $setting"
            eval "$setting"
        done < <(jq -r '.system_settings[] // empty' "$config_file")

        local post_install_script
        post_install_script=$(jq -r '."post-install-setup-script" // empty' "$config_file")

        if [[ -n "$post_install_script" ]]; then
            local script_path="${config_dir}${post_install_script}"
            if [[ -f "$script_path" ]]; then
                info "Running post-install setup: $post_install_script"
                chmod +x "$script_path"
                "$script_path"
            else
                info "Post-install script not found: $script_path"
            fi
        fi
    done

    info "App configs sync complete"
}

sync_configs
