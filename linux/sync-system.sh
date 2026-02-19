#!/usr/bin/env bash
#
# sync-system.sh — Copy non-symlinked system config files back into the repo.
#
# Run this after editing system configs so they can be committed.
# Requires sudo for files owned by root.

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_SYS="$DIR/system"

sync_file() {
    local src="$1" dst="$REPO_SYS/$2"
    if [[ ! -f "$src" ]]; then
        echo "SKIP  $src (not found)"
        return
    fi
    if [[ ! -r "$src" ]]; then
        echo "SKIP  $src (not readable — run with sudo if you want to sync this)"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "OK    $src → $dst"
}

sync_file /etc/greetd/config.toml                              greetd/config.toml
sync_file /etc/systemd/system/dhcpcd.service.d/override.conf  systemd/dhcpcd-override.conf
sync_file "/etc/sudoers.d/$(id -un)"                          sudoers.example
