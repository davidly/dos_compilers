' *** STAT2_EX.BAS - STATIC statement programming example
'
INPUT "Name of file";F1$
INPUT "String to replace";Old$
INPUT "Replace with";Nw$
Rep = 0 : Num = 0
M = LEN(Old$)
OPEN F1$ FOR INPUT AS #1
CALL Extension
OPEN F2$ FOR OUTPUT AS #2
DO WHILE NOT EOF(1)
   LINE INPUT #1, Temp$
   CALL Search
   PRINT #2, Temp$
LOOP
CLOSE
PRINT "There were ";Rep;" substitutions in ";Num;" lines."
PRINT "Substitutions are in file ";F2$
END

SUB Extension STATIC
SHARED F1$,F2$
   Mark = INSTR(F1$,".")
   IF Mark = 0 THEN
      F2$ = F1$ + ".NEW"
   ELSE
      F2$ = LEFT$(F1$,Mark - 1) + ".NEW"
   END IF
END SUB

SUB Search STATIC
SHARED Temp$,Old$,Nw$,Rep,Num,M
STATIC R
   Mark = INSTR(Temp$,Old$)
   WHILE Mark
      Part1$ = LEFT$(Temp$,Mark - 1)
      Part2$ = MID$(Temp$,Mark + M)
      Temp$ = Part1$ + Nw$ + Part2$
      R = R + 1
      Mark = INSTR(Temp$,Old$)
   WEND
   IF Rep = R THEN
       EXIT SUB
   ELSE
       Rep = R
       Num = Num + 1
   END IF
END SUB
