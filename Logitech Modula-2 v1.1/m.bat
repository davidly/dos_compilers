@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.LOD 2>nul
del %1.LNK 2>nul
del %1.REF 2>nul
del %1.MAP 2>nul

ntvdm -r:. m2 comp %1.MOD /S- /R- /T-
ntvdm -r:. m2 link %1

del %1.LNK 2>nul
del %1.REF 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p m2 %1.LOD
