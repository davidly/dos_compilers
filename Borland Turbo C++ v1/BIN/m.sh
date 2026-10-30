str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:.. tcc  -DDOSTIME -ms -Z -O -G -I..\\include -L..\\lib -e$str.EXE $str.C

rm $str.OBJ 2>/dev/null

