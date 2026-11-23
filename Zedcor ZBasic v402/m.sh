#!/bin/sh
set -eu
CDPATH= cd -- "$(dirname -- "$0")"
exec ntvdm -r:. -u -c ZBASICCL.COM "$@" < /dev/null
