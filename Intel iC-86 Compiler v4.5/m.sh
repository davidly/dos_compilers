str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.LST 2>/dev/null
rm $str.MP1 2>/dev/null
rm $str.OBJ 2>/dev/null
rm $str.EXE 2>/dev/null

# the compiler and libs\* c runtime is from https://winworldpc.com/product/intel-ic-86-compiler/45
# the linker and u\* objects are from https://winworldpc.com/product/intel-iapx-86-88-family-utilities/42
# use u not util for the directory name to keep the link86 command tail < 127 characters

ntvdm -u -r:. -e::include:=inc ic86 $str.c small optimize\(3\) mod86 diagnostic\( 2 \) define \(INTELC\)

# 8087 required
# ntvdm -r:. link86 libs\cstdoss.obj,c:\%1.obj,c:\libs\cdoss.lib,u\cel87.lib,u\8087.lib,libs\clib87.lib TO %1.exe exe

# 8087 emulator
ntvdm -u -r:. link86 libs\\cstdoss.obj,$str.obj,c:\\libs\\cdoss.lib,u\\cel87.lib,u\\e8087.lib,u\\de8087,libs\\clib87.lib TO $str.EXE exe

rm $str.LST 2>/dev/null
rm $str.MP1 2>/dev/null
rm $str.OBJ 2>/dev/null
