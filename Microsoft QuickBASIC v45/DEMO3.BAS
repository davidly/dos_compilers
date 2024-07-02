DECLARE SUB Bounce (Hi%, Low%)
DECLARE SUB Fall (Hi%, Low%, Del%)
DECLARE SUB Siren (Hi%, Range%)
DECLARE SUB Klaxon (Hi%, Low%)
DEFINT A-Z

' QB 4.5 Version of Sound Effects Demo Program

' Sound effects menu
DO
   CLS
   PRINT "Sound effects": PRINT
   COLOR 15, 0: PRINT "  B"; :  COLOR 7, 0: PRINT "ouncing"
   COLOR 15, 0: PRINT "  F"; :  COLOR 7, 0: PRINT "alling"
   COLOR 15, 0: PRINT "  K"; :  COLOR 7, 0: PRINT "laxon"
   COLOR 15, 0: PRINT "  S"; :  COLOR 7, 0: PRINT "iren"
   COLOR 15, 0: PRINT "  Q"; :  COLOR 7, 0: PRINT "uit"
   PRINT : PRINT "Select: ";

   ' Get valid key
   DO
      Q$ = UCASE$(INPUT$(1))
   LOOP WHILE INSTR("BFKSQ", Q$) = 0

   ' Take action based on key
   CLS
   SELECT CASE Q$
      CASE IS = "B"
         PRINT "Bouncing . . . "
         Bounce 32767, 246
      CASE IS = "F"
         PRINT "Falling . . . "
         Fall 2000, 550, 500
      CASE IS = "S"
         PRINT "Wailing . . ."
         PRINT " . . . press any key to end."
         Siren 780, 650
      CASE IS = "K"
         PRINT "Oscillating . . ."
         PRINT " . . . press any key to end."
         Klaxon 987, 329
      CASE ELSE
   END SELECT
LOOP UNTIL Q$ = "Q"
END

' Loop two sounds down at decreasing time intervals
SUB Bounce (Hi%, Low%) STATIC
   FOR Count = 60 TO 1 STEP -2
      SOUND Low - Count / 2, Count / 20
      SOUND Hi, Count / 15
   NEXT Count
END SUB

' Loop down from a high sound to a low sound
SUB Fall (Hi%, Low%, Del%) STATIC
   FOR Count = Hi TO Low STEP -10
      SOUND Count, Del / Count
   NEXT Count
END SUB

' Alternate two sounds until a key is pressed
SUB Klaxon (Hi%, Low%) STATIC
   DO WHILE INKEY$ = ""
      SOUND Hi, 5
      SOUND Low, 5
   LOOP
END SUB

' Loop a sound from low to high to low
SUB Siren (Hi%, Range%)
   DO WHILE INKEY$ = ""
      FOR Count = Range TO -Range STEP -4
         SOUND Hi - ABS(Count), .3
         Count = Count - 2 / Range
      NEXT Count
   LOOP
END SUB
