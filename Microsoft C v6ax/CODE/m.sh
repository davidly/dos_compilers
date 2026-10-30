str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -u -c -r:.. -e:path=c:\\bin\;c:\\binb,include=c:\\include,lib=c:\\lib ../BIN/CL.EXE /nologo /B1 C1L /B2 C2L /Owx /Fe$str.EXE $str.C
ntvdm -c -p $str

rm $str.OBJ 2>/dev/null
rm $str.MAP 2>/dev/null
