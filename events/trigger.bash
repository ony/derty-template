#!/usr/bin/env bash

readonly events_maxdepth=16

set -ex

[[ -z "$EVENTS_DIR" ]] && export EVENTS_DIR=$(dirname "$(readlink -f "$0")")

if [[ -z "$EVENTS_LVL" ]]; then
    EVENTS_LVL=1
elif [[ "$EVENTS_LVL" -ge $events_maxdepth ]]; then
    echo "Too nested chain of events $EVENTS_LVL (exceeding $events_maxdepth)" >&2
    exit 2
else
    let EVENTS_LVL+=1
fi
export EVENTS_LVL

script_run=()
runparts_args=()
case "$1" in
dryrun-*)
    export EVENT="${1#dryrun-}"
    runparts_args+=(--test --verbose)
    script_run=(echo)
    shift
    ;;
?*)
    export EVENT="$1"
    shift
    ;;
*)
    echo "Missing mandatory argument event" >&2
    exit 1
    ;;
esac

for arg in "$@"; do
    runparts_args+=(--arg="$arg")
done

for script in "$EVENTS_DIR"/"$EVENT"{,.zsh,.bash,.sh}; do
    if [[ -x "$script" ]]; then
        exec "${script_run[@]}" "$script" "$@"
    fi
done

exec run-parts --regex='.*' "${runparts_args[@]}" "$EVENTS_DIR/${EVENT}.d"
