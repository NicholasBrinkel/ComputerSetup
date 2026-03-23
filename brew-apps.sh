#!/bin/bash

install_brew_apps() {
    source "${SCRIPT_DIR}/lib/logging.sh"

    require brew

    banner "Installing Brew Apps"

    local config_file="${SCRIPT_DIR}/brew-config.json"
    if [[ ! -f "$config_file" ]]; then
        error "Config file not found: $config_file"
        exit 1
    fi

    local formulas
    local casks
    formulas=$(jq -r '.formulas[]' "$config_file" 2>/dev/null || echo "")
    casks=$(jq -r '.casks[]' "$config_file" 2>/dev/null || echo "")

    local pids=()
    local installed_count=0
    local skipped_count=0

    for formula in $formulas; do
        [[ -z "$formula" ]] && continue
        if brew list "$formula" &>/dev/null; then
            info "Skipping (already installed): $formula"
            ((skipped_count++))
        else
            info "Installing formula: $formula"
            brew install "$formula" &
            pids+=($!)
            ((installed_count++))
        fi
    done

    for cask in $casks; do
        [[ -z "$cask" ]] && continue
        if brew list --cask "$cask" &>/dev/null; then
            info "Skipping (already installed): $cask"
            ((skipped_count++))
        else
            info "Installing cask: $cask"
            brew install --cask "$cask" &
            pids+=($!)
            ((installed_count++))
        fi
    done

    if [[ ${#pids[@]} -gt 0 ]]; then
        info "Installing $installed_count app(s) in parallel..."
        for pid in "${pids[@]}"; do
            wait "$pid" && success "Installation completed" || error "Installation failed (PID: $pid)"
        done
    fi

    [[ $skipped_count -gt 0 ]] && info "Skipped $skipped_count already-installed app(s)"
    success "All applications processed"
}
