str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAP 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:. -c tpc $str.pas  /\$S- /GD

rm $str.MAP 2>/dev/null
