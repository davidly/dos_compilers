str=${1^^}

rm $str.SYM 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u cb86 $str
ntvdm -r:. -u link86 $str = $str

rm $str.SYM 2>/dev/null
rm $str.OBJ 2>/dev/null
