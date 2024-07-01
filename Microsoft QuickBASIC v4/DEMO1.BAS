5 DEFINT A-Z
10 ' BASICA/GWBASIC Version of Sound Effects Demo Program
15 '
20 ' Sound effect menu
25 Q = 2
30 WHILE Q >= 1
35     CLS
40     PRINT "Sound effects": PRINT
45     COLOR 15, 0: PRINT "  B"; : COLOR 7, 0: PRINT "ouncing"
50     COLOR 15, 0: PRINT "  F"; : COLOR 7, 0: PRINT "alling"
55     COLOR 15, 0: PRINT "  K"; : COLOR 7, 0: PRINT "laxon"
60     COLOR 15, 0: PRINT "  S"; : COLOR 7, 0: PRINT "iren"
65     COLOR 15, 0: PRINT "  Q"; : COLOR 7, 0: PRINT "uit"
70     PRINT : PRINT "Select: ";
75     Q$ = INPUT$(1): Q = INSTR("BFKSQbfksq", Q$) ' Get valid key
80     IF Q = 0 GOTO 75
85     CLS     ' Take action based on key
90     ON Q GOSUB 100, 200, 300, 400, 500, 100, 200, 300, 400, 500
95 WEND
100 ' Bounce - loop two sounds down at decreasing time intervals
105    HTONE = 32767: LTONE = 246
110    PRINT "Bouncing . . ."
115    FOR COUNT = 60 TO 1 STEP -2
120       SOUND LTONE - COUNT / 2, COUNT / 20
125       SOUND HTONE, COUNT / 15
130    NEXT COUNT
135 RETURN
200 ' Fall - loop down from a high sound to a low sound
205    HTONE = 2000: LTONE = 550: DELAY = 500
210    PRINT "Falling . . ."
215    FOR COUNT = HTONE TO LTONE STEP -10
220       SOUND COUNT, DELAY / COUNT
225    NEXT COUNT
230 RETURN
300 ' Klaxon - alternate two sounds until a key is pressed
305    HTONE = 987: LTONE = 329
310    PRINT "Oscillating . . ."
315    PRINT " . . . press any key to end."
320    WHILE INKEY$ = ""
325       SOUND HTONE, 5: SOUND LTONE, 5
330    WEND
335 RETURN
400 ' Siren - loop a sound from low to high to low
405    HTONE = 780: RANGE = 650
410    PRINT "Wailing . . ."
415    PRINT " . . . press any key to end."
420    WHILE INKEY$ = ""
425       FOR COUNT = RANGE TO -RANGE STEP -4
430          SOUND HTONE - ABS(COUNT), .3
435          COUNT = COUNT - 2 / RANGE
440       NEXT COUNT
445    WEND
450 RETURN
500 ' Quit
505 END

