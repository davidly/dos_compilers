str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.ERR 2>/dev/null
rm $str.R86 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u mt86 $str
ntvdm -r:. -u linkmt $str paslib.r86 fpreals.r86

rm $str.ERR 2>/dev/null
rm $str.R86 2>/dev/null

ntvdm -c -p $str

