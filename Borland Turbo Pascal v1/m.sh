#!/bin/sh
set -eu
CDPATH= cd -- "$(dirname -- "$0")"
exec ntvdm -c -r:. -u TURBOCL.COM "$@" < /dev/null
