str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.LST 2>/dev/null
rm $str.MP1 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:. PLM86 $str.PLM OPTIMIZE\(3\)

ntvdm -u -r:. ASM86 DOSLIBS.ASM

ntvdm -u -r:. LINK86 $str.OBJ,DOSLIBS.OBJ,PLM86.LIB TO $str.EXE EXE

rm $str.LST 2>/dev/null
rm $str.MP1 2>/dev/null
rm $str.OBJ 2>/dev/null
