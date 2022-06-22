#!/usr/bin/env bash

set -Eeuo pipefail

# dir of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

sudo cp -r "${DIR}" /etc/nixos
sudo nixos-rebuild switch --flake "/etc/nixos#${1}"
