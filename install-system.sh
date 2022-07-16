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

sudo rm -rf /etc/nixos
sudo cp -r "${DIR}" /etc/nixos
sudo nixos-rebuild switch --flake "/etc/nixos#${HOST}"
