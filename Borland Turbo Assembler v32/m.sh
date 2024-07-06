str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -r:. -u -c tasm $str.asm -la
ntvdm -r:. -u -c tlink $str.obj

rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
