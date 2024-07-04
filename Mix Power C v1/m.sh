str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.MIX 2>/dev/null

# this will crash because pc.exe trashes its own stack. but that's after it's done
ntvdm -r:. -u pc /c /ms /dpowerc /j /fi /q $str.c 1>/dev/null 2>/dev/null
ntvdm -r:. -u pcl $str

rm $str.MIX 2>/dev/null

ntvdm -u -r:. -c -p $str


