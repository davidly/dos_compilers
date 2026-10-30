str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -r:. -u -c qcl /DDOSTIME /I..\\include /AS /Ox /Gs /c $str.c
ntvdm -r:. -u -c link $str,,$str,..\\lib\\slibce+..\\lib\\em

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -r:. -u -c -p $str
