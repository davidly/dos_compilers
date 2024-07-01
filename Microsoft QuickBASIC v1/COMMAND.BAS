bs = 10
power = 1
lg = 0
sign = 1
x = val(command$)
test1: if x > 0 then goto test2 _
   else _
      print "log(";command$;") not defined."
      print "Input must be greater than zero."
      end
test2: if x >= 1 then goto test3 _
   else _
      x = 1/x
      sign = -1
test3: if x < 100 then goto main _
   else _
      while x >= 100
         x = x/10
         lg = lg + 1
      wend
main:
   while abs(bs - 1) > .0000001
      if bs > x then goto newval _
      else _
         x = x/bs
         lg = lg + power
      newval:
         bs = sqr(bs)
         power = power/2
   wend
   print "log(";command$;") = ";lg*sign
