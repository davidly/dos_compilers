screen 2 
loop = 1
while loop
   gosub split
   check = min
   while check = min
      a$ = inkey$
      if len(a$) <> 0 then end _
      else _
         gosub split
         gosub face
   wend
   cls
wend
split: rem ** This splits time$ into numeric values
   let t$ = time$
   hr$ = left$(t$,2) : min$ = mid$(t$,4,2)
   hr = val(hr$) : min = val(min$)
return
face: rem ** This draws clock face
   circle (320,100),175
   little = 360 -(30 * hr + min/2)
   draw "ta=" + varptr$(little) + "nu40"
   big = 360 -(6*min)
   draw "ta=" + varptr$(big) + "nu70"
   locate 2,37 : print time$
   locate 23,25 : print "Press any key to return to system"
return
