#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# muLISP loads COMMON.LSP and STRUCTUR.LSP ahead of the benchmark: they're combined into
# LISPRUN.LSP without their ^Z end-of-file characters and (RDS) calls.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f LISPRUN.LSP
cat COMMON.LSP STRUCTUR.LSP $str.LSP | tr '\032' ' ' | sed -e '/(RDS)/d' > LISPRUN.LSP

ntvdm -u -r:. -c -p mulisp LISPRUN.LSP
rm -f LISPRUN.LSP
