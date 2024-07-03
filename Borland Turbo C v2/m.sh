str=${1^^}

rm $str.OBJ 2>/dev/null
rm $str.COM 2>/dev/null

ntvdm -u -r:. -c -t tcc -ls -DDOSTIME -G -O -Z -ms -Iinclude -Llib -r -e$str.EXE $str.C
ntvdm -c -p $str

rm $str.OBJ 2>/dev/null


