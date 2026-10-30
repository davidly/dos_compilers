str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.O 2>/dev/null
rm $str.EXE 2>/dev/null

# -nDESMETC doesn't work in this version of c88
ntvdm -r:. -u c88 $str
echo
ntvdm -r:. -u bind $str other
echo

rm $str.O 2>/dev/null
