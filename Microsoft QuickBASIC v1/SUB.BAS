input "File to be searched";f$
input "Pattern to search for";p$
open f$ for input as #1
while not eof(1)
   line input #1, test$
   call basgrep(test$,p$)
wend 
end
sub basgrep(test$,p$)  static
   static num
   num = num + 1
   x = instr(test$,p$)
   if x = 0 then exit sub _
   else _
      print  "Line #";num;": ";test$
end sub
