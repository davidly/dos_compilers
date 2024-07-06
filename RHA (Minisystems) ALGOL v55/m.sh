str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null

ntvdm -r:. -u algol $str
ntvdm -r:. -u -c -p arun $str.OBJ
