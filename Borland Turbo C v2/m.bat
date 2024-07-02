del %1.com 1>nul 2>nul
rem ntvdm -r:. -c -t tcc -lt -DDOSTIME -G -O -Z -mt -Iinclude -Llib -r -e%1.com %1.c
ntvdm -r:. -c -t tcc -ls -DDOSTIME -G -O -Z -ms -Iinclude -Llib -r -e%1.exe %1.c
ntvdm -r:. -c -p %1

