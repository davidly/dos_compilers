ntvdm -r:. -c -t tcc -lm -f -DDOSTIME -G -O -ml -Iinclude -Llib -r -e%1.exe ..\qc_251\tests\%1.c
ntvdm %1


