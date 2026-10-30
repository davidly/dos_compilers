str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COD 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:. cl /Ox /DDOSTIME /AS /Gs /Ze /Zp -I inc -I inc\\sys -L lib $str.c
ntvdm -u -r:. link $str,,$str,lib\\slibfp+lib\\slibc+lib\\em

rm $str.COD 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -d -c -p $str
