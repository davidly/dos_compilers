str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.O 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u c88 $str
echo
ntvdm -r:. -u bind $str
echo

rm $str.O 2>/dev/null
