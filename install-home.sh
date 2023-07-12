#!/usr/bin/env bash

set -Eeuo pipefail

# dir of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

if [[ ${1+x} ]]; then
  HOST=${1}
else
  if [[ ${HOSTNAME+x} ]]; then
    printf "Hostname not supplied, using '%s'\n" "${HOSTNAME}"
    HOST=${HOSTNAME}
  else
    printf "Failed to determine hostname, aborting\n"
    exit 1
  fi
fi

# Build environment
mkdir -p "${HOME}/.config"
ln --symbolic --no-dereference --force "${DIR}" "${HOME}/.config"
nix --experimental-features 'nix-command flakes' build -o "${DIR}/result" "${DIR}#homeConfigurations.${HOST}"

# remove old home manager profiles b/c of https://github.com/nix-community/home-manager/issues/2848
nix --experimental-features nix-command profile list | awk '$4 ~ "/nix/store/[0-9a-z]{32}-home-manager-path" { print $1 }' | xargs -r nix --experimental-features nix-command profile remove

# mimeapps.list has a bad habit of being modified and getting in the way
rm -f "${HOME}/.config/mimeapps.list"

# Activate new environment
# shellcheck disable=SC1091
. "${DIR}/result/activate"
