str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:. -c bascom $str.bas,,$str.lst,
ntvdm -u -r:. -c link $str,,$str,.\\,nul

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null
