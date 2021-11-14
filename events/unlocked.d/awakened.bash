#!/usr/bin/env bash
export IDLE_SECONDS=$LOCK_SECONDS
exec "$(dirname "$0")"/../trigger.bash awakened "$@"
