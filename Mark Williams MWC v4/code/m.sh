str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:.. "-e:CCHEAD=@C:\lib\cc -f -DMWC -VOPT" ..\\bin\\cc $str.c -lm

rm $str.OBJ 2>/dev/null
