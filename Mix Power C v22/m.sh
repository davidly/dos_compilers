str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.MIX 2>/dev/null

ntvdm -u -r:. pc -f /c /ms /dpowerc /dDOSTIME /j /fi /q $str.c 1>/dev/null 2>/dev/null
ntvdm -u -r:. pcl $str

rm $str.MIX 2>/dev/null

ntvdm -u -r:. -c -p $str
