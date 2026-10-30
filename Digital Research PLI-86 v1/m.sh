str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.SYM 2>/dev/null

ntvdm -r:. -u pli.exe $str \$L \$I
ntvdm -r:. -u link86 $str,plilib.l86,pcdio.obj,div2.obj,fdiv2.obj

rm $str.OBJ 2>/dev/null
rm $str.SYM 2>/dev/null

ntvdm -r:. -u -c -p $str
