#!/usr/bin/env sh

set -Eeuo pipefail

# dir of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

sudo ln --symbolic --no-dereference --force ${DIR} /etc/nixos
sudo nixos-rebuild switch --flake "/etc/nixos#${1}"
