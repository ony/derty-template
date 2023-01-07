#!/usr/bin/env bash
set -e  # -x
readonly prefix=$(realpath $(dirname "$0"))

list_options() {
    for options in "$prefix"/*; do
        echo "${options##$prefix/}"
    done
}

if option="$(list_options | rofi -dmenu)"; then
    exec "$prefix/$option"
fi
