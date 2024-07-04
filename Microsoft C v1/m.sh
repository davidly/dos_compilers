str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u mc1 $str
ntvdm -r:. -u mc2 $str
ntvdm -r:. -u link $str + c + gettm,, $str.map, mc

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
