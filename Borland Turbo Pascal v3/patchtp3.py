#!/usr/bin/env python3
# Turbo Pascal v3.02a generates apps that try to determine the speed of the CPU at startup.
# On emulators this can cause many instructions to be executed and throws off benchmark numbers.
# This replaces the call to do the speed check with NOP instructions. Same as patchtp3.cxx.
# usage: patchtp3.py app.com

import sys

if len(sys.argv) != 2:
    sys.exit("usage: patchtp3.py app.com")

with open(sys.argv[1], "r+b") as f:
    data = f.read()
    if len(data) < 0x8aa:
        sys.exit("file seems too small")
    if data[7:37] != b"Copyright (C) 1985 BORLAND Inc":
        sys.exit("file doesn't appear to be a Turbo Pascal v3.02a generated app")
    if data[0x8a7:0x8aa] == b"\x90\x90\x90":
        print("file is apparently already patched")
        sys.exit(0)
    if data[0x8a7:0x8aa] != b"\xe8\xe8\xf7":
        sys.exit("file doesn't have call 0f7e8h at offset 08a7h")
    f.seek(0x8a7)
    f.write(b"\x90\x90\x90")

print("file %s successfully patched to remove startup cpu timing code" % sys.argv[1])
