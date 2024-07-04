str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null

ntvdm -u -r:. for1 $str,$str,$str,$str
ntvdm -u -r:. pas2
ntvdm -u -r:. pas3

ntvdm -u -r:. -e:LIB=libs -f link $str,$str,$str,fortran.lib+cexec.lib

rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null

ntvdm -u -r:. $str
