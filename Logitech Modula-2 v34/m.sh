str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -f -r:. -e:m2sym=m2lib\\sym m2exe\\M2C.EXE $str

# the modula 2 linker fails
# ntvdm -u -r:. -e:m2lib=m2lib\\lib m2exe\\m2l $str/o/p

# the qbx linker works fine
ntvdm -u -h -f -r:. -e:lib=m2lib\\lib link $str,,,m2lib m2rts.lib;

rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm $str
