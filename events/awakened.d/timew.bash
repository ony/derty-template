#!/usr/bin/env bash
# Pause TimeWarrior activity if was idle for prolonged period of time

readonly ignore_idle_seconds=5

set -ex
[[ "$IDLE_SECONDS" -le $ignore_idle_seconds ]] && exit

if timew stop "${IDLE_SECONDS}sec" ago :quiet; then
    # You may want to skip continue in some/all cases
    timew continue :quiet
fi
