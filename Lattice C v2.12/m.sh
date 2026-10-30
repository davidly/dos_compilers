str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u LC -ms $str.C
ntvdm -r:. -u LINK CS.OBJ $str.OBJ,$str,,LCS.LIB

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
