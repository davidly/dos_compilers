str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.JRL 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.SYM 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u janus $str /L /O1
ntvdm -r:. -u optimize $str
ntvdm -r:. -u jlink $str /O1

rm $str.JRL 2>/dev/null
rm $str.PRN 2>/dev/null
rm $str.SYM 2>/dev/null
