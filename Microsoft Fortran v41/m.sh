str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -u -r:. -e:include=include,init=bin,path=bin,lib=lib,tmp=tmp BIN\\fl /FPc /Ox $str.for

rm $str.OBJ 2>/dev/null

ntvdm -p -u -r:. $str
