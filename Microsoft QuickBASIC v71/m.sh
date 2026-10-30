str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -u -r:. -c bc $str.bas $str.obj $str.lst /O
ntvdm -u -r:. -c link $str,,$str,,,;

rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -u -r:. -c $str


