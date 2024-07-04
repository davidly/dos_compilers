str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.O 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -r:.. -e:include=c:\\include,path=c:\\bin ..\\bin\\cc -DAZTEC86 +F +A $str.c
rm ctmp* 2>/dev/null
ntvdm -u -r:.. -e:lib=c:\\lib ..\\bin\\ln $str c:\\lib\\m.lib c:\\lib\\c.lib

rm $str.O 2>/dev/null
