#!/usr/bin/env sh

nix flake update --recreate-lock-file --commit-lock-file
