#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    source "${SCRIPT_DIR}/lib/logging.sh"
    source "${SCRIPT_DIR}/lib/colors.sh"

    info "Configuring PATH and commands..."
    source "${SCRIPT_DIR}/add-to-path.sh"

    banner "Computer Setup"

    source "${SCRIPT_DIR}/install-brew.sh"
    install_brew || true

    source "${SCRIPT_DIR}/brew-apps.sh"
    install_brew_apps

    source "${SCRIPT_DIR}/apply-custom-system-settings.sh"
    configure_system
}

main "$@"
