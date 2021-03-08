#!/usr/bin/env sh

set -Eeuo pipefail

sudo rm -rf /etc/nixos
sudo ln --symbolic --no-dereference $(pwd) /etc/nixos
sudo nixos-rebuild switch --flake '/etc/nixos#foureightynine'
