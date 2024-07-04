str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.CRF 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null

ntvdm -r:. -u -h bin/masm /Zi /Zd /z /L $str,,,\;
ntvdm -r:. -u -h bin/link /CP:1 $str,,$str,,nul.def

rm $str.CRF 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.LST 2>/dev/null

ntvdm -u $str
