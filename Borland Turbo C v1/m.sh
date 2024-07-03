str=${1^^}

rm $str.OBJ 2>/dev/null
rm $str.COM 2>/dev/null

ntvdm -u tcc -f -mm -G -O -DDOSTIME -Z -N- $str.c
ntvdm -c -p $str

rm $str.OBJ 2>/dev/null


