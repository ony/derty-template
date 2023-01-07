#!/usr/bin/env bash
set -e  # -x
cd "$(dirname "$0")"
if option="$(fzf)"; then
    exec "./$option"
fi
