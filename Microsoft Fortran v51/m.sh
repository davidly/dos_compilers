str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -u -r:. -e:include=include,init=bin,path=bin\;binb,lib=lib,tmp=tmp binb\\fl /FPc /Ot $str.for /link llibce.lib /NOE

rm $str.OBJ 2>/dev/null

ntvdm -u -r:. $str
