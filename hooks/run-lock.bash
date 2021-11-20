#!/usr/bin/env bash
# Simple wrapper suitable for use with various locks like vlock/i3lock/swaylock
# that allows to block return until screen unlocked.
#
# Example: ./run-lock.bash swaylock

readonly events_dir="$(dirname $(readlink -f "$0"))/../events"
trigger() { "$events_dir/trigger.bash" "$@"; }

trigger locking
start_second=$SECONDS

"$@"
status=$?

LOCK_SECONDS=$(($SECONDS - $start_second)) trigger unlocked

exit $status
