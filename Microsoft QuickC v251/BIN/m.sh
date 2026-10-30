str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -u -r:. -f -e:include=..\\include,lib=..\\lib qcl /Gs /Ox /DDOSTIME $str.c 

rm $str.OBJ 2>/dev/null

ntvdm -u -r:. -c -p $str
