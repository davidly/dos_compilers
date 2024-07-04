str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.COM 2>/dev/null
rm $str.MIX 2>/dev/null

ntvdm -r:. -u cc $str.c
ntvdm -r:. -u linker $str

rm $str.MIX 2>/dev/null

ntvdm -r:. -u -c $str
