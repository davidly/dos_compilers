str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.SYM 2>/dev/null


ntvdm -u -r:. drc $str
ntvdm -u -r:. link86 $str

rm $str.OBJ 2>/dev/null
rm $str.SYM 2>/dev/null

echo

