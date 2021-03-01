#!/usr/bin/env sh

sudo rm -rf /etc/nixos
sudo ln --symbolic --no-dereference $(pwd) /etc/nixos
sudo nixos-rebuild switch --flake '/etc/nixos#foureightynine'
