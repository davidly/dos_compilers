       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BUILD. 
       SECURITY.
             THIS PROGRAM CREATES AN INDEXED FILE OF NAMES, ADDRESSES,
             AND PHONE NUMBERS
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ISAM-FILE
              ASSIGN TO DISK
              FILE STATUS IS ISAM-STATUS
              RECORD KEY IS ISAM-KEY
              ACCESS MODE IS RANDOM
              ORGANIZATION IS INDEXED.

       DATA DIVISION.
       FILE SECTION.
       FD  ISAM-FILE
           LABEL RECORDS ARE STANDARD
           VALUE OF FILE-ID IS 'ISAM.DAT'.

       01  ISAM-RECORD.
           05  ISAM-KEY.
               10  ISAM-LAST-NAME      PIC X(20).
               10  ISAM-FIRST-NAME     PIC X(20).
           05  ISAM-ADDRESS-LINE-1     PIC X(40).
           05  ISAM-ADDRESS-LINE-2     PIC X(40).
           05  ISAM-PHONE     PIC X(12).


       WORKING-STORAGE SECTION.

       01  WORK-FIELDS.
           05  IIX          PIC S9(5)  VALUE 0 COMP-0.
           05  JIX          PIC S9(5)  VALUE 0 COMP-0.
           05  KIX          PIC S9(5)  VALUE 0 COMP-0.
           05  ISAM-STATUS  PIC XX     VALUE SPACES.


           05  WS-MORE       PIC X    VALUE SPACES.
               88  NO-MORE       VALUE 'N', 'n'.

           05  ANY-CHAR     PIC X    VALUE SPACE.

       01  SWITCHES.
           05  ON-VALUE         PIC X           VALUE 'Y'.
           05  OFF-VALUE        PIC X           VALUE 'N'.
           05  BUILD-FINISHED-SW      PIC X     VALUE 'N'.
               88  BUILD-FINISHED               VALUE 'Y'.

       01  WS-DATA-RECORD.
           05  WS-KEY.
               10  WS-LAST-NAME      PIC X(20) VALUE SPACES.
               10  WS-FIRST-NAME     PIC X(20) VALUE SPACES.
           05  WS-ADDRESS-LINE-1     PIC X(40) VALUE SPACES.
           05  WS-ADDRESS-LINE-2     PIC X(40) VALUE SPACES.
           05  WS-PHONE     PIC X(12)   VALUE SPACES.  

       LINKAGE SECTION.                       
       01  LS-TITLE     PIC X(50).
 
       SCREEN SECTION.                       

       01  BLANK-SCREEN.
           03 BLANK SCREEN.

       01  TUTOR-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE CREATION DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM LS-TITLE HIGHLIGHT.
           03  LINE 4 COLUMN 5 VALUE
                 'This is subprogram BUILD, CALLed from main program DEM
      -          'O.'.
           03  LINE 5 COLUMN 5 VALUE
                 'The title above was passed as a parameter from DEMO.'.
           03  LINE 7 COLUMN 1 VALUE
                 'In this program, you will create an indexed (ISAM) fil
      -          'e of records containing '.
           03  LINE 8 COLUMN 1 VALUE
                 'names, addresses, and phone numbers. After the data fo
      -          'r one person  '.
           03  LINE 9 COLUMN 1 VALUE
                 'has been entered, you will be given the opportunity to
      -          ' review the data.'.
           03  LINE 11 COLUMN 1 VALUE
                 'If the data is ok, it will be written to files ISAM.DA
      -          'T and ISAM.KEY.'.
           03  LINE 13 COLUMN 1 VALUE
                 'The full name of the person will be used as a key for 
      -          'searching the'.
           03  LINE 14 COLUMN 1 VALUE
                 'file in program UPDATE.'.
           03  LINE 16 COLUMN 1 VALUE
                 'To end this program, reply N to the question:'.
           03  LINE 17 COLUMN 1 VALUE
                 '    "Do you wish to enter more data?(Y/N)"'.
           03  LINE 18 COLUMN 1 VALUE
                 'when it appears on the screen.'.
           03  LINE 20 COLUMN 1 HIGHLIGHT VALUE
                 'Hit ENTER to continue. '.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.

       01  DATA-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE CREATION DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM LS-TITLE HIGHLIGHT.
           03  LINE 4 COLUMN 1 VALUE
                 'Please enter the data requested below. To end this pro
      -          'gram'.
           03  LINE 5 COLUMN 1 VALUE
                 'reply N to the question: "Do you wish to enter more da
      -          'ta?(Y/N)"'.
           03  LINE 6 COLUMN 1 VALUE
                 'when it appears on the screen.'.
           03  LINE 8 COLUMN 1  VALUE
                 'Enter FIRST name and initial  (1 to 20 characters): '.
           03  LINE 9 COLUMN 1 VALUE '[' HIGHLIGHT.
           03  LINE 9 COLUMN 2   PIC X(20) USING WS-FIRST-NAME.
           03  LINE 9 COLUMN 22 VALUE ']' HIGHLIGHT.
           03  LINE 10 COLUMN 1 VALUE
                 'Enter LAST name  (1 to 20 characters): '.
           03  LINE 11 COLUMN 1 VALUE '[' HIGHLIGHT.
           03  LINE 11 COLUMN 2   PIC X(20) USING WS-LAST-NAME.
           03  LINE 11 COLUMN 22 VALUE ']' HIGHLIGHT.
           03  LINE 13 COLUMN 1 VALUE
                 'Enter first address line (1 to 40 characters): '.
           03  LINE 14 COLUMN 1 VALUE '[' HIGHLIGHT.
           03  LINE 14 COLUMN 2      PIC X(40) USING WS-ADDRESS-LINE-1.
           03  LINE 14 COLUMN 42 VALUE ']' HIGHLIGHT.
           03  LINE 15 COLUMN 1 VALUE
                 'Enter second address line (1 to 40 characters): '.
           03  LINE 16 COLUMN 1 VALUE '[' HIGHLIGHT.
           03  LINE 16 COLUMN 2      PIC X(40) USING WS-ADDRESS-LINE-2.
           03  LINE 16 COLUMN 42 VALUE ']' HIGHLIGHT.
           03  LINE 18 COLUMN 1 VALUE
                 'Enter phone number (XXX-XXXX or XXX-XXX-XXXX): '.
           03  LINE 19 COLUMN 1 VALUE '[' HIGHLIGHT.
           03  LINE 19 COLUMN 2      PIC X(12) USING WS-PHONE. 
           03  LINE 19 COLUMN 14 VALUE ']' HIGHLIGHT.
           03  LINE 21 COLUMN 10 VALUE
                'If data is OK, hit ENTER to write to the file. You can
      -         'use BACK TAB to '.
           03  LINE 22 COLUMN 15 VALUE
              'return to previous fields and modify data with cursor pos
      -       'itioning'.
           03  LINE 23 COLUMN 15 VALUE
                'keys.'.
           03  LINE 23 COLUMN 21 HIGHLIGHT VALUE
                'Hit ENTER by itself to continue: '.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.
                              
       01  WRITE-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 20 VALUE
                 'MS-COBOL INDEXED FILE CREATION DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM LS-TITLE HIGHLIGHT.
           03  LINE 5 COLUMN 1 VALUE
                 'Record written to file ISAM.DAT. File status = '.
           03       PIC XX FROM ISAM-STATUS HIGHLIGHT.
           03  LINE 8 COLUMN 1 VALUE
                 'File status = 00 means action was successful'.
           03  LINE 9 COLUMN 1 VALUE
                 'File status = 10 means END-OF-FILE encountered'.
           03  LINE 10 COLUMN 1 VALUE
                 'File status = 21 means KEY NOT IN SEQUENCE'.
           03  LINE 11 COLUMN 1 VALUE
              'File status = 22 means ATTEMPT TO WRITE DUPLICATE KEY'.
           03  LINE 12 COLUMN 1 VALUE
                 'File status = 23 means NO RECORD FOUND'.
           03  LINE 13 COLUMN 1 VALUE
                 'File status = 24 means DISK FULL'.
           03  LINE 14 COLUMN 1 VALUE
                 'File status = 30 means PERMANENT INPUT-OUTPUT ERROR'.
           03  LINE 15 COLUMN 1 VALUE
                 'File status = 91 means FILE STRUCTURE WAS DAMAGED'.
           03  LINE 18 COLUMN 1 VALUE
                  '    Do you wish to enter more data?(Y/N)'.
           03  LINE 19 COLUMN 10 HIGHLIGHT VALUE
                'Type response (Y or N) followed by ENTER: '.
           03  COLUMN PLUS 1 PIC X TO WS-MORE.




       PROCEDURE DIVISION USING LS-TITLE.
 
       P000-MAIN-LINE.
           MOVE OFF-VALUE TO BUILD-FINISHED-SW.
           MOVE SPACE TO WS-MORE.
           DISPLAY TUTOR-SCREEN.
           ACCEPT TUTOR-SCREEN.

           OPEN OUTPUT ISAM-FILE.
           IF ISAM-STATUS NOT = '00'
               DISPLAY ' FILE OPEN FAILURE. JOB CANCELLED'
               DISPLAY 'FILE STATUS = ', ISAM-STATUS
               DISPLAY 'TYPE ANY CHARACTER TO END JOB'
               ACCEPT ANY-CHAR
           ELSE
               PERFORM P100-GET-DATA
               UNTIL BUILD-FINISHED.

           CLOSE ISAM-FILE.
           DISPLAY BLANK-SCREEN.
           EXIT PROGRAM.


       P100-GET-DATA.
           MOVE SPACES TO WS-DATA-RECORD.
           DISPLAY DATA-SCREEN.
           ACCEPT DATA-SCREEN.

           PERFORM P500-WRITE-DATA.
           DISPLAY WRITE-SCREEN.
           PERFORM P110-CONTINUE.

       P110-CONTINUE.
           ACCEPT WRITE-SCREEN.
           IF NO-MORE
               MOVE ON-VALUE TO BUILD-FINISHED-SW.
       
       P500-WRITE-DATA.
           WRITE ISAM-RECORD FROM WS-DATA-RECORD.
