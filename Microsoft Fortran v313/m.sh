str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null

ntvdm -u -r:. FOR1 $str,$str,$str,$str
ntvdm -u -r:. PAS2
ntvdm -u -r:. PAS3

ntvdm -u -r:. -f LINK $str,$str,$str,FORTRAN.LEM

rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
