str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -u -r:. -h qcl /DDOSTIME /AS /Ot /Gs /c -I inc -I inc\\sys $str.c
ntvdm -u -r:. -h link $str,,$str,lib\\slibce,lib\\quicklib.obj

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -r:. -p $str
