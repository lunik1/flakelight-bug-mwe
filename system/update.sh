#!/usr/bin/env sh

set -Eeuo pipefail

# dir of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

nix flake update ${DIR} --recreate-lock-file --commit-lock-file
