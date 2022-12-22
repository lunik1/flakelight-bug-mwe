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

push_to_cachix() {
  cachix push lunik1-nix-config -j "$(nproc)"
}

push_output() {
  nix --experimental-features 'nix-command flakes' build "$1" --json | jq -r '.[].outputs | to_entries[].value' | push_to_cachix
}

cd "${DIR}"

builtin cd "$(mktemp -d)"
if ! git diff-index --quiet HEAD --; then
  printf "WARNING: Uncomitted changes. Will not be pushed to cachix.\n"
fi

# Make sure repo is locked before pushing to public cache
git clone "${DIR}"

cd nix-config

if git-crypt lock; then
  :
else
  [ $? -ne 1 ] && exit 2
fi

# Push all inputs
nix --experimental-features 'nix-command flakes' flake archive --json |
  jq -r '.path,(.inputs|to_entries[].value.path)' |
  push_to_cachix

# Push all outputs
push_output ".#devShell.${SYSTEM}"

for i in systems/*.nix; do
  name=$(basename "${i}" .nix)
  push_output ".#nixosConfigurations.${name}.config.system.build.toplevel"
done

for i in home-configurations/*.nix; do
  name=$(basename "${i}" .nix)
  push_output ".#homeConfigurations.${name}"
done
