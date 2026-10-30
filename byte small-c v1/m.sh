str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAP 2>/dev/null
rm $str.MAC 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u cc86 $str.c
ntvdm -r:. -u masm $str.mac\;\;
ntvdm -r:. -u link /STACK:4096 $str,,$str,clib.lib,nul.def

rm $str.MAP 2>/dev/null
rm $str.MAC 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -d -c -p $str
