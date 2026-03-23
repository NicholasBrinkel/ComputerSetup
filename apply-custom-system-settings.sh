#!/bin/bash

configure_system() {
    source "${SCRIPT_DIR}/lib/logging.sh"

    banner "Configuring System Settings"

    local config_file="${SCRIPT_DIR}/system-config.json"
    if [[ ! -f "$config_file" ]]; then
        error "Config file not found: $config_file"
        return 1
    fi

    if [[ "$(jq -r '.show_hidden_files' "$config_file")" == "true" ]]; then
        info "Enabling hidden files in Finder..."
        defaults write com.apple.finder AppleShowAllFiles -bool true
    fi

    if [[ "$(jq -r '.show_path_bar' "$config_file")" == "true" ]]; then
        info "Enabling path bar in Finder..."
        defaults write com.apple.finder ShowPathbar -bool true
    fi

    if [[ "$(jq -r '.expand_save_panel' "$config_file")" == "true" ]]; then
        info "Expanding save dialogs..."
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    fi

    if [[ "$(jq -r '.show_path_bar' "$config_file")" == "true" ]] || [[ "$(jq -r '.show_hidden_files' "$config_file")" == "true" ]]; then
        killall Finder 2>/dev/null || true
    fi

    success "System settings configured"
}
