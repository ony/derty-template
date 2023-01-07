#!/usr/bin/env bash

die() {
    echo "$*" >&2
    exit 2
}

have_cmd() {
    command -v "$1" > /dev/null
}

detect_env() {
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        echo wayland
    elif [[ -n "$DISPLAY" ]]; then
        echo x11-clipboard
    else
        die "Can't detect environment for clipboard"
    fi
}

case "$0" in
*-markdown.bash)
    if ! have_cmd markdownify; then
        markdownify() {
            nix run nixpkgs\#python3Packages.markdownify -- "$@"
        }
    fi
    from_html() { markdownify; }
    ;;
*-xwiki.bash)
    from_html() { pandoc -r html -w xwiki; }
    ;;
*) die "Unsupported alias $0" ;;
esac

set -e # -x

mode=
if [[ -n "$WAYLAND_DISPLAY" ]]; then
    mode=wayland
elif [[ -n "$DISPLAY" ]]; then
    mode=x11
else
    die "Unknown environment for clipboard"
fi

case "${CLIPBOARD_ENV:-$(detect_env)}" in
wayland)
    if have_cmd wl-paste && have_cmd wl-copy; then
        clip_info() { wl-paste -l; }
        clip_out() { wl-paste -t "$1"; }
        clip_in() { wl-copy; }
    else
        die "Missing supporte for Wayland. Known tools wl-paste/wl-copy"
    fi
    ;;

x11-clipboard)
    if have_cmd xclip; then
        clip_info() { xclip -selection clipboard -o -t TARGETS; }
        clip_out() { xclip -selection clipboard -o -t "$1"; }
        clip_in() { xclip -selection clipboard; }
    else
        die "Missing supporte for ${CLIPBOARD_ENV}. Known tools xclip"
    fi
    ;;
esac

mimes="$(clip_info)"
if grep -q "^text/html$" <<< "$mimes"; then
    clip_out text/html | from_html | clip_in
elif grep -q "^image/png$" <<< "$mimes"; then
    echo "TODO: upload image and form markdown pointing to it" >&2
    # url="$(clip_out image/png | upload_somewhere)"
    # clip_in <<< "![image]($url)"
fi
