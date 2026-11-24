#!/bin/sh
# Build and time the benchmarks for every compiler; see perfrun.py for details.
# usage: ./perfrun.sh [-j jobs] [-t seconds] [-k] [name-filter ...]
exec python3 "$(dirname "$0")/perfrun.py" "$@"
