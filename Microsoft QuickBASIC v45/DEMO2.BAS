DEFINT A-Z
' QB2 Version of Sound Effects Demo Program
'   (works under most other BASIC compilers)

' Sound effects menu
WHILE Q$ <> "Q"
    CLS
    PRINT "Sound effects": PRINT
    COLOR 15, 0: PRINT "  B"; : COLOR 7, 0: PRINT "ouncing"
    COLOR 15, 0: PRINT "  F"; : COLOR 7, 0: PRINT "alling"
    COLOR 15, 0: PRINT "  K"; : COLOR 7, 0: PRINT "laxon"
    COLOR 15, 0: PRINT "  S"; : COLOR 7, 0: PRINT "iren"
    COLOR 15, 0: PRINT "  Q"; : COLOR 7, 0: PRINT "uit"
    PRINT : PRINT "Select: ";

    ' Get valid key
    Q$ = " "
    WHILE INSTR("BFKSQbfksq", Q$) = 0
        Q$ = INPUT$(1)
    WEND

    ' Take action based on key
    CLS
    IF Q$ = "B" OR Q$ = "b" THEN
        PRINT "Bouncing . . . "
        CALL Bounce(32767, 246)
    ELSEIF Q$ = "F" OR Q$ = "f" THEN
        PRINT "Falling . . . "
        CALL Fall(2000, 550, 500)
    ELSEIF Q$ = "S" OR Q$ = "s" THEN
        PRINT "Wailing . . ."
        PRINT " . . . press any key to end."
        CALL Siren(780, 650)
    ELSEIF Q$ = "K" OR Q$ = "k" THEN
        PRINT "Oscillating . . ."
        PRINT " . . . press any key to end."
        CALL Klaxon(987, 329)
    ELSEIF Q$ = "q" THEN
        Q$ = "Q"
    END IF
WEND
END

' Loop two sounds down at decreasing time intervals
SUB Bounce (Hi, Low) STATIC
    FOR Count = 60 TO 1 STEP -2
        SOUND Low - Count / 2, Count / 20
        SOUND Hi, Count / 15
    NEXT
END SUB

' Loop down from a high sound to a low sound
SUB Fall (Hi, Low, Del) STATIC
    FOR Count = Hi TO Low STEP -10
        SOUND Count, Del / Count
    NEXT
END SUB

' Alternate two sounds until a key is pressed
SUB Klaxon (Hi, Low) STATIC
    WHILE INKEY$ = ""
        SOUND Hi, 5
        SOUND Low, 5
    WEND
END SUB

' Loop a sound from low to high to low
SUB Siren (Hi, Rng) STATIC
    WHILE INKEY$ = ""
        FOR Count = Rng TO -Rng STEP -4
            SOUND Hi - ABS(Count), .3
            Count = Count - 2 / Rng
        NEXT
    WEND
END SUB

