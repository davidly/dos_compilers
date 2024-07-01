loop = 1
while loop
   n$ = ""
   print
   input "Decimal number";d
   input "New base";b
   print : print d;" base 10 equals ";
   while d
      call convert
   wend
   print n$;" base ";b : print
   input "Convert another";r$
   c$ = left$(r$,1)
   if (c$ = "y" or c$ = "Y") _
      then loop = 1 _
      else loop = 0
wend
end
sub convert static
   shared d,b,n$
   r = d mod b
   d = d\b
   if r > 9 then goto letter _
   else _
      dgt$ = str$(r)
      ln = len(dgt$) - 1
      n$ = right$(dgt$,ln) + n$
      exit sub
   letter:
      dgt$ = chr$(65 + r -10)
      n$ = dgt$ + n$
end sub
