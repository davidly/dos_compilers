str=$(tr '[a-z]' '[A-Z]' <<< $1)

rm $str.O 2>/dev/null
rm $str.EXE 2>/dev/null

ntvdm -r:. -u pcc $str
echo
ntvdm -r:. -u pccl $str
echo

rm $str.O 2>/dev/null
