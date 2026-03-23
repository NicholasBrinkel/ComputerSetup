#!/bin/bash

configure_system() {
    source "${SCRIPT_DIR}/lib/logging.sh"

    banner "Configuring System Settings"

    local config_file="${SCRIPT_DIR}/system-config.json"
    if [[ ! -f "$config_file" ]]; then
        error "Config file not found: $config_file"
        exit 1
    fi

    local macos_settings
    macos_settings=$(jq -c '.' "$config_file" 2>/dev/null || echo "{}")

    if [[ "$macos_settings" == "{}" ]] || [[ -z "$macos_settings" ]]; then
        info "No macOS settings configured"
        return 0
    fi

    if [[ "$(jq -r '.show_hidden_files' "$config_file")" == "true" ]]; then
        if confirm "Show hidden files in Finder?" "y"; then
            info "Enabling hidden files in Finder..."
            defaults write com.apple.finder AppleShowAllFiles -bool true
            killall Finder 2>/dev/null || true
        fi
    fi

    if [[ "$(jq -r '.show_path_bar' "$config_file")" == "true" ]]; then
        if confirm "Show path bar in Finder?" "y"; then
            info "Enabling path bar in Finder..."
            defaults write com.apple.finder ShowPathbar -bool true
            killall Finder 2>/dev/null || true
        fi
    fi

    if [[ "$(jq -r '.expand_save_panel' "$config_file")" == "true" ]]; then
        if confirm "Expand save dialogs by default?" "y"; then
            info "Expanding save dialogs..."
            defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
        fi
    fi

    success "System settings configured"
}
