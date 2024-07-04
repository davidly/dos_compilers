str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.LOD 2>/dev/null
rm $str.LNK 2>/dev/null
rm $str.REF 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -r:. -u m2 comp $str.mod /S- /R- /T-
ntvdm -r:. -u m2 link $str
ntvdm -r:. -u -p m2 $str.lod

rm $str.LNK 2>/dev/null
rm $str.REF 2>/dev/null
rm $str.MAP 2>/dev/null
