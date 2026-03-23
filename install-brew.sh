#!/bin/bash

install_brew() {
    if command -v brew &>/dev/null; then
        info "Homebrew is already installed: $(brew --version)"
        return 0
    fi

    banner "Installing Homebrew"

    if confirm "Install a custom version of Homebrew?" "n"; then
        read -p "Enter the Homebrew install URL (or press Enter for default): " custom_url
        if [[ -n "$custom_url" ]]; then
            info "Installing custom Homebrew from: $custom_url"
            /bin/bash -c "$(curl -fsSL "$custom_url")"
        else
            install_default_brew
        fi
    else
        install_default_brew
    fi

    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    success "Homebrew installed successfully"
}

install_default_brew() {
    info "Installing Homebrew (official)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
