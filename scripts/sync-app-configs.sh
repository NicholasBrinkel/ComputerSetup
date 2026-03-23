#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/configs/enabled"

source "${SCRIPT_DIR}/lib/logging.sh"

info() {
    echo "[INFO] $1"
}

info "Syncing app configs..."

if [[ ! -d "$CONFIG_DIR" ]]; then
    info "No enabled configs directory found"
    return 0
fi

for config_file in "$CONFIG_DIR"/*.json; do
    [[ -e "$config_file" ]] || continue

    local name
    name=$(basename "$config_file" .json)

    info "Processing config: $name"

    local display_name
    display_name=$(jq -r '.name // $name' "$config_file")
    banner "App Config: $display_name"

    while IFS= read -r formula; do
        [[ -n "$formula" ]] || continue
        if brew list "$formula" &>/dev/null; then
            info "Skipping (already installed): $formula"
        else
            info "Installing formula: $formula"
            brew install "$formula"
        fi
    done < <(jq -r '.settings.formulas[] // []' "$config_file")

    while IFS= read -r cask; do
        [[ -n "$cask" ]] || continue
        if brew list --cask "$cask" &>/dev/null; then
            info "Skipping (already installed): $cask"
        else
            info "Installing cask: $cask"
            brew install --cask "$cask"
        fi
    done < <(jq -r '.settings.casks[] // []' "$config_file")

    while IFS='=' read -r key value; do
        [[ -n "$key" ]] || continue
        info "Adding export: $key"
        "${SCRIPT_DIR}/lib/add-env-variable.sh" "export $key=$value" 2>/dev/null || true
    done < <(jq -r '.settings.exports // {} | to_entries[] | "\(.key)=\(.value)"' "$config_file")

    while IFS= read -r shell_config; do
        [[ -n "$shell_config" ]] || continue
        info "Adding shell config: $shell_config"
        "${SCRIPT_DIR}/lib/add-shell-config.sh" "$shell_config" 2>/dev/null || true
    done < <(jq -r '.settings.shell_configs[] // []' "$config_file")

    while IFS= read -r setting; do
        [[ -n "$setting" ]] || continue
        info "Applying system setting: $setting"
        eval "$setting"
    done < <(jq -r '.settings.system_settings[] // []' "$config_file")
done

info "App configs sync complete"
