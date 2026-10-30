str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm  -u -r:. -c binb/pas1 $str,$str,$str,$str
ntvdm  -u -r:. -c binb/pas2
ntvdm  -u -r:. -c binb/pas3
ntvdm  -u -r:. -e:lib=lib -c binb/link $str djldos,$str,$str,,nul.def

rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm $str

