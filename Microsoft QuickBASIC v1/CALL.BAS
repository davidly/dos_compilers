dim file$(2)
cmd$ = command$
call split(cmd$,file$())
call strip(file$(2))
call printout(file$())
end
sub split(c$,f$(1)) static
   mark = instr(c$," ")
   f$(1) = left$(c$,mark - 1)
   f$(2) = mid$(c$,mark + 1)
end sub
sub strip(f$) static
   first$ = left$(f$,1)
   while first$ = " "
      lng = len(f$)
      f$ = right$(f$,lng - 1)
      first$ = left$(f$,1)
   wend
end sub
sub printout(f$(1)) static
   for file% = 1 to 2
      open f$(file%) for input as #1
      while not eof(1)
         line input #1, temp$
         print temp$
      wend
      close #1
   next
end sub
