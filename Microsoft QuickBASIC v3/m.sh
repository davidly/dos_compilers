#!/bin/sh
set -eu
CDPATH= cd -- "$(dirname -- "$0")"
if [ "$#" -ne 1 ]; then
    echo 'Usage: m.sh name[.BAS]' >&2
    exit 1
fi
name=$(printf '%s' "$1" | LC_ALL=C tr '[:lower:]' '[:upper:]')
name=${name%.BAS}
case "$name" in
    ''|?????????*|*[!A-Z0-9_-]*)
        echo 'Expected a DOS source basename' >&2
        exit 1 ;;
esac
ntvdm -r:. -u -c QB.EXE "$name.BAS/O;" < /dev/null
ntvdm -r:. -u -c LINK.EXE "$name,,$name,,,;" < /dev/null
