str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.GRP 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -u -r:.. -c -e:path=c:\\binb\;c:\\binr COBOL $str,$str,$str,$str

ntvdm -u -h -c -r:.. -e:lib=c:\\lib LINK $str,,$str,,nul.def

rm $str.LST 2>/dev/null
rm $str.GRP 2>/dev/null
rm $str.MAP 2>/dev/null
rm $str.OBJ 2>/dev/null

ntvdm -u -c -m -r:.. -e:path=c:\\binb\;c:\\binr $str

