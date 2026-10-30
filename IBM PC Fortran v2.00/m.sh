str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm  -u -r:. FOR1 $str.FOR,,,\;
ntvdm  -u -r:. FOR2
ntvdm  -u -r:. FOR3
ntvdm  -u -r:. link $str,,,partial.lib+dos20.lib
echo 

rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -c $str

