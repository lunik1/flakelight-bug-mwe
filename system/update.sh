#!/usr/bin/env sh

set -Eeuo pipefail

nix flake update --recreate-lock-file --commit-lock-file
