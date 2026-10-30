str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null

ntvdm -u -r:. -e:MCDIR=. cc $str m=S -q
echo

