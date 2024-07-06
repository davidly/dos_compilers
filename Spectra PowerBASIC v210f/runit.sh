# runs a PowerBASIC app, which only write to CGA memory for text output

str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvdm -r:. -u -c -p -m $str.EXE

