str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

# note: to use ntvdm, libraries must be rebuilt for the 8086 (not 80186) using comp86em.sh

ntvdm -c -r:. -u OC $str.MOD 8086
ntvdm -c -r:. -u LINK $str+LIO+SYS \;

rm $str.OBJ 2>/dev/null

