#!/usr/bin/env bash

set -Eeuo pipefail

mkdir -p $HOME/.config
ln --symbolic --no-dereference --force $(pwd) $HOME/.config
nix-shell -p nixUnstable --command "nix build --experimental-features 'nix-command flakes' '.#$1'"
# nixos-rebuild switch --flake ".#$1"

. result/activate
