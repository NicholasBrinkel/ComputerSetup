#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}"

mkdir -p ~/.config/nvim

cp -f "${CONFIG_DIR}/files/init.lua" ~/.config/nvim/init.lua

echo "Neovim config synced"