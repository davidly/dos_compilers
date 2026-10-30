str=$(tr '[a-z]' '[A-Z]' <<< $1)

# build using a project file
ntvdm -u -r:. -e:PATH=c:\\SYS SYS\\TSC /m $str.pr

rm TERMINAL.OBJ 2>/dev/null
rm ASCII.OBJ 2>/dev/null
rm INOUT.OBJ 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
