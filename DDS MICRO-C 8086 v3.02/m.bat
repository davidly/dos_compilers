del %1.exe 2>nul
del %1.com 2>nul
ntvdm -r:. -e:path=. cc %1 H=C:\ -O -S


