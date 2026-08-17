#!/usr/bin/env bash
set -euo pipefail

KEY_DIR="$(dirname "$0")/keys"
KEY_FILE="$KEY_DIR/id_ansible"

mkdir -p "$KEY_DIR"

if [[ -f "$KEY_FILE" ]]; then
    echo "Clé SSH déjà présente: $KEY_FILE"
else
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "ansible-lab"
    echo "Clé SSH générée: $KEY_FILE"
fi

chmod 600 "$KEY_FILE"
chmod 644 "$KEY_FILE.pub"
