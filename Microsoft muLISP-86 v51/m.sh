str=$(tr '[a-z]' '[A-Z]' <<< $1)

cat COMMON.LSP STRUCTUR.LSP $str.LSP >FOO.LSP

# remove ^z end of file characters found in common.lsp and structur.lsp
tr '\32' ' ' <FOO.LSP >BAR.LSP

# remove (RDS) twice from the file
sed -e '/(RDS)/d' BAR.LSP >BAZ.LSP

ntvdm -r:. -u -p -c mulisp BAZ.LSP

rm FOO.LSP 2>/dev/null
rm BAR.LSP 2>/dev/null
rm BAZ.LSP 2>/dev/null
