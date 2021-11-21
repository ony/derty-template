#!/usr/bin/env bash

readonly ignore_cmd_seconds=3

[[ "$CMD_SECONDS" -le $ignore_cmd_seconds ]] && exit

args=(--app-name="$CMD_ARGV0")
if [[ "$CMD_STATUS" == "0" ]]; then
    summary="$CMD_ARGV0 succeeded in ${CMD_SECONDS}s"
else
    summary="$CMD_ARGV0 failed($CMD_STATUS) in ${CMD_SECONDS}s"
    args+=(--urgency=critical)
fi

notify-send "${args[@]}" "$summary" "Command: $CMD_LINE"
