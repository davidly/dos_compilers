       IDENTIFICATION DIVISION.
       PROGRAM-ID.    DEMO.
       SECURITY.
              THIS PROGRAM TESTS SCREEN DISPLAY AND ACCEPT. A SERIES OF
              SCREENS ARE DISPLAYED, AND ACCEPTED. THE USER SHOULD ENTER
              VALUES INTO THE FIELDS TO TEST THE FEATURES INDICATED
              IN THE HEADINGS.
      *
       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

         01  SCREEN-ACCEPT-FIELDS.
             05  ANY-CHAR-1       PIC X(13)    VALUE SPACES.
             05  INTEGER-1        PIC S9(6)     VALUE ZERO.
             05  TWO-PLACE-NUM-1  PIC S9(4)V99  VALUE ZERO.
             05  FIVE-PLACE-NUM-1 PIC SV9(5)    VALUE ZERO.

             05  ANY-CHAR-2       PIC X(13)    VALUE "ABCDEFGHIJKLM".
             05  INTEGER-2        PIC S9(6)     VALUE 1234.
             05  TWO-PLACE-NUM-2  PIC S9(4)V99  VALUE 1234.56.
             05  FIVE-PLACE-NUM-2 PIC SV9(5)    VALUE .12345.

             05  ANY-CHAR-3       PIC X(13)    VALUE "ABCDEFGHIJKLM".
             05  INTEGER-3        PIC S9(6)     VALUE 1234.
             05  TWO-PLACE-NUM-3  PIC S9(4)V99  VALUE 1234.56.
             05  FIVE-PLACE-NUM-3 PIC SV9(5)    VALUE .12345.

             05  ANY-CHAR-4       PIC X(13)    VALUE "ABCDEFGHIJKLM".
             05  INTEGER-4        PIC S9(6)     VALUE 1234.
             05  TWO-PLACE-NUM-4  PIC S9(4)V99  VALUE 1234.56.
             05  FIVE-PLACE-NUM-4 PIC SV9(5)    VALUE .12345.

             05  ANY-CHAR-5       PIC X(13)    VALUE "ABCDEFGHIJKLM".
             05  INTEGER-5        PIC S9(6)     VALUE 1234.
             05  TWO-PLACE-NUM-5  PIC S9(4)V99  VALUE 1234.56.
             05  FIVE-PLACE-NUM-5 PIC SV9(5)    VALUE .12345.

             05  ANY-CHAR-6       PIC X(13)    VALUE "ABCDEFGHIJKLM".
             05  INTEGER-6        PIC S9(6)     VALUE 1234.
             05  TWO-PLACE-NUM-6  PIC S9(4)V99  VALUE 1234.56.
             05  FIVE-PLACE-NUM-6 PIC SV9(5)    VALUE .12345.

             05  ANY-CHAR-7       PIC X(13)    VALUE "ABCDEFGHIJKLM".
             05  INTEGER-7        PIC S9(6)     VALUE 1234.
             05  TWO-PLACE-NUM-7  PIC S9(4)V99  VALUE 1234.56.
             05  FIVE-PLACE-NUM-7 PIC SV9(5)    VALUE .12345.


       01  WORK-FIELDS.
           05  IIX          PIC S9(5)  VALUE 0 COMP-0.
           05  JIX          PIC S9(5)  VALUE 0 COMP-0.
           05  KIX          PIC S9(5)  VALUE 0 COMP-0.
           05  WS-TITLE-LEN PIC S9(5)  VALUE 0 COMP-0.
           05  WS-START     PIC S9(5)  VALUE 0 COMP-0.
           05  WS-END       PIC S9(5)  VALUE 0 COMP-0.

           05  TEN-SPACES   PIC X(10) VALUE SPACES.
           05  ANY-CHAR     PIC X    VALUE SPACE.
           05  WS-OPTION    PIC X    VALUE SPACE.
               88  SCREEN-OPTION     VALUE 'S', 's'.
               88  CREATE-OPTION     VALUE 'C', 'c'.
               88  UPDATE-OPTION     VALUE 'U', 'u'.
               88  END-OPTION        VALUE 'E', 'e'.

       01  WS-WK-TITLE     PIC X(50)  VALUE ALL 'X'.
       01  FILLER REDEFINES WS-WK-TITLE.
           05  WS-WK-TITLE-CHAR OCCURS 50 TIMES    PIC X.
 
       01  WS-TITLE     PIC X(50)  VALUE SPACES. 
       01  FILLER REDEFINES WS-TITLE.
           05  WS-TITLE-CHAR OCCURS 50 TIMES    PIC X.
  
       01  SWITCHES.
           05  ON-VALUE         PIC X           VALUE 'Y'.
           05  OFF-VALUE        PIC X           VALUE 'N'.
           05  DEMO-FINISHED-SW      PIC X      VALUE 'N'.
               88  DEMO-FINISHED                VALUE 'Y'.


       SCREEN SECTION.                       

       01  BLANK-SCREEN.
           03 BLANK SCREEN.

       01  TUTOR-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 10 VALUE
                 '    DEMO - MICROSOFT MS-COBOL DEMONSTRATION SYSTEM'.
           03  LINE 3 COLUMN 1 VALUE
                 'In this program, you will be given the options to see 
      -          'how Microsoft MS-COBOL  '.
           03  LINE 4 COLUMN 1 VALUE
                 'uses its Screen Section to create fill-in forms on you
      -          'r terminal screen'.
           03  LINE 5 COLUMN 1 VALUE
                 'or to create, list, and update a simple indexed file d
      -          'ata base.'.
           03  LINE 8 COLUMN 1 BLANK LINE.
           03  LINE 9 COLUMN 1 VALUE
                 'You will first be asked to type in a title, made up of
      -          ' any characters'.
           03  LINE 10 COLUMN 1 VALUE
                 'you like, that will be used in later screens. The prog
      -          'ram will center'. 
           03  LINE 11 COLUMN 1 VALUE
                 'the title for you. Next you will be asked to hit ENTER 
      -          ' to get the'. 
           03  LINE 12 COLUMN 1 VALUE
                'next screen. The title you entered will appear, along w
      -          'ith a list'. 
           03  LINE 13 COLUMN 1 VALUE
                 'of options, and you will be given further instructions 
      -          '. '. 
           03  LINE 15 COLUMN 1 VALUE
                'Ready?'.
           03  LINE 17 COLUMN 1 VALUE
                'Please type a title from 1 to 50 characters below, then
      -          ' hit ENTER:'.
           03  LINE 19 COLUMN 1 HIGHLIGHT VALUE 'Title: '.
           03  PIC X(50) TO WS-WK-TITLE.
           03  LINE 21 COLUMN 1 HIGHLIGHT VALUE
                 'Please hit ENTER to continue. '.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.

       01  OPTION-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 19 VALUE
                 '  OPTIONS FOR MS-COBOL DEMONSTATION PROGRAM'.
           03  LINE 3 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 5 COLUMN 1 VALUE
                 'You may now run programs that demonstrate features of 
      -          'MS-COBOL. Among'.
           03  LINE 6 COLUMN 1 VALUE
                 'these features are:'.
           03  LINE 7 COLUMN 15 VALUE
                 'Screen Section for generating screens'.
           03  LINE 8 COLUMN 15 VALUE
                 'Automatic generation of program overlays'.
           03  LINE 9 COLUMN 15 VALUE
                 "CALLing of subroutines".
           03  LINE 10 COLUMN 15 VALUE
                 "CHAINing to another program without returning".
           03  LINE 11 COLUMN 15 VALUE
                 'Creation of an indexed (ISAM) data file.'.
           03  LINE 12 COLUMN 15 VALUE
                 'Display, addition, deletion and modification of record
      -          's in the'.
           03  LINE 13 COLUMN 20 VALUE
                 'ISAM file.'.
           03  LINE 14 COLUMN 1 VALUE
                 'Please select one of the following options by entering
      -          ' the first letter '.
           03  LINE 15 COLUMN 1 VALUE
                 'of the option in the space below. Choose option E to e
      -          'nd this demonstration '.
           03  LINE 17 COLUMN 5 VALUE
                 'Option S: Screen section demonstration'.
           03  LINE 18 COLUMN 5 VALUE
                 'Option C: Create an indexed-file data base'.
           03  LINE 19 COLUMN 5 VALUE
                 'Option U: Update or display indexed-file data base.'.
           03  LINE 20 COLUMN 5 VALUE
                 'Option E: End the demonstration.'.
           03  LINE 22 COLUMN 10 HIGHLIGHT VALUE
                 'Enter option here followed by ENTER: '.
           03  COLUMN PLUS 1 PIC X TO WS-OPTION.   




       01  SCREEN-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INTERACTIVE DISPLAY/ACCEPT DEMONSTRATION'.
           03  LINE 3 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 5 COLUMN 1 VALUE
                 'In this program, several screens are displayed, then a
      -          'ccepted. As a screen '.
           03  LINE 6 COLUMN 1 VALUE
                 'is displayed, enter new values into its fields, and se
      -          'e how screens '.
           03  LINE 7 COLUMN 1 VALUE
                 'function under different options, such as:'.
           03  LINE 9 COLUMN 10 VALUE
                 'UPDATE (with the USING, TO, and FROM options)'.
           03  LINE 10 COLUMN 10 VALUE
                 'AUTO-SKIP'.
           03  LINE 11 COLUMN 10 VALUE
                 'SECURE'.
           03  LINE 16 COLUMN 1 HIGHLIGHT VALUE
                 'Hit ENTER to continue. '.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.   

       01  SCREEN-SCREEN-2.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INTERACTIVE DISPLAY/ACCEPT DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 4 COLUMN 1 VALUE
                 'Note that when fields are defined as numeric, i.e, whe
      -          'n the PIC clause '.
           03  LINE 5 COLUMN 1 VALUE
                 'contains "9"s, the cursor starts at the right end of t
      -          'he field, and '.
           03  LINE 6 COLUMN 1 VALUE
                 'when a digit is typed, any previous value is cleared.
      -          ' '.
           03  LINE 8 COLUMN 1 VALUE
                 'If a numeric field contains a decimal point, you may h
      -          'ave to type a'.
           03  LINE 9 COLUMN 1 VALUE
                 'period (".") to get to the right of the decimal point.  
      -          ''.
           03  LINE 10 COLUMN 1 BLANK LINE.
           03  LINE 11 COLUMN 1 VALUE
                 'When a field is defined as alpha-numeric, i.e., when t
      -          'he PIC clause'.
           03  LINE 12 COLUMN 1 VALUE
                 'contains "X"s, the cursor starts on the left and chara
      -          'cters in the field'.
           03  LINE 13 COLUMN 1 VALUE
                 'may be edited with cursor positioning keys.'.
           03  LINE 14 COLUMN 1 BLANK LINE.
           03  LINE 15 COLUMN 1 VALUE
                'The following screens will include information on how'.  
           03  LINE 16 COLUMN 1 VALUE
                 'to ACCEPT a field or an entire screen, how to back up 
      -          'to earlier'.
           03  LINE 17 COLUMN 1 VALUE
                 'fields in a screen, and how to modify values entered i
      -          'nto a field.'.
           03  LINE 22 COLUMN 1 HIGHLIGHT VALUE
                 'Please hit ENTER to continue. '.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.   
                              
       01  HINT-SCREEN.
           03  LINE 19 COLUMN 1 VALUE
                 'Helpful hints: '.
           03  LINE 20 COLUMN 1 VALUE
                 '    ENTER or TAB will accept a field and go to next fi
      -          'eld.'.
           03  LINE 21 COLUMN 1 VALUE
                 '    <ESCAPE> accepts all fields on a screen.'.
           03  LINE 22 COLUMN 1 VALUE
                 '    <BACK TAB> returns to a previous field.'.
           03  LINE 23 COLUMN 1 VALUE
                 '    Edit alpha-numeric fields with the cursor position
      -          ' keys.'.
           03  LINE 24 COLUMN 1 VALUE
                 '    Alarm will sound when what you type is not what is
      -          ' expected.'.

         01  NORMAL-SCREEN.
             03  BLANK SCREEN.
             03  LINE 1 COLUMN 20  VALUE
                   "ACCEPT SCREEN WITHOUT AUTO SKIP OR SECURE".
             03  LINE 3 COLUMN 10  VALUE
                 "* Enter values into the fields below. Note that you mu
      -            "st hit TAB or".
             03  LINE 4 COLUMN 14  VALUE
                 "RETURN to go from one field to the next.".
             03  LINE 5 COLUMN 10  VALUE
                 "* You must type a period to get past the decimal point
      -            " in the third".
             03  LINE 6 COLUMN 14  VALUE
                 "field in each line. Hit BACK TAB to return to the prev
      -            "ious field.".
             03  LINE 7 COLUMN 10  VALUE
                 '* Fields described as "NUMBER" can only contain digits
      -            ', signs, '.
             03  LINE 8 COLUMN 14  VALUE
                   'and a decimal point.'.

             03  NS-LINE-10.
                 05  LINE 10.
                 05  COLUMN 1 VALUE
                     "FEATURE DEMONSTRATED".
                 05  COLUMN 23 VALUE
                     "ANY CHARACTER".
                 05  COLUMN 39 VALUE
                     "NUMBER".
                 05  COLUMN 49 VALUE
                     "NUMBER".
                 05  COLUMN 58 VALUE
                     "NUMBER".

             03  NS-LINE-12.
                 05  LINE 12.
                 05  COLUMN 1 VALUE
                     "NO ORIGINAL VALUE".
                 05  COLUMN 23 PIC X(13) TO ANY-CHAR-1.
                 05  COLUMN 39 PIC S9(6)  TO INTEGER-1.
                 05  COLUMN 49 PIC S9(4)V99  TO TWO-PLACE-NUM-1.
                 05  COLUMN 58 PIC SV9(5) TO FIVE-PLACE-NUM-1.

             03  NS-LINE-13.
                 05  LINE 13.
                 05  COLUMN 1 VALUE
                     "UPDATE VALUES".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-2.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-2.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-2.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-2.

             03  NS-LINE-14.
                 05  LINE 14.
                 05  COLUMN 1 VALUE
                     "HIGHLIGHT,REV-VIDEO".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-3 HIGHLIGHT.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-3 HIGHLIGHT.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-3
                                           REVERSE-VIDEO.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-3
                                           REVERSE-VIDEO.

             03  NS-LINE-15.
                 05  LINE 15.
                 05  COLUMN 1 VALUE
                     "UNDERLINE-BLINK".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-4
                                           UNDERLINE.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-4
                                           UNDERLINE.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-4
                                           BLINK.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-4
                                           BLINK.
             03  NS-LINE-16.
                 05  LINE 16.
                 05  COLUMN 1 VALUE
                     "AUTO-SECURE".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-5
                                           AUTO.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-5
                                           AUTO.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-5
                                           SECURE.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-5
                                           SECURE.

             03  NS-LINE-17.
                 05  LINE 17.
                 05  COLUMN 1 VALUE
                     "BELL + OTHERS".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-6
                                           HIGHLIGHT BELL.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-6
                                           REVERSE-VIDEO BELL.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-6
                                           UNDERLINE BELL.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-6
                                            BLINK BELL.

         01  AUTO-SKIP-SCREEN AUTO.
             03  BLANK SCREEN.
             03  LINE 1 COLUMN 28  VALUE
                   "ACCEPT SCREEN WITH AUTO-SKIP".
             03  LINE 3 COLUMN 10  VALUE
                 "* Enter values into the fields below. Note that when a
      -            " field is filled,".
             03  LINE 4 COLUMN 14  VALUE
                   "the cursor will go to the next field without having
      -            "to hit RETURN.".
             03  LINE 5 COLUMN 10  VALUE
                 "* You may still use RETURN and TAB to advance to the n
      -            "ext field,".
             03  LINE 6 COLUMN 14  VALUE
                   "and use BACK TAB to return to a previous field.".
             03  LINE 7 COLUMN 10  VALUE
                 '* Fields described as "NUMBER" can only contain digits
      -            ', signs, '.
             03  LINE 8 COLUMN 14  VALUE
                   'and a decimal point.'.


             03  AS-LINE-10.
                 05  LINE 10.
                 05  COLUMN 1 VALUE
                     "FEATURE DEMONSTRATED".
                 05  COLUMN 23 VALUE
                     "ANY CHARACTER".
                 05  COLUMN 39 VALUE
                     "NUMBER".
                 05  COLUMN 49 VALUE
                     "NUMBER".
                 05  COLUMN 58 VALUE
                     "NUMBER".

             03  AS-LINE-12.
                 05  LINE 12.
                 05  COLUMN 1 VALUE
                     "NO ORIGINAL VALUE".
                 05  COLUMN 23 PIC X(13) TO ANY-CHAR-1.
                 05  COLUMN 39 PIC S9(6)  TO INTEGER-1.
                 05  COLUMN 49 PIC S9(4)V99  TO TWO-PLACE-NUM-1.
                 05  COLUMN 58 PIC SV9(5) TO FIVE-PLACE-NUM-1.

             03  AS-LINE-13.
                 05  LINE 13.
                 05  COLUMN 1 VALUE
                     "UPDATE VALUES".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-2.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-2.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-2.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-2.

             03  AS-LINE-14.
                 05  LINE 14.
                 05  COLUMN 1 VALUE
                     "HIGHLIGHT,REV-VIDEO".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-3 HIGHLIGHT.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-3 HIGHLIGHT.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-3
                                           REVERSE-VIDEO.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-3
                                           REVERSE-VIDEO.

             03  AS-LINE-15.
                 05  LINE 15.
                 05  COLUMN 1 VALUE
                     "UNDERLINE-BLINK".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-4
                                           UNDERLINE.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-4
                                           UNDERLINE.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-4
                                           BLINK.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-4
                                           BLINK.
             03  AS-LINE-16.
                 05  LINE 16.
                 05  COLUMN 1 VALUE
                     "SECURE".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-5
                                           SECURE.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-5
                                           SECURE.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-5
                                           SECURE.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-5
                                           SECURE.

             03  AS-LINE-17.
                 05  LINE 17.
                 05  COLUMN 1 VALUE
                     "BELL + OTHERS".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-6
                                           HIGHLIGHT BELL.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-6
                                           REVERSE-VIDEO BELL.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-6
                                           UNDERLINE BELL.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-6
                                            BLINK BELL.


         01  SECURE-SCREEN SECURE.
             03  BLANK SCREEN.
             03  LINE 1 COLUMN 28  VALUE
                   "ACCEPT SCREEN WITH SECURE".
             03  LINE 3 COLUMN 10  VALUE
                 "* Enter values into the fields below. Note that when a
      -            " field is typed,".
             03  LINE 4 COLUMN 14  VALUE
                   "it is turned into asterisks, which will hide the val
      -            "ue entered.".
             03  LINE 5 COLUMN 10  VALUE
                 "* You may still use RETURN and TAB to advance to the n
      -            "ext field,".
             03  LINE 6 COLUMN 14  VALUE
                   "and use BACK TAB to return to a previous field.".
             03  LINE 7 COLUMN 10  VALUE
                 '* Fields described as "NUMBER" can only contain digits
      -            ', signs, '.
             03  LINE 8 COLUMN 14  VALUE
                   'and a decimal point.'.


             03  SS-LINE-10.
                 05  LINE 10.
                 05  COLUMN 1 VALUE
                     "FEATURE DEMONSTRATED".
                 05  COLUMN 23 VALUE
                     "ANY CHARACTER".
                 05  COLUMN 39 VALUE
                     "NUMBER".
                 05  COLUMN 49 VALUE
                     "NUMBER".
                 05  COLUMN 58 VALUE
                     "NUMBER".

             03  SS-LINE-12.
                 05  LINE 12.
                 05  COLUMN 1 VALUE
                     "NO ORIGINAL VALUE".
                 05  COLUMN 23 PIC X(13) TO ANY-CHAR-1.
                 05  COLUMN 39 PIC S9(6)  TO INTEGER-1.
                 05  COLUMN 49 PIC S9(4)V99  TO TWO-PLACE-NUM-1.
                 05  COLUMN 58 PIC SV9(5) TO FIVE-PLACE-NUM-1.

             03  SS-LINE-13.
                 05  LINE 13.
                 05  COLUMN 1 VALUE
                     "UPDATE VALUES".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-2.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-2.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-2.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-2.

             03  SS-LINE-14.
                 05  LINE 14.
                 05  COLUMN 1 VALUE
                     "HIGHLIGHT,REV-VIDEO".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-3 HIGHLIGHT.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-3 HIGHLIGHT.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-3
                                           REVERSE-VIDEO.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-3
                                           REVERSE-VIDEO.

             03  SS-LINE-15.
                 05  LINE 15.
                 05  COLUMN 1 VALUE
                     "UNDERLINE-BLINK".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-4
                                           UNDERLINE.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-4
                                           UNDERLINE.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-4
                                           BLINK.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-4
                                           BLINK.
             03  SS-LINE-16. 
                 05  LINE 16.
                 05  COLUMN 1 VALUE
                     "AUTO-SKIP".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-5
                                           AUTO.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-5
                                           AUTO.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-5
                                           AUTO.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-5  
                                           AUTO.

             03  SS-LINE-17.
                 05  LINE 17.
                 05  COLUMN 1 VALUE
                     "BELL + OTHERS".
                 05  COLUMN 23 PIC X(13) USING ANY-CHAR-6
                                           HIGHLIGHT BELL.
                 05  COLUMN 39 PIC S9(6)  USING INTEGER-6
                                           REVERSE-VIDEO BELL.
                 05  COLUMN 49 PIC S9(4)V99  USING TWO-PLACE-NUM-6
                                           UNDERLINE BELL.
                 05  COLUMN 58 PIC SV9(5) USING FIVE-PLACE-NUM-6
                                            BLINK BELL.


       01  FINAL-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 21 VALUE
                 '  END OF MICROSOFT MS-COBOL DEMONSTRATION'.
           03  LINE 3 COLUMN 15     PIC X(50) FROM WS-TITLE.
           03  LINE 5 COLUMN 1 VALUE
                 'Thank you for taking part in this demonstration of '.
           03  LINE 6 COLUMN 1 VALUE
                 'the features of Microsoft MS-COBOL.'.
           03  LINE 8 COLUMN 1 HIGHLIGHT VALUE
                 'Please hit ENTER to end this program. '.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.


       PROCEDURE DIVISION.

       P000-MAIN-LINE.
      *
      *       *** demo.cpy is a copy file of pre-processing warnings ***
      *       *** It MUST always end with:
      *                  PERFORM P005-PROCESS.
      *
           COPY demo.cpy.

           STOP RUN.


       P005-PROCESS.
           DISPLAY TUTOR-SCREEN.
           ACCEPT TUTOR-SCREEN.



           PERFORM P010-CENTER-TITLE.
           PERFORM P100-GET-OPTIONS
               UNTIL DEMO-FINISHED.

           DISPLAY FINAL-SCREEN.
           ACCEPT FINAL-SCREEN.
           DISPLAY BLANK-SCREEN.

       P010-CENTER-TITLE.
           IF WS-WK-TITLE = SPACES
               MOVE SPACES TO WS-TITLE
           ELSE
               PERFORM P020-CENTER.

        P020-CENTER.  
            PERFORM P025-NOTHING VARYING IIX FROM 1 BY 1
               UNTIL WS-WK-TITLE-CHAR (IIX) NOT = SPACE
               OR IIX > 50.
            PERFORM P025-NOTHING VARYING JIX FROM 50 BY -1
               UNTIL WS-WK-TITLE-CHAR (JIX) NOT = SPACE
               OR JIX NOT > 1.
            COMPUTE WS-TITLE-LEN = JIX - IIX + 1.
            COMPUTE WS-START = 1 + ((50 - WS-TITLE-LEN) / 2).
            COMPUTE WS-END = WS-TITLE-LEN + WS-START - 1.
            PERFORM P030-MOVE-TITLE VARYING KIX FROM WS-START
               BY 1 UNTIL KIX > WS-END.

       P025-NOTHING.
           EXIT.

       P030-MOVE-TITLE.
           MOVE WS-WK-TITLE-CHAR (IIX) TO WS-TITLE-CHAR (KIX).
           ADD 1 TO IIX.

       P100-GET-OPTIONS.
           MOVE ZERO TO WS-OPTION.
           DISPLAY OPTION-SCREEN.
           ACCEPT OPTION-SCREEN.

           IF SCREEN-OPTION
                PERFORM P500-SCREEN-DEMO
           ELSE IF CREATE-OPTION
                PERFORM P200-CREATE-DATA-FILE
           ELSE IF UPDATE-OPTION
                PERFORM P300-UPDATE-DATA-FILE
           ELSE IF END-OPTION
                MOVE ON-VALUE TO DEMO-FINISHED-SW.

       P200-CREATE-DATA-FILE.
           CALL "build" USING WS-TITLE.

       P300-UPDATE-DATA-FILE.
           CHAIN "update" USING WS-TITLE.

       P500-SCREEN-DEMO-SECTION    SECTION 50.
       P500-SCREEN-DEMO.
           DISPLAY SCREEN-SCREEN.
           ACCEPT SCREEN-SCREEN.
           DISPLAY SCREEN-SCREEN-2.
           ACCEPT SCREEN-SCREEN-2.
           DISPLAY NORMAL-SCREEN.
           DISPLAY HINT-SCREEN.
           ACCEPT NORMAL-SCREEN.
           DISPLAY AUTO-SKIP-SCREEN.
           DISPLAY HINT-SCREEN.
           ACCEPT AUTO-SKIP-SCREEN.
           DISPLAY SECURE-SCREEN.
           DISPLAY HINT-SCREEN.
           ACCEPT SECURE-SCREEN.

