str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null

ntvdm -u -r:. -e:path=. cc $str H=C:\ -O -S
echo

