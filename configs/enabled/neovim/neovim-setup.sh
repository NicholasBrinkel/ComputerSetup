#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}"

mkdir -p ~/.config/nvim

for file in "${CONFIG_DIR}"/files/*.lua; do
    [[ -f "$file" ]] || continue
    filename=$(basename "$file")
    cp -f "$file" ~/.config/nvim/"$filename"
done

echo "Neovim config synced"