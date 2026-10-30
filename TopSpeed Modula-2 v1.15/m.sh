str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvdm -u -r:. m2 /c $str
ntvdm -u -r:. m2 /l $str

rm OBJ/$str.OBJ 2>/dev/null

