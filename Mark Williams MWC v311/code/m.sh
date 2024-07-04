str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.O 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -t -u -r:.. "-e:CCHEAD=@C:\lib\cc -f -DMWC" ..\\bin\\cc $str.c -lm

rm $str.O 2>/dev/null
