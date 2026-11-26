#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# The compiler and libs\* C runtime are from https://winworldpc.com/product/intel-ic-86-compiler/45
# The linker and u\* objects are from https://winworldpc.com/product/intel-iapx-86-88-family-utilities/42
# The directory is u, not util, to keep the link86 command tail < 127 characters.
# This links with the 8087 emulator (de8087.lib goes with the de8087 object;
# e8087.lib with it gives floating point results of 0); to require an 8087 use u\8087.lib instead of u\de8087.lib,u\de8087.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.LST
rm -f $str.MP1
rm -f $str.OBJ

ntvdm -u -r:. -e::include:=inc ic86 $str.C small "optimize(3)" mod86 "diagnostic(" 2 ")" define "(INTELC)"
ntvdm -u -r:. link86 "libs\\cstdoss.obj,$str.obj,c:\\libs\\cdoss.lib,u\\cel87.lib,u\\de8087.lib,u\\de8087,libs\\clib87.lib" TO $str.EXE exe

rm -f $str.LST
rm -f $str.MP1
rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
