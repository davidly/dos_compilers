scale$ = "cdefgab"
play "o0 x" + varptr$(scales$)
for i = 1 to 6
   play ">x" + varptr$(scale$)
next
play "o6 x" + varptr$(scale$)
for i = 1 to 6
   play "<x" + varptr$(scale$)
next
