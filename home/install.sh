#!/usr/bin/env bash

set -Eeuo pipefail

# dir of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Build environment
mkdir -p "${HOME}/.config"
ln --symbolic --no-dereference --force "${DIR}" "${HOME}/.config"
nix-shell -p nix_2_4 --command \
  "nix build -o ${DIR}/result --experimental-features 'nix-command flakes' '${DIR}#$1'"

# Activate new environment
# shellcheck disable=SC1091
. "${DIR}/result/activate"
