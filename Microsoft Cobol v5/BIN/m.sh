str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.GRP 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -u -r:.. -c -d cobol $str,$str,$str,$str

# link.exe that ships with cobol requires 286+ protected mode. use msvc v5's linker instead
# qbx's link.exe executes code in a segment it just freed
ntvdm -u -h -c -r:.. -e:lib=c:\\lib mcv5link $str,,$str,,nul.def

rm $str.OBJ 2>/dev/null
rm $str.GRP 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm -u -c -m -p $str
