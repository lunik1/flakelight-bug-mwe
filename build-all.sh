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

tobuild=()

tobuild+=("${DIR}#devShells.${SYSTEM}.default")

for i in "${DIR}"/nix/nixosConfigurations/*.nix; do
  name=$(basename "${i}" .nix)

  if [[ ${name} == "default" ]]; then
    continue
  fi
  tobuild+=("${DIR}#nixosConfigurations.${name}.config.system.build.toplevel")
done

for i in "${DIR}"/nix/homeConfigurations/*.nix; do
  name=$(basename "${name}" .nix)

  if [[ ${i} == "default" ]]; then
    continue
  fi
  tobuild+=("${DIR}#homeConfigurations.${name}.activationPackage")
done

nix --experimental-features 'nix-command flakes' build "${tobuild[@]}"
