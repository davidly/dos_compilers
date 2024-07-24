str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.GRP 2>/dev/null

ntvdm -u -r:. -h -c COBOL $str,$str,$str,$str

ntvdm -u -h -c -r:. LINK $str,,$str,lcobol.lib,nul.def

rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.GRP 2>/dev/null

ntvdm -u -c $str
