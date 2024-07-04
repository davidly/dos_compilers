str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COD 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:. -h cl /Ox /DDOSTIME /AS /Gs /Ze -I inc -I inc\\sys -L lib $str.c
ntvdm -u -r:. -e:lib=lib -h link $str,,$str,slibce

rm $str.COD 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -r:. -c -p $str
