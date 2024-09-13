str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.EXE 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm  -u -r:. pas1 $str,$str,$str,$str;
ntvdm  -u -r:. pas2
ntvdm  -u -r:. link $str,$str,,pascal.lib

# Some binaries created by this compiler require being loaded above 64k or
# they crash with a stack error.
# Use ntvdm's -h switch to enable them to run, e.g.:
# ntvdm -h sieve.exe

rm CON.LST 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.COD 2>/dev/null
rm $str.LST 2>/dev/null
rm $str.MAP 2>/dev/null

ntvdm $str

