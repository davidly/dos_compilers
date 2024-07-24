       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CENTER.
       SECURITY.
              THIS PROGRAM CENTERS, LEFT ALIGNS, OR RIGHT ALIGNS
              A HEADING WITHIN AN 80 CHARACTER FIELD. IT CAN BE MADE 
              INTO A GENERAL-PURPOSE SUBROUTINE BY MOVING THE BLOCK OF
              STORAGE CALLED PARAMETER-AREA INTO THE LINKAGE SECTION,
              ADDING THE CLAUSE, "USING PARAMETER-AREA" TO THE PROCEDURE
              DIVISION HEADER, REPLACING "STOP RUN" WITH "EXIT PROGRAM",
              AND DELETING THE DISPLAY AND ACCEPT STATEMENTS. THE
              PARAMETER-AREA VARIABLES WOULD THEN BE SET UP IN THE 
		  CALLING PROGRAM.


      *
       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.



       01  WORK-FIELDS.
           05  IIX          PIC S9(5)  VALUE 0 COMP-0.
           05  WS-IN-START  PIC S9(5)  VALUE 0 COMP-0.
           05  WS-IN-END    PIC S9(5)  VALUE 0 COMP-0.
           05  WS-IN-LEN    PIC S9(5)  VALUE 0 COMP-0.
           05  WS-OUT-INDEX PIC S9(5)  VALUE 0 COMP-0.
           05  TEN-SPACES   PIC X(10)  VALUE SPACES.

       01  SWITCHES.
           05  ON-VALUE         PIC X           VALUE 'Y'.
           05  OFF-VALUE        PIC X           VALUE 'N'.
           05  FINISHED-SW      PIC X           VALUE 'N'.
               88  FINISHED                     VALUE 'Y'.

       01  WS-RULERS.
           05  WS-RULER-1.
               10  FILLER       PIC X(40)       VALUE
                 "         1         2         3         4".                                      
               10  FILLER       PIC X(40)       VALUE
                 "         5         6         7         8".                                      
           05  WS-RULER-2.
               10  FILLER       PIC X(40)       VALUE
                 "1234567890123456789012345678901234567890".                                      
               10  FILLER       PIC X(40)       VALUE
                 "1234567890123456789012345678901234567890".                                      

       01  PARAMETER-AREA.
           05  PA-OPTION    PIC X         VALUE SPACE.
               88  CENTER-OPTION          VALUE 'C', 'c'.
               88  LEFT-ALIGN-OPTION      VALUE 'L', 'l'.
               88  RIGHT-ALIGN-OPTION     VALUE 'R', 'r'.
               88  VALID-OPTION           VALUE 'C', 'c', 'L', 'l',
                                                'R', 'r'.
               88  END-OPTION             VALUE 'E', 'e'.

           05  PA-BUFFER-LEN   PIC S9(5)  VALUE 80 COMP-0.

           05  PA-IN-TITLE    PIC X(80)  VALUE SPACES.
           05  FILLER REDEFINES PA-IN-TITLE.
               10  PA-IN-TITLE-CHAR OCCURS 80 TIMES    PIC X.
 
           05  PA-OUT-TITLE    PIC X(80)  VALUE SPACES.
           05  FILLER REDEFINES PA-OUT-TITLE.
               10  PA-OUT-TITLE-CHAR OCCURS 80 TIMES    PIC X.
 




       PROCEDURE DIVISION.

       P000-MAIN-LINE.
           DISPLAY SPACE.
           DISPLAY SPACE.
           DISPLAY TEN-SPACES, 
           " This is program CENTER, one of the MS-COBOL demonstration".
           DISPLAY TEN-SPACES, 
           " programs. It will center, left align, or right align".
           DISPLAY TEN-SPACES, 
           " a line of text up to 80 characters long. You will be ".
           DISPLAY TEN-SPACES, 
           " asked whether you want to center or align your text, ".
           DISPLAY TEN-SPACES, 
           " then asked to enter your text, which will be displayed".
           DISPLAY TEN-SPACES, 
           " as requested.".
           DISPLAY SPACE.
           DISPLAY TEN-SPACES, 
           " This action will be repeated until you enter".
           DISPLAY TEN-SPACES, 
           " option E to end the program.".
           DISPLAY SPACE.
           DISPLAY TEN-SPACES, 
           " This is a simple program, but it may be made into a".
           DISPLAY TEN-SPACES, 
           " subroutine that can be called to center or align report".
           DISPLAY TEN-SPACES, 
           " or screen headings.".
           DISPLAY SPACE.
           DISPLAY SPACE.


           PERFORM P010-GET-OPTION   
               UNTIL FINISHED.

           STOP RUN.

       P010-GET-OPTION.
           DISPLAY
            " Please type first letter of option desired, then hit",
            " RETURN:".
           DISPLAY
            " Option C: Center text on screen".
           DISPLAY
            " Option L: Left align text on screen".
           DISPLAY
            " Option R: Right align text on screen".
           DISPLAY
            " Option E: End this program".
           DISPLAY SPACE.
           ACCEPT PA-OPTION.

           IF END-OPTION
               MOVE ON-VALUE TO FINISHED-SW
           ELSE IF VALID-OPTION
                 PERFORM P020-GET-TITLE.

       P020-GET-TITLE. 
           DISPLAY
            " Please enter text (1 to 80 characters) below:".
           DISPLAY SPACE.
           MOVE SPACES TO PA-OUT-TITLE.
           ACCEPT PA-IN-TITLE.

           IF PA-IN-TITLE NOT = SPACES
               PERFORM P030-ADJUST.

           DISPLAY
            "Centered/aligned text:".
           DISPLAY WS-RULER-1.
           DISPLAY WS-RULER-2.
           DISPLAY PA-OUT-TITLE.

        P030-ADJUST.  
            PERFORM P035-NOTHING VARYING WS-IN-START 
               FROM 1 BY 1
               UNTIL PA-IN-TITLE-CHAR (WS-IN-START) NOT = SPACE
               OR WS-IN-START > PA-BUFFER-LEN.

            PERFORM P035-NOTHING VARYING WS-IN-END
               FROM PA-BUFFER-LEN BY -1
               UNTIL PA-IN-TITLE-CHAR (WS-IN-END) NOT = SPACE
               OR WS-IN-END NOT > 1.

            IF LEFT-ALIGN-OPTION
               MOVE 1 TO WS-OUT-INDEX
            ELSE
               COMPUTE WS-IN-LEN =
                  WS-IN-END - WS-IN-START + 1
               IF RIGHT-ALIGN-OPTION
                  COMPUTE WS-OUT-INDEX = 
                        1 + (PA-BUFFER-LEN - WS-IN-LEN) 
               ELSE
      *                      *** MUST BE CENTER OPTION ******  
                   COMPUTE WS-OUT-INDEX = 
                        1 + ((PA-BUFFER-LEN - WS-IN-LEN) / 2).

            PERFORM P040-MOVE-TITLE VARYING IIX FROM WS-IN-START
               BY 1 UNTIL IIX > WS-IN-END.

       P035-NOTHING.
           EXIT.

       P040-MOVE-TITLE.
           MOVE PA-IN-TITLE-CHAR (IIX)
               TO PA-OUT-TITLE-CHAR (WS-OUT-INDEX).
           ADD 1 TO WS-OUT-INDEX.
