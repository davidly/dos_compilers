str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:.. -u ../ppc $str
ntvdm -r:.. -u -e:lib=.. ../sblink $str

rm $str.OBJ 2>/dev/null

#ntvdm -c -p $str

