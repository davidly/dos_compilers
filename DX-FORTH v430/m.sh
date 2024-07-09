str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null

ntvdm -r:. -u -c -p forth - include $str.f $str bye
