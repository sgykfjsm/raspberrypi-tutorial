#!/usr/bin/env bash

set -eu

BKUP_DIR="${HOME}/backup"

mkdir -pv "${BKUP_DIR}"

cp -pv /etc/modules "${BKUP_DIR}/modules.$(date '+%Y%m%d%H%M%S')"

sudo apt-get update
sudo apt-get install -y i2c-tools python-smbus

if ! grep -q --word-regexp "i2c-bcm2708"; then
    echo "i2c-bcm2708" | sudo tee -a /etc/modules
fi

if ! grep -q --word-regexp "i2c-dev"; then
    echo "i2c-dev" | sudo tee -a /etc/modules
fi

echo
echo ">>>> Please reboot hosts to activate i2c modules"
echo 'After rebooting, do `lsmod | grep i2c`'
echo "You should see below"
echo
echo "i2c_dev                 5859  0"
echo "i2c_bcm2708             4834  0"
echo
