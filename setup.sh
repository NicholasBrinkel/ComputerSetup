#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: setup <command>

Commands:
    add <input>     Add a config from user input
    config <name>   Create a new app config
    sync           Sync all configs (install brew apps, apply system settings, update ~/.computer-setup)
    test           Run all tests
    help           Show this help message

EOF
}

run_sync() {
    source "${SCRIPT_DIR}/lib/logging.sh"
    source "${SCRIPT_DIR}/lib/colors.sh"

    info "Sourcing ~/.computer-setup from ~/.zshrc and ~/.bashrc"

    source "${SCRIPT_DIR}/apply-custom-system-settings.sh"
    source "${SCRIPT_DIR}/brew-apps.sh"

    banner "Computer Setup Sync"

    configure_system
    install_brew_apps
    "${SCRIPT_DIR}/add-to-path.sh"
    "${SCRIPT_DIR}/scripts/sync-app-configs.sh"

    success "Sync complete"
}

case "${1:-}" in
    add)
        "${SCRIPT_DIR}/add.sh" "${2:-}"
        ;;
    config)
        "${SCRIPT_DIR}/configs/config.sh" "${2:-}"
        ;;
    sync|"")
        run_sync
        ;;
    test)
        "${SCRIPT_DIR}/tests/test-runner.sh"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
