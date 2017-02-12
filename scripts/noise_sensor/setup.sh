#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
    echo "Must be root user"
    exit 1
fi

set -eu

_OLDPWD=$(pwd)
test -d "${BASH_SOURCE[0]%/*}" && cd "${BASH_SOURCE[0]%/*}"

SCRIPT_DIR="$(pwd)"

at_exit() {
    [ -n "${_OLDPWD-}" ] && cd "${_OLDPWD}"
}

trap at_exit EXIT
trap 'trap - EXIT; at_exit; exit 1' INT PIPE TERM

install_ffmpeg() {
    if which ffmpeg > /dev/null 2>&1; then
        return 0
    fi

    pushd /tmp > /dev/null 2>&1

    wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz
    tar xvf ffmpeg-release-64bit-static.tar.xz
    cp ./ffmpeg-release-64bit-static/ffmpeg /usr/local/bin/ffmpeg

    popd > /dev/null 2>&1
}

main() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y alsa-utils sox libsox-fmt-all portaudio19-dev python-dev alsa-utils python-pip
    install_ffmpeg
    # Optional for ffmpeg
    # apt-get install -y nscd

    # About soundmeter: https://github.com/shichao-an/soundmeter
    pip install soundmeter --allow-all-external --allow-unverified pyaudio
    soundmeter --help
}

main "$@"

exit
# EOF
