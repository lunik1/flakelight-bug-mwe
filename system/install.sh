#!/usr/bin/env sh

set -Eeuo pipefail

sudo ln --symbolic --no-dereference --force $(pwd) /etc/nixos
sudo nixos-rebuild switch --flake '/etc/nixos#foureightynine'
