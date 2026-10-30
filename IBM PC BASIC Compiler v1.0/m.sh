str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm  -u -r:. BASCOM $str.BAS,,$str.LST,
ntvdm  -u -r:. LINK $str,,,\;
echo 

rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -c $str

