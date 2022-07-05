#!/usr/bin/env bash

set -Eeuo pipefail

# dir of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

SYSTEM=$(nix-info | awk -v RS=, '{if ($1 == "system:") {gsub(/"/, "", $2); print $2;}}')

basename() {
  dir=${1%"${1##*[!/]}"}
  dir=${dir##*/}

  if [[ -v 2 ]]; then
    dir=${dir%"$2"}
  fi

  printf '%s\n' "${dir:-/}"
}

nix build "${DIR}#devShell.${SYSTEM}"

for i in "${DIR}"/systems/*.nix; do
  name=$(basename "${i}" .nix)
  nix build "${DIR}#nixosConfigurations.${name}.config.system.build.toplevel"
done

for i in "${DIR}"/home-configurations/*.nix; do
  name=$(basename "${i}" .nix)
  nix build "${DIR}#homeConfigurations.${name}"
done
