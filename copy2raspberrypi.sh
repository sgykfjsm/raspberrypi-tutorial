#!/usr/bin/env bash

set -eux

_OLDPWD=$(pwd)
test -d "${BASH_SOURCE[0]%/*}" && cd "${BASH_SOURCE[0]%/*}"

SCRIPT_DIR="$(pwd)"

at_exit() {
    [ -n "${_OLDPWD-}" ] && cd "${_OLDPWD}"
}

trap at_exit EXIT
trap 'trap - EXIT; at_exit; exit 1' INT PIPE TERM

HOSTNAME="raspberrypi.local"
USER="pi"
PORT="22"
DIST_DIR="/home/${USER}"
IDENTITYFILE="~/.ssh/id_rsa_rsap"

scp -P ${PORT} -i "${IDENTITYFILE}" -r "${SCRIPT_DIR}/scripts" "${USER}@${HOSTNAME}:${DIST_DIR}/"
