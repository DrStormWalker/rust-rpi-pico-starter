#!/bin/sh

DIRECTORY_ROOT="$(dirname $0)"
DIRECTORY="$DIRECTORY_ROOT/.rpi-mount"

mkdir -p "$DIRECTORY"

sudo mount /dev/disk/by-label/RPI-RP2 "$DIRECTORY" -o "uid=$UID,gid=users"
