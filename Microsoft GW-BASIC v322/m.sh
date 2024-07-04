str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvdm -r:. -u -c -p gwbasic $str.bas
