str=$(tr '[a-z]' '[A-Z]' <<< $1)


rem -h flag is required for pas2 and generated apps so the top of ram is on a 64k-1 boundary
rem due to bugs in the apps that try to copy 64k-1 bytes of ram and wrap.

rm $str.EXE 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -r:. -u -c pas1 $str,$str,$str,$str
rm CON.LST 2>/dev/null
ntvdm -r:. -u -h -c pas2
ntvdm -r:. -u -c link $str djldos,,,,

rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -h -p $str

