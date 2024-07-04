str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -r:. -u -c pas1 $str,$str,$str,$str
ntvdm -r:. -u -c pas2
ntvdm -r:. -u -c pas3
ntvdm -r:. -u -c link $str djldos,,,,

rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -r:. -u -p $str
