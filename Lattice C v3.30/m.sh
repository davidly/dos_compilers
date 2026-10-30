str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u -e:INCLUDE=. LC -ms -v -g $str.C
ntvdm -r:. -u LINK S\\C.OBJ $str.OBJ,$str,,s\\LC.LIB+LAPI.LIB

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
