rem $dynamic
r$ = "n"
while r$ = "n"
   input  "Range (low,high): ",low,high
   input "Total to choose: ",total
   m = high - low + 1
   redim range(m)
   for k = 1 to m
      range(k) = k + low - 1
   next
   randomize timer/10
   for i = 1 to total
      x = int(m*rnd + 1)
      print range(x),
      range(x) = range(m)
      m = m - 1
   next
   print
   erase range
   input "End program (y or n)";r$
wend
end
