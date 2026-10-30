str=$(tr '[a-z]' '[A-Z]' <<< $1)

ntvdm -r:. -u F83.COM <$str.F
