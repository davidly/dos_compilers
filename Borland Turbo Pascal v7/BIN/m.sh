str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvdm -r:.. -u TPC.EXE $str.PAS -\$S- -GD

rm $str.MAP 2>/dev/null

