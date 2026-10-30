str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.INT 2>/dev/null
rm $str.LST 2>/dev/null

ntvdm -u -r:. -h -c -d COBOL $str,$str,$str/D\;

rm $str.LST 2>/dev/null

ntvdm -u -r:. -c RUNCOB $str
echo 
