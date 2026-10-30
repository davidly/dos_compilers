str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:. -h -c -d COBOL $str,$str,$str/D\;
ntvdm -u -h -c -r:. LINK $str,$str,$str,C:\;

rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -u -r:. -c -m $str

