       IDENTIFICATION DIVISION.
       PROGRAM-ID.    UPDATE.
       SECURITY.
             THIS PROGRAM MODIFIES AND LISTS  AN INDEXED FILE OF 
             NAMES, ADDRESSES, AND PHONE NUMBERS
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ISAM-FILE
              ASSIGN TO DISK
              FILE STATUS IS ISAM-STATUS
              RECORD KEY IS ISAM-KEY
              ACCESS MODE IS DYNAMIC
              ORGANIZATION IS INDEXED.

           SELECT MAIL-LIST-FILE
              ASSIGN TO DISK
              FILE STATUS IS MAIL-LIST-STATUS
              ORGANIZATION IS LINE SEQUENTIAL.

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

       FD  MAIL-LIST-FILE
           LABEL RECORDS ARE STANDARD
           VALUE OF FILE-ID IS 'MAIL.DAT'.

       01  MAIL-LIST-RECORD          PIC X(41).

       WORKING-STORAGE SECTION.

       01  WORK-FIELDS.
           05  IIX          PIC S9(5)  VALUE 0 COMP-0.
           05  JIX          PIC S9(5)  VALUE 0 COMP-0.
           05  KIX          PIC S9(5)  VALUE 0 COMP-0.
           05  WS-START     PIC S9(5)  VALUE 0 COMP-0.
           05  WS-END       PIC S9(5)  VALUE 0 COMP-0.
           05  ISAM-STATUS  PIC XX     VALUE SPACES.
           05  MAIL-LIST-STATUS  PIC XX     VALUE SPACES.
           05  WS-ACTION    PIC X(20)   VALUE SPACES.

           05  WS-OPTION   PIC X    VALUE SPACE.
               88  ADD-OPTION       VALUE 'A', 'a'.
               88  LIST-OPTION      VALUE 'L', 'l'.
               88  DELETE-OPTION    VALUE 'D', 'd'.
               88  MODIFY-OPTION    VALUE 'M', 'm'.
               88  EXIT-OPTION    VALUE 'E', 'e'.


           05  WS-TERMINATE  PIC X     VALUE SPACES.
               88  TERMINATED       VALUE 'T', 't', 'N', 'n',
                                           'S', 's'.
           05  ANY-CHAR     PIC X    VALUE SPACE.

       01  SWITCHES.
           05  ON-VALUE         PIC X           VALUE 'Y'.
           05  OFF-VALUE        PIC X           VALUE 'N'.
           05  UPDT-FINISHED-SW      PIC X      VALUE 'N'.
               88  UPDT-FINISHED                VALUE 'Y'.

       01  WS-DATA-RECORD.
           05  WS-KEY.
               10  WS-LAST-NAME.
                   15  WS-LAST-NAME-CHAR OCCURS 20 TIMES  PIC X.
               10  WS-FIRST-NAME     PIC X(20).
           05  WS-ADDRESS-LINE-1     PIC X(40)  VALUE SPACES.  
           05  WS-ADDRESS-LINE-2     PIC X(40)  VALUE SPACES.  
           05  WS-PHONE     PIC X(12)   VALUE SPACES.  

       01  WS-MAIL-LIST-RECORD.
           05  WS-ML-NAME.
               10  WS-ML-NAME-CHAR PIC X OCCURS 41 TIMES.
           05  WS-ML-ADDRESS-LINE-1     PIC X(40)  VALUE SPACES.  
           05  WS-ML-ADDRESS-LINE-2     PIC X(40)  VALUE SPACES.  


       01  WS-TITLE     PIC X(50).
 
       SCREEN SECTION.                       

       01  BLANK-SCREEN.
           03 BLANK SCREEN.

       01  TUTOR-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE UPDATE DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 4 COLUMN 5 VALUE
                 'This is main program UPDATE, CHAINed to from main prog
      -         'ram DEMO.'.
           03  LINE 5 COLUMN 5 VALUE
                 'Since UPDATE was CHAINed to and not CALLed, control wi
      -          'll not return'.
           03  LINE 6 COLUMN 5 VALUE
                 'to DEMO.'.
           03  LINE 8 COLUMN 1 VALUE
                 'In this program, you may list, add, delete, or modify
      -          'records in file ISAM.DAT'.
           03  LINE 9 COLUMN 1 VALUE
                 'which was created in subprogram BUILD. If you did not 
      -          'try the CREATE option'.    
           03  LINE 10 COLUMN 1 VALUE
                 'yet, please terminate this program by responding T bel
      -          'ow, then execute'.
           03  LINE 11 COLUMN 1 VALUE
                 'DEMO again, this time selecting option C to create the
      -          ' file which is'.
           03  LINE 12 COLUMN 1 VALUE
                 'updated in this program. OK?.'.
           03  LINE 14 COLUMN 1 VALUE
                 'To terminate this program type T, then hit ENTER.'.
           03  LINE 15 COLUMN 1 HIGHLIGHT VALUE
                 'Hit ENTER by itself to continue:'.
           03  COLUMN PLUS 1 PIC X TO WS-TERMINATE.

       01  TUTOR-SCREEN-2.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE UPDATE DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 4 COLUMN 1 VALUE
                 'Ok. Since you have created file ISAM.DAT, you may now 
      -         'modify or'.
           03  LINE 5 COLUMN 1 VALUE
                 'display its contents. One advantage of the MS-COBOL in
      -          'dexed file'.
           03  LINE 6 COLUMN 1 VALUE
                 'structure is that it automatically returns records sor
      -          'ted by key when'.
           03  LINE 7 COLUMN 1 VALUE
                 'the file is read sequentially.'.
           03  LINE 9 COLUMN 1 VALUE
                 'You will now see a menu screen which will let you:'.
           03  LINE 10 COLUMN 5 VALUE
                 'List the file, creating a file of mailing labels sorte
      -          'd by last name,'.
           03  LINE 11 COLUMN 10 VALUE
                      'then first name;'.
           03  LINE 12 COLUMN 5 VALUE
                 'Add records to the file;'.
           03  LINE 13 COLUMN 5 VALUE
                 'Delete records from the file;'.
           03  LINE 14 COLUMN 5 VALUE
                 'Modify records on the file.'.
           03  LINE 17 COLUMN 1 VALUE
                 'You will return to the options menu after you have com
      -          'pleted'.
           03  LINE 18 COLUMN 1 VALUE
                 'any set of actions, so that you may modify, then list
      -          'the'.
           03  LINE 19 COLUMN 1 VALUE
                 'file, as many times as you like.'.
           03  LINE 21 COLUMN 1 HIGHLIGHT VALUE
                 'Please hit ENTER to continue.'.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.

       01  OPTION-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE UPDATE DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 6 COLUMN 1 VALUE
                 'Please select one of the following options by typing t
      -          'he first letter'.
           03  LINE 7 COLUMN 1 VALUE
                 'of the option in the space below, then hitting ENTER.
      -          'Option E'.
           03  LINE 8 COLUMN 1 VALUE
                 'followed by ENTER will end this demonstration.'.
           03  LINE 10 COLUMN 5 VALUE
              'Option L: List records in indexed file sorted by last nam
      -          'e, then first name'.
           03  LINE 11 COLUMN 15 VALUE
              'and create a mailing label file in the same order'.
           03  LINE 12 COLUMN 5 VALUE
              'Option A: Add a record to the indexed file'.
           03  LINE 13 COLUMN 5 VALUE
              'Option D: Delete a specified record in the indexed file'.
           03  LINE 14 COLUMN 5 VALUE
              'Option M: Modify a specified record in the indexed file'.
           03  LINE 16 COLUMN 5 VALUE
              'Option E: End this program'.
           03  LINE 23 COLUMN 10 HIGHLIGHT VALUE
                 'Enter option here followed by ENTER: '.
           03  COLUMN PLUS 1 PIC X TO WS-OPTION.

       01  AFTERMATH-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 20 VALUE
                 'MS-COBOL INDEXED FILE UPDATE DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 4 COLUMN 1 VALUE
                 'Action requested = '.
           03       PIC X(20) FROM WS-ACTION HIGHLIGHT.
           03  LINE 5 COLUMN 1 VALUE
                 'File status = '.
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
                  '    Do you wish to '.
           03       PIC X(6) FROM WS-ACTION HIGHLIGHT.
           03       VALUE ' any more records (Y/N)?'.
           03  LINE 20 COLUMN 10 HIGHLIGHT VALUE
                'Reply (followed by ENTER) = '.
           03  COLUMN PLUS 1 PIC X TO WS-TERMINATE.

       01  LIST-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE UPDATE DEMONSTRATION'.
           03  LINE 2 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 4 COLUMN 1 VALUE
                 'The following record was written by you to file ISAM.D
      -          'AT, and is now '.
           03  LINE 5 COLUMN 1 VALUE
                 'sorted in ascending order by LAST NAME followed by FIR
      -          'ST name.'.
           03  LINE 7 COLUMN 1   PIC X(20) FROM WS-FIRST-NAME
                                           HIGHLIGHT.
           03  LINE 8 COLUMN 1   PIC X(20) FROM WS-LAST-NAME
                                           HIGHLIGHT.
           03  LINE 9 COLUMN 1      PIC X(40) FROM WS-ADDRESS-LINE-1
                     HIGHLIGHT.
           03  LINE 10 COLUMN 1      PIC X(40) FROM WS-ADDRESS-LINE-2
                     HIGHLIGHT.
           03  LINE 11 COLUMN 1      PIC X(12) FROM WS-PHONE AUTO
                     HIGHLIGHT.
           03  LINE 13 COLUMN 1 VALUE
                'The following records were written to file MAIL.DAT to
      -         'be used for mailing'.
           03  LINE 14 COLUMN 1 VALUE
                 'labels. File status of last write = '.
           03       PIC XX FROM MAIL-LIST-STATUS HIGHLIGHT.
           03  LINE 15 COLUMN 9 VALUE
                 'File status = 00 means action was successful'.
           03  LINE 17 COLUMN 1   PIC X(41) FROM WS-ML-NAME
                                           HIGHLIGHT.
           03  LINE 18 COLUMN 1      PIC X(40) FROM WS-ML-ADDRESS-LINE-1
                     HIGHLIGHT.
           03  LINE 19 COLUMN 1      PIC X(40) FROM WS-ML-ADDRESS-LINE-2
                     HIGHLIGHT.
           03  LINE 21 COLUMN 9 VALUE
                'Do you wish to read the next record?'.
           03  LINE 22 COLUMN 12 VALUE
              'Reply ENTER by itself to continue reading the file. Type
      -       'S followed '.
           03  LINE 23 COLUMN 12 VALUE
                'by ENTER to stop reading the file.'.
           03  LINE 23 COLUMN 50  HIGHLIGHT VALUE
                'Reply = '.
           03  COLUMN PLUS 1 PIC X TO WS-TERMINATE.
                              
  
       01  NAME-ADDRESS-SCREEN.
           03  NAME-SCREEN.
            05 BLANK SCREEN.
            05 LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE UPDATE DEMONSTRATION'.
            05 LINE 2 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
            05 LINE 4 COLUMN 1 VALUE
                 'Please enter the data requested below. To exit from th
      -          'is program'.
            05 LINE 5 COLUMN 1 VALUE
                 'reply N to the question: "Do you wish to enter more da
      -          'ta?(Y/N)"'.
            05 LINE 6 COLUMN 1 VALUE
                 'when it appears on the screen.'.
            05 LINE 8 COLUMN 1 VALUE
                 'Enter FIRST name and initial  (1 to 20 characters): '.
            05 LINE 9 COLUMN 1 VALUE '[' HIGHLIGHT.
            05 LINE 9 COLUMN 2   PIC X(20) FROM WS-FIRST-NAME
                                   TO WS-FIRST-NAME.                                           
            05 LINE 9 COLUMN 22 VALUE ']' HIGHLIGHT.
            05 LINE 10 COLUMN 1 VALUE
                 'Enter LAST name  (1 to 20 characters): '.
            05 LINE 11 COLUMN 1 VALUE '[' HIGHLIGHT.
            05 LINE 11 COLUMN 2   PIC X(20) FROM WS-LAST-NAME
                                   TO WS-LAST-NAME.                                            
            05 LINE 11 COLUMN 22 VALUE ']' HIGHLIGHT.

           03  ADDRESS-SCREEN.
            05 LINE 13 COLUMN 1 VALUE
                 'Enter first address line (1 to 40 characters): '.
            05 LINE 14 COLUMN 1 VALUE '[' HIGHLIGHT.
            05 LINE 14 COLUMN 2      PIC X(40) FROM WS-ADDRESS-LINE-1
                     TO WS-ADDRESS-LINE-1.
            05 LINE 14 COLUMN 42 VALUE ']' HIGHLIGHT.
            05 LINE 15 COLUMN 1 VALUE
                 'Enter second address line (1 to 40 characters): '.
            05 LINE 16 COLUMN 1 VALUE '[' HIGHLIGHT.
            05 LINE 16 COLUMN 2      PIC X(40) TO WS-ADDRESS-LINE-2
                     FROM WS-ADDRESS-LINE-2.
            05 LINE 16 COLUMN 42 VALUE ']' HIGHLIGHT.
            05 LINE 18 COLUMN 1 VALUE
                 'Enter phone number (XXX-XXXX or XXX-XXX-XXXX): '.
            05 LINE 19 COLUMN 1 VALUE '[' HIGHLIGHT.
            05 LINE 19 COLUMN 2      PIC X(12) FROM WS-PHONE
                     TO WS-PHONE.
            05 LINE 19 COLUMN 14 VALUE ']' HIGHLIGHT.
            05 LINE 21 COLUMN 10 VALUE
                'If data is OK, hit ENTER to write to the file. You can
      -         'use BACK TAB to '.
            05 LINE 22 COLUMN 15 VALUE
              'return to previous fields and modify data with cursor pos
      -       'itioning.'.
            05 LINE 23 COLUMN 15  VALUE
                'keys. '.
            05 LINE 23 COLUMN 21 HIGHLIGHT VALUE
                'Hit ENTER here to continue: '.
            05 COLUMN PLUS 1 PIC X TO ANY-CHAR.
                              
       01  EOF-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 17 VALUE
                 'MS-COBOL INDEXED FILE UPDATE DEMONSTRATION'.
           03  LINE 3 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 6 COLUMN 1 VALUE
                 'You have reached the end of the file ISAM.DAT.'.
           03  LINE 8 COLUMN 1 VALUE
              'You have also built the line sequential file MAIL.DAT, a 
      -       'sorted file'.
           03  LINE 9 COLUMN 1 VALUE
              'of mailing labels. You will now return to the options scr
      -       'een, where '.
           03  LINE 10 COLUMN 1 VALUE
              'you can again modify or list ISAM.DAT. When you choose op
      -       'tion E to end'.
           03  LINE 11 COLUMN 1 VALUE
              'this demonstration and return to the operating system, yo
      -       'u may use the'.
           03  LINE 12 COLUMN 1 VALUE
              'system TYPE command to list file MAIL.DAT.'.
           03  LINE 18  COLUMN 1 HIGHLIGHT VALUE
                 'Please hit ENTER to return to the options menu: '.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.


       01  FINAL-SCREEN.
           03 BLANK SCREEN.
           03  LINE 1 COLUMN 21 VALUE
                 '  END OF MICROSOFT MS-COBOL DEMONSTRATION'.
           03  LINE 3 COLUMN 15     PIC X(50) FROM WS-TITLE HIGHLIGHT.
           03  LINE 5 COLUMN 1 VALUE
                 'Thank you for taking part in this demonstration of '.
           03  LINE 6 COLUMN 1 VALUE
                 'the features of Microsoft MS-COBOL.'.
           03  LINE 8 COLUMN 1 VALUE
              'After hitting ENTER to end this program, you can use the
      -           'system TYPE '.
           03  LINE 9 COLUMN 5 VALUE
                 'command to list file MAIL.DAT and see the mailing list
      -           ' you have built. '.
           03  LINE 16 COLUMN 1 HIGHLIGHT VALUE
                 'Please hit ENTER to end this program.'.
           03  COLUMN PLUS 1 PIC X TO ANY-CHAR.



       PROCEDURE DIVISION CHAINING WS-TITLE.
 
       P000-MAIN-LINE.
           DISPLAY TUTOR-SCREEN.
           ACCEPT TUTOR-SCREEN.

           IF TERMINATED
               STOP RUN.

           OPEN I-O ISAM-FILE.
           IF ISAM-STATUS NOT = '00'
               DISPLAY ' FILE OPEN FAILURE. JOB CANCELLED'
               DISPLAY 'FILE STATUS = ', ISAM-STATUS
               DISPLAY 'TYPE ANY CHARACTER TO END JOB'
               ACCEPT ANY-CHAR
           ELSE
               DISPLAY TUTOR-SCREEN-2
               ACCEPT TUTOR-SCREEN-2
               PERFORM P100-GET-DATA
                    UNTIL UPDT-FINISHED.

           CLOSE ISAM-FILE.
           DISPLAY BLANK-SCREEN.
           STOP RUN.


       P100-GET-DATA.
           MOVE SPACE TO WS-TERMINATE.
           MOVE SPACE TO WS-OPTION.
           MOVE SPACES TO WS-DATA-RECORD.
           DISPLAY OPTION-SCREEN.
           ACCEPT OPTION-SCREEN.

           IF LIST-OPTION
                MOVE 'MAIL LIST' TO WS-ACTION
                PERFORM P110-START-FILE
                OPEN OUTPUT MAIL-LIST-FILE
                PERFORM P200-MAIL-LIST
                    UNTIL TERMINATED
                CLOSE MAIL-LIST-FILE
           ELSE IF ADD-OPTION
                MOVE 'ADD' TO WS-ACTION
                PERFORM P300-ADD
                    UNTIL TERMINATED
           ELSE IF DELETE-OPTION
                MOVE 'DELETE' TO WS-ACTION
                PERFORM P400-DELETE
                    UNTIL TERMINATED
           ELSE IF MODIFY-OPTION
                MOVE 'MODIFY' TO WS-ACTION
                PERFORM P500-MODIFY
                    UNTIL TERMINATED
           ELSE IF EXIT-OPTION
                DISPLAY FINAL-SCREEN
                ACCEPT FINAL-SCREEN
                MOVE ON-VALUE TO UPDT-FINISHED-SW 
           ELSE
               NEXT SENTENCE.


       P110-START-FILE.
            MOVE SPACES TO ISAM-KEY.
            START ISAM-FILE
                KEY IS GREATER THAN ISAM-KEY
                INVALID KEY PERFORM P900-START-ERROR.

       
       P200-MAIL-LIST.
           PERFORM P800-READ-ISAM.
         
           IF NOT TERMINATED
               PERFORM P210-BUILD-MAIL
               DISPLAY LIST-SCREEN 
               ACCEPT LIST-SCREEN.

       P210-BUILD-MAIL.
      *       PREPARE MAIL LIST RECORD. PLACE FIRST NAME AND
      *       INITIAL ON LINE, SEARCH FOR END, THEN MOVE LAST
      *       NAME TO LINE AND WRITE TO FILE MAIL.DAT.

           MOVE WS-ADDRESS-LINE-1 TO WS-ML-ADDRESS-LINE-1.
           MOVE WS-ADDRESS-LINE-2 TO WS-ML-ADDRESS-LINE-2.
           MOVE WS-FIRST-NAME     TO WS-ML-NAME.

           IF WS-FIRST-NAME = SPACES
               MOVE 1 TO IIX
           ELSE
               PERFORM P220-NOTHING VARYING IIX FROM 20 BY -1
                   UNTIL (WS-ML-NAME-CHAR (IIX) NOT = SPACE) 
                   OR (IIX < 1)
               ADD 2 TO IIX.
      *    ** IIX IS LOCATION FOR START OF LAST NAME
   
      *    *** FIND FIRST NON-BLANK IN LAST NAME

           IF WS-LAST-NAME = SPACES
               MOVE 1 TO WS-START, WS-END
           ELSE
               PERFORM P220-NOTHING VARYING JIX FROM 1 BY 1
                   UNTIL (WS-LAST-NAME-CHAR (JIX) NOT = SPACE) 
                   OR (JIX > 20)
               MOVE JIX TO WS-START
               PERFORM P220-NOTHING VARYING JIX FROM 20 BY -1
                   UNTIL (WS-LAST-NAME-CHAR (JIX) NOT = SPACE) 
                   OR (JIX < 1)
               MOVE JIX TO WS-END.
      *      **** MOVE LAST NAME TO LINE

           PERFORM P230-MOVE-NAME VARYING KIX FROM WS-START BY 1
               UNTIL KIX > WS-END.

           PERFORM P240-WRITE-MAIL-LIST.

       P220-NOTHING.
           EXIT.

       P230-MOVE-NAME.
           MOVE WS-LAST-NAME-CHAR (KIX) TO WS-ML-NAME-CHAR (IIX).
           ADD 1 TO IIX.

       P240-WRITE-MAIL-LIST.
           WRITE MAIL-LIST-RECORD FROM WS-ML-NAME.
           WRITE MAIL-LIST-RECORD FROM WS-ML-ADDRESS-LINE-1.
           WRITE MAIL-LIST-RECORD FROM WS-ML-ADDRESS-LINE-2.
           MOVE SPACES TO MAIL-LIST-RECORD.
           WRITE MAIL-LIST-RECORD.

       P300-ADD.
           MOVE SPACES TO WS-DATA-RECORD.
           DISPLAY NAME-ADDRESS-SCREEN. 
           ACCEPT NAME-ADDRESS-SCREEN.
         
           PERFORM P700-WRITE-ISAM.
         
           DISPLAY AFTERMATH-SCREEN. 
           ACCEPT AFTERMATH-SCREEN.

       P400-DELETE.
           MOVE SPACES TO WS-DATA-RECORD.
           DISPLAY NAME-SCREEN. 
           ACCEPT NAME-SCREEN.
           PERFORM P820-DELETE-ISAM.
         
           DISPLAY AFTERMATH-SCREEN. 
           ACCEPT AFTERMATH-SCREEN.

       P500-MODIFY.
           MOVE SPACES TO WS-DATA-RECORD.
           DISPLAY NAME-SCREEN. 
           ACCEPT NAME-SCREEN.
           PERFORM P810-RANDOM-READ-ISAM.

           IF ISAM-STATUS = '00'
               DISPLAY NAME-SCREEN
               DISPLAY ADDRESS-SCREEN
               ACCEPT ADDRESS-SCREEN
               PERFORM P710-REWRITE-ISAM.

           DISPLAY AFTERMATH-SCREEN. 
           ACCEPT AFTERMATH-SCREEN.

       P700-WRITE-ISAM.
           WRITE ISAM-RECORD FROM WS-DATA-RECORD.

       P710-REWRITE-ISAM.
           REWRITE ISAM-RECORD FROM WS-DATA-RECORD.

       P800-READ-ISAM.
           READ ISAM-FILE NEXT INTO WS-DATA-RECORD
                AT END
                      MOVE 'T' TO WS-TERMINATE
                      DISPLAY EOF-SCREEN
                      ACCEPT EOF-SCREEN.

       P810-RANDOM-READ-ISAM.
           MOVE WS-DATA-RECORD TO ISAM-RECORD.
           READ ISAM-FILE INTO WS-DATA-RECORD.

       P820-DELETE-ISAM.
           MOVE WS-DATA-RECORD TO ISAM-RECORD.
           DELETE ISAM-FILE RECORD.

       P900-START-ERROR.
           MOVE 'T' TO WS-TERMINATE.
           DISPLAY EOF-SCREEN.
           ACCEPT EOF-SCREEN.
