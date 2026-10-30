str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

# for1 and for2 have bugs that require -h so ntvdm loads the binary >= 64k and < 640k

ntvdm  -h -u -r:. FOR1 $str.FOR,,,\;
ntvdm  -h -u -r:. FOR2
ntvdm  -u -r:. link $str,,,\;
echo 

rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -c $str

