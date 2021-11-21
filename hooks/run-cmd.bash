#!/usr/bin/env bash
# Example: ./run-cmd.bash sleep 5s

readonly events_dir="$(dirname $(readlink -f "$0"))/../events"
trigger() { "$events_dir/trigger.bash" "$@"; }

start_second=$SECONDS

"$@"
status=$?

CMD_ARGV0="$1" CMD_LINE="$*" CMD_SECONDS=$(($SECONDS - $start_second)) CMD_STATUS=$status \
    trigger cmd-complete > /dev/null 2>&1 < /dev/null &

exit $status
