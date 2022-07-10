#!/usr/bin/env bash

set -Eeuo pipefail

# dir of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Build environment
mkdir -p "${HOME}/.config"
ln --symbolic --no-dereference --force "${DIR}" "${HOME}/.config"
nix-shell -p nixFlakes --command \
  "nix build -o ${DIR}/result --experimental-features 'nix-command flakes' '${DIR}#homeConfigurations.${1}'"

# remove old home manager profiles b/c of https://github.com/nix-community/home-manager/issues/2848
nix profile list | awk '$4 ~ "/nix/store/[0-9a-z]{32}-home-manager-path" { print $1 }' | xargs -r nix profile remove

# Activate new environment
# shellcheck disable=SC1091
. "${DIR}/result/activate"
