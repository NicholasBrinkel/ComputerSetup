#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: setup <command>

Commands:
    add <input>      Add a config from user input
    test            Run all tests
    help            Show this help message

EOF
}

case "${1:-}" in
    add)
        "${SCRIPT_DIR}/add.sh" "${2:-}"
        ;;
    test)
        "${SCRIPT_DIR}/tests/test-runner.sh"
        ;;
    help|--help|-h|"")
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
