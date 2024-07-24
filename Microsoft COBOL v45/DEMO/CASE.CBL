      $set ans85 noosvs comp mf
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                      CASE.CBL                            *
      *                                                          *
      * This program converts the case of COBOL source code      *
      * files in several ways, producing, for example, uppercase *
      * reserved words and lower case data names.                *
      *                                                          *
      * Instructions for use are presented when it is first      *
      * executed.                                                *
      *                                                          *
      * This source file actually contains two separate          *
      * programs, one called from the other. This type of source *
      * file is known as a multi-program source. Compiling this  *
      * source file will result in the creation of two separate  *
      * OBJs, as if two separate programs had been compiled, one *
      * after the other. The two OBJs will be called CASE and    *
      * CASECONV, CASECONV taking its name from the PROGRAM-ID   *
      * line in the second program.                              *
      *                                                          *
      * Compile the program and link the two OBJs created in the *
      * usual way.                                               *
      *                                                          *
      ************************************************************
       identification division.
       program-id. case.
       environment division.
       file-control.
           select input-file assign input-file-name
               organization is line sequential
               file status is file-status.

           select output-file assign output-file-name
               organization is line sequential
               file status is file-status.

       data division.

       file section.

       fd input-file.
       01 input-record                 pic x(80).

       fd output-file.
       01 output-record                pic x(80).

       working-storage section.
       01      temp-00   .
           03     temp-00-0101 pic x(0078) value "Instructions for using
      -    " the CASE utility for altering the case of COBOL source:".
           03 filler           pic x(0082).
           03     temp-00-0301 pic x(0077) value "CASE <srce-file-spec>
      -    "<target-file-spec> <resvd-word> <data-name> <procedure>".
           03 filler           pic x(0086).
           03     temp-00-0504 pic x(0062) value "src-file-spec: full pa
      -    "thname and file name for the source file".
           03 filler           pic x(0015).
           03     temp-00-0601 pic x(0065) value "target-file-spec: full
      -    " pathname and file name for the target file".
           03 filler           pic x(0021).
           03     temp-00-0707 pic x(0060) value "resvd-word: U means co
      -    "nvert all reserved words to UPPER case".
           03 filler           pic x(0032).
           03     temp-00-0819 pic x(0029) value "L means convert to LOW
      -    "ER case".
           03 filler           pic x(0051).
           03     temp-00-0919 pic x(0062) value "F means convert first
      -    "character to UPPER, all others to LOWER ".
           03     temp-00-1001 pic x(0062) value "       data-name: U me
      -    "ans convert all data names to UPPER case".
           03 filler           pic x(0036).
           03     temp-00-1119 pic x(0029) value "L means convert to LOW
      -    "ER case".
           03 filler           pic x(0051).
           03     temp-00-1219 pic x(0062) value "F means convert first
      -    "character to UPPER, all others to LOWER ".
           03     temp-00-1301 pic x(0079) value "       procedure: U me
      -    "ans convert all procedure and section names to UPPER case".
           03 filler           pic x(0019).
           03     temp-00-1419 pic x(0029) value "L means convert to LOW
      -    "ER case".
           03 filler           pic x(0051).
           03     temp-00-1519 pic x(0061) value "F means convert first
      -    "character to UPPER, all others to LOWER".
           03 filler           pic x(0081).
           03     temp-00-1701 pic x(0054) value "eg. CASE C:\WORK\MYPRO
      -    "G.CBL D:\MYDIR\NEWPROG.CBL U F L".
           03 filler           pic x(0106).
           03     temp-00-1901 pic x(0080) value "The other use of this
      -    "utility is to convert a COBOL source file to ""SENTENCE"".
      -    "".
           03     temp-00-2001 pic x(0080) value "ie. the first characte
      -    "r found after a period is UPPER case, all others are LOWER".
           03 filler           pic x(0080).
           03     temp-00-2201 pic x(0050) value "eg. CASE C:\WORK\MYPRO
      -    "G.CBL D:\MYDIR\NEWPROG.CBL S".
           03 filler           pic x(0030).
       77  prog-line-no                pic 9(6) comp.
       77  prog-line-no-disp           pic z(6).
       77  start-ind                   pic 99 comp.
       77  char-ind                    pic 99 comp.
       77  buffer-char-ind             pic 99 comp.

       77  file-flag                   pic x.
           88  end-of-file                 value "Y".

       77  error-flag                  pic x.
           88 error-found                  value "Y".

       77  file-status                 pic xx.

       77  input-file-name             pic x(80).

       77  output-file-name            pic x(80).

       77  q-answer                    pic x.

       77  no-list                     pic x(6).
           88  no-list-true  value "Nolist" "NOLIST" "nolist" "NoList".
       77  syntax-error                pic x(80)
                value "Syntax error in parameters - Program Terminated".
       01  out-err.
           03  oe1                     pic x(20)
                                            value "Target file exists:".
           03  oe2                     pic x(15) value "Are you sure?".
       01  in-err.
           03  ie1                     pic x(27)
                                     value "Source file not found for:".
           03  in-err-fname            pic x(53).
       01  dup-err.
           03  de1                     pic x(37)
                           value "Source and target file are the same:".
           03  dup-err-fname           pic x(43).

       78  upper-case      value "UPPER-CASE".
       78  lower-case      value "lower-case".
       78  first-char      value "First-Character-Upper".
       78  sentence-case   value "Sentence-type-case".

       01  final-message-1.
           03  fm1      pic x(31) value "            About to convert:".
           03  disp-inp pic x(49).
           03  fm2      pic x(31) value "                          to:".
           03  disp-out pic x(49).
       01  final-message-2-1.
           03  fm3     pic x(31) value " Converting Reserved words to:".
           03  res-inp pic x(49).
           03  fm4     pic x(31) value "                Data names to:".
           03  dat-inp pic x(49).
           03  fm5     pic x(31) value "           Procedure names to:".
           03  pro-inp pic x(49).
       01  final-message-2-2.
           03  fm6     pic x(31) value "    Converting entire file to:".
           03  fm7     pic x(49) value "Sentence case".
       01  final-message-3.
           03  fm8     pic x(31) value "--- No screen listing ---".
       01  final-message-4.
           03  fm9     pic x(31) value "    Do you wish to continue ? ".

       01  command-tail.
           03  command-tail-char       pic x occurs 81.

       01  buffer-string.
           03  buffer-char             pic x occurs 80.

       01  case-linkage.
           03  case-flags.
               05  lnk-reserved-case       pic x.
                   88  lnk-reserved-case-ok
                                  value "u" "l" "f" "U" "L" "F" "S" "s".
      * note that the resreved case flag is also used to determine if
      * the conversion is to be a "sentence" type conversion.
               05  lnk-data-name-case      pic x.
                   88  lnk-data-name-case-ok
                                          value "u" "l" "f" "U" "L" "F".
               05  lnk-proc-case           pic x.
                   88  lnk-proc-case-ok
                                          value "u" "l" "f" "U" "L" "F".
           03  record-area             pic x(80).

       procedure division.
       runstart section.
           display spaces upon crt
           perform get-command-line
           if not error-found
               perform test-case-flags
               if error-found
                   perform command-line-error
               else
                   perform open-input-file
                   if error-found
                       perform input-file-error
                   else
                       display spaces upon crt
                       perform check-output-file
                       if not error-found
                           open output output-file
                           perform convert-file
                           close input-file
                           close output-file
                       end-if
                   end-if
               end-if
           end-if
           exit program
           stop run.

       get-command-line section.
           accept command-tail from command-line
           if command-tail = spaces
               perform command-line-prompt
               display "Enter Parameters"
               accept command-tail
               if command-tail = spaces
                   set error-found to true
                   display syntax-error
               end-if
           end-if
           if not error-found
               perform split-off-names
               if input-file-name  = spaces
                       or output-file-name = spaces
                       or lnk-reserved-case = spaces
                       or lnk-data-name-case = spaces
                       or lnk-proc-case = spaces
                   perform command-line-error
               else
                   if input-file-name = output-file-name
                       perform duplicate-file-name-error
                   end-if
               end-if
           end-if.

       open-input-file section.
           open input input-file
           if file-status not = "00"
               set error-found to true
               close input-file
           end-if.

       check-output-file section.
           open input output-file
           if file-status = "00"
               close output-file
               perform check-for-overwrite
           end-if.

       convert-file section.
           move input-file-name to disp-inp
           move output-file-name to disp-out
           evaluate lnk-reserved-case
               when "U"
               when "u"
                   move upper-case to res-inp
               when "L"
               when "l"
                   move lower-case to res-inp
               when "F"
               when "f"
                   move first-char to res-inp
               when "S"
               when "s"
                   move sentence-case to res-inp
           end-evaluate
           evaluate lnk-data-name-case
               when "U"
               when "u"
                   move upper-case to dat-inp
               when "L"
               when "l"
                   move lower-case to dat-inp
               when "F"
               when "f"
                   move first-char to dat-inp
           end-evaluate
           evaluate lnk-proc-case
               when "U"
               when "u"
                   move upper-case to pro-inp
               when "L"
               when "l"
                   move lower-case to pro-inp
               when "F"
               when "f"
                   move first-char to pro-inp
           end-evaluate
           display final-message-1 at 0301
           if lnk-reserved-case = "S" or "s"
               display final-message-2-2 at 0601
           else
               display final-message-2-1 at 0601
           end-if
           if no-list-true
               display final-message-3 at 1001
           end-if
           display final-message-4 at 1201
           move "Y" to q-answer
           accept q-answer at 1233

           if q-answer = "y" or "Y"
               display "Converting - Please Wait" at 1401
               perform read-input-file
               move 1 to prog-line-no
               perform until end-of-file
                   move prog-line-no to prog-line-no-disp
                   move input-record to record-area
                   call "CASECONV" using case-linkage
                   move record-area to output-record
                   write output-record
                   if not no-list-true
                       move prog-line-no-disp to output-record(1:6)
                       display output-record
                   else
                       display prog-line-no-disp at 1425
                   end-if
                   add 1 to prog-line-no
                   perform read-input-file
               end-perform
               display " "
               display " "
               display "Conversion complete"
           else
               set error-found to true
           end-if.

       split-off-names section.
           move 1 to start-ind
           perform find-leading-spaces
           perform get-input-file-name
           perform find-leading-spaces
           perform get-output-file-name
           perform find-leading-spaces
           perform get-reserved-flag
           if lnk-reserved-case = "S" or "s"
               move "S" to lnk-data-name-case
               move "S" to lnk-proc-case
           else
               perform find-leading-spaces
               perform get-data-name-flag
               perform find-leading-spaces
               perform get-proc-name-flag
           end-if
           perform find-leading-spaces
           perform get-nolist-flag.

       find-leading-spaces section.
           perform varying char-ind from start-ind by 1 until
                   (char-ind > 80)
                 or not (command-tail-char(char-ind) = (spaces or ","))
           end-perform
           move char-ind to start-ind.

       get-input-file-name section.
           move spaces to buffer-string
           move 1 to buffer-char-ind
           perform varying char-ind from start-ind by 1 until
                   char-ind > 80 or command-tail-char(char-ind) = spaces
               move command-tail-char(char-ind) to
                                            buffer-char(buffer-char-ind)
               add 1 to buffer-char-ind
           end-perform
           move buffer-string to input-file-name
           move char-ind to start-ind.

       get-output-file-name section.
           move spaces to buffer-string
           move 1 to buffer-char-ind
           perform varying char-ind from start-ind by 1 until
                   char-ind > 80 or command-tail-char(char-ind) = spaces
               move command-tail-char(char-ind) to
                                            buffer-char(buffer-char-ind)
               add 1 to buffer-char-ind
           end-perform
           move buffer-string to output-file-name
           move char-ind to start-ind.

       get-reserved-flag section.
           if start-ind < 80
               move command-tail-char(start-ind) to lnk-reserved-case
               add 1 to start-ind
           end-if.

       get-data-name-flag section.
           if start-ind < 80
               move command-tail-char(start-ind) to lnk-data-name-case
               add 1 to start-ind
           end-if.

       get-proc-name-flag section.
           if start-ind < 80
               move command-tail-char(start-ind) to lnk-proc-case
               add 1 to start-ind
           end-if.

       get-nolist-flag section.
           move spaces to buffer-string
           move 1 to buffer-char-ind
           perform varying char-ind from start-ind by 1 until
                   char-ind > 80 or command-tail-char(char-ind) = spaces
               move command-tail-char(char-ind) to
                                            buffer-char(buffer-char-ind)
               add 1 to buffer-char-ind
           end-perform
           move buffer-string to no-list.

       check-for-overwrite section.
           display out-err at 0101
           move "Y" to q-answer
           accept q-answer at 0137
           if q-answer = "y" or "Y"
               next sentence
           else
               set error-found to true
           end-if.

       input-file-error section.
           set error-found to true
           move input-file-name to in-err-fname
           display in-err.

       command-line-error section.
           perform command-line-prompt
           display syntax-error
           set error-found to true.

       command-line-prompt section.
           display temp-00.

       duplicate-file-name-error section.
           move input-file-name to dup-err-fname
           set error-found to true
           display dup-err.

       read-input-file section.
           read input-file
               at end
                   set end-of-file to true
           end-read.

       test-case-flags section.
           if lnk-reserved-case = "S" or "s"
               next sentence
           else
               if lnk-reserved-case-ok and
                              lnk-data-name-case-ok and lnk-proc-case-ok
                   next sentence
               else
                   set error-found to true
               end-if
           end-if.

       end program case.


       identification division.
       program-id. caseconv.
      ***************************************************************
      * This program accepts one 80 character line of COBOL code in its
      * linkage section. This line of code is returned to the calling
      * program with the line of code changed according to the
      * following rules:
      *
      * There are 3 parameters passed in linkage section:
      *
      *   lnk-reserved-case        can have values U, L and F
      *   lnk-data-name-case       can have values U, L and F
      *   lnk-proc-case            can have values U, L and F
      *
      *   the first parameter controls the case of reserved words
      *   the second parameter controls the case of data names
      *   the third parameter controls the procedure and section names
      *
      *   All the above can be independantly changed so that they are
      *   in:
      *
      *        UPPER-CASE
      *        lower-case or
      *        First-Character-Upper-Case
      *
      *   according to the respective value of the parameter
      *
      *   One additional function of this program is controlled by
      *   passing the value "S" in lnk-reserved-case. In this case, the
      *   other parameters are ignored and the entire line is converted
      *   so that the case is made "Sentence like". ie. the first
      *   alphabetic character found after a period is capitalised.
      ***************************************************************
       working-storage section.
       01  temp-char                   pic x.
       01  temp-char-9 redefines temp-char pic 99 comp.
      *   This next variable, and its associated 88 is used to determine
      *   whether to capitalize the next character in the case of "F"
      *   type conversion. The setting in the 88 is to capitalize after
      *   a space, a hyphen etc. This can be changed to suit your
      *   requirements.

       01  prev-char                   pic x.
           88  prev-char-separator
                           value "(" ":" "-" space "0" thru "9".
       77  ind-1                       pic 9(4) comp.
       77  ind-2                       pic 9(4) comp.
       78  editfun                     value x"bb".
       78  spacebreak                  value x"c5".
       78  yes                         value 1.
       78  nay                         value 0.
       01  literal                     pic 99 comp value zero.
       01  reserved                    pic 99 comp value zero.
       01  new-sentence-expected       pic 99 comp value 1.
       01  start-of-sentence           pic 99 comp value 1.
       01  perf-name-expected          pic 99 comp value zero.
       01  alt1-name-expected          pic 99 comp value zero.
       01  alt2-name-expected          pic 99 comp value zero.
       01  go-name-expected            pic 99 comp value zero.
       01  pic-name-expected           pic 99 comp value zero.
       01  sub                         pic 99 comp value zero.
       01  start-sub                   pic 99 comp value zero.
       01  end-sub                     pic 99 comp value zero.
       01  res-sub                     pic 99 comp value zero.
       01  res-len                     pic 99 comp value zero.
       01  res-word-buffer.
         02  res-word-buffer-char      pic x occurs 65.
       01  filler redefines res-word-buffer.
        02 res19.
         03 res18.
          04 res17.
           05 res16.
            06 res15.
             07 res14.
              08 res13.
               09 res12.
                10 res11.
                 11 res10.
                  12 res09.
                   13 res08.
                    14 res07.
                     15 res06.
                      16 res05.
                       17 res04.
                        18 res03.
                         19 res02        pic xx.
                         19 filler       pic x.
                        18 filler        pic x.
                       17 filler         pic x.
                      16 filler          pic x.
                     15 filler           pic x.
                    14 filler            pic x.
                   13 filler             pic x.
                  12 filler              pic x.
                 11 filler               pic x.
                10 filler                pic x.
               09 filler                 pic x.
              08 filler                  pic x.
             07 filler                   pic x.
            06 filler                    pic x.
           05 filler                     pic x.
          04 filler                      pic x.
         03 filler                       pic x.
        02 filler                        pic x(46).
       01  char-to-bin.
         02 char                       pic x.
       01  char9 redefines char-to-bin pic 99 comp.
       01  ulcase                      pic 99 comp value 0.
       01  locase                      pic 99 comp value 1.
       01  editstart                   pic 9(4) comp value zero.
       01  templen                     pic 9(4) comp value zero.
       01  editlen                     pic 9(4) comp value zero.
       01  editfunction                pic 9(4) comp value 0.

      *list of no of reserved words for ANS85
       78  res-word-count-2   value 24.
       78  res-word-count-3   value 24.
       78  res-word-count-4   value 51.
       78  res-word-count-5   value 43.
       78  res-word-count-6   value 48.
       78  res-word-count-7   value 41.
       78  res-word-count-8   value 40.
       78  res-word-count-9   value 23.
       78  res-word-count-10  value 23.
       78  res-word-count-11  value 17.
       78  res-word-count-12  value 15.
       78  res-word-count-13  value 9.
       78  res-word-count-14  value 6.
       78  res-word-count-15  value 4.
       78  res-word-count-16  value 2.
       78  res-word-count-19  value 1.

       01 r2tab    pic x(48) value "ATBYCDFDGOIDIFINISNOOFONORRDSDTOUPCF
      -"CHDEPFPHRFRH".
       01 filler redefines r2tab.
         02  r2entry pic xx occurs res-word-count-2.
       01 r3tab    pic x(72) value "ADDALLANDARECRTDAYEGIEMIENDEOPESIFOR
      -"KEYNOTOFFPICRUNSETTABTOPUSEI-OSUMANY".
       01 filler redefines r3tab.
         02  r3entry pic xxx occurs res-word-count-3.
       01 r4tab.
        02 filler pic x(128) value "ALSOAREACALLCOMPCOPYCORRDATADATEDOWN
      -"ELSEEXITFILEFROMINTOJUSTKEPTLEFTLESSLINEMODEMOVENEXTOPENPAGEREAD
      -"REELSAMESENDSIGNSIZESORTSTOP".
        02 filler pic x(76) value
      -"TAPETEXTTHANTHENTHRUTIMETYPEUNITUPONWHENWITHZEROSYNCCODELASTPLUS
      -"TESTTHENTRUE".
       01 filler redefines r4tab.
         02  r4entry pic x(4) occurs res-word-count-4.
       01 r5tab.
        02 filler pic x(128) value "AFTERALTERAREASBLANKBLOCKCLOSECOBOLC
      -"OMMACOUNTEQUALERROREVERYFIRSTINDEXINPUTLABELLIMITLINESMERGEQUEUE
      -"QUOTERERUNSPACESTARTSYSINTAB".
        02 filler pic x(87) value
      -"LETIMESUNTILUSAGEUSINGVALUEWORDSWRITEZEROSENTERRIGHTFINALGROUPRE
      -"SETCLASSORDEROTHERPURGE".
       01 filler redefines r5tab.
         02  r5entry pic x(5) occurs res-word-count-5.
       01 r6tab.
        02 filler pic x(128) value "ACCEPTACCESSASSIGNAUTHORBEFOREBOTTOM
      -"CANCELCOMMITCOMP-3CURSORDELETEDIVIDEENABLEEXTENDFILLERGIVINGLENG
      -"THLIMITSLINAGEMANUALMEMORYNA".
        02 filler pic x(124) value
      -"TIVEOCCURSOUTPUTQUOTESRANDOMRECORDRETURNREWINDSEARCHSELECTSOURCE
      -"SPACESSTATUSSTRINGSWITCHSYSOUTUNLOCKVALUESZEROESCOMP-3COLUMN".
        02 filler pic x(42) value
      -"DETAILREPORTNUMBERBINARYCOMMONEND-IFGLOBAL".
       01 filler redefines r6tab.
         02  r6entry pic x(6) occurs res-word-count-6.
       01 r7tab.
        02 filler pic x(128) value "COMPUTECONSOLEDISABLEDISPLAYDYNAMICF
      -"OOTINGGREATERINDEXEDINSPECTINVALIDLEADINGLINKAGEMESSAGEMODULESNU
      -"MERICOMITTEDPERFORMPICTUREPO".
        02 filler pic x(124) value
      -"INTERPROCEEDPROGRAMRECEIVERECORDSRELEASEREMOVALRENAMESRESERVEREW
      -"RITEROUNDEDSECTIONSEGMENTTHROUGHVARYINGINITIALCONTROLHEADING".
        02 filler pic x(35) value
      -"REPORTSCONTENTEND-ADDPADDINGREPLACE".
       01 filler redefines r7tab.
         02  r7entry pic x(7) occurs res-word-count-7.
       01 r8tab.
        02 filler pic x(128) value "CODE-SETCONTAINSCURRENCYDIVISIONEXCE
      -"SS-3FORMFEEDJAPANESEMULTIPLEMULTIPLYNEGATIVEOPTIONALOVERFLOWPOSI
      -"TIONPOSITIVEREVERSEDROLLBACK".
        02 filler pic x(128) value
      -"SENTENCESEPARATESEQUENCESTANDARDSUBTRACTSYMBOLICTALLYINGTERMINAL
      -"TRAILINGUNSTRINGCONTROLSGENERATEINDICATEINITIATEPRINTINGSUPPRESS
      -"".
        02 filler pic x(64) value
      -"RELATIVESECURITYALPHABETCONTINUEEND-READEVALUATEEXTERNALEND-CALL
      -"".
       01 filler redefines r8tab.
         02  r8entry pic x(8) occurs res-word-count-8.
       01 r9tab.
        02 filler pic x(126) value "ADVANCINGAUTOMATICCHARACTERCRT-UNDER
      -"DEBUGGINGDELIMITEDDELIMITERDEPENDINGEXCEPTIONEXCLUSIVEJUSTIFIEDP
      -"ROCEDUREREDEFINESREMAINDER".
        02 filler pic x(81) value
      -"REPLACINGREPORTINGTERMINATEASCENDINGALTERNATECOLLATINGEND-STARTE
      -"ND-WRITEREFERENCE".
       01 filler redefines r9tab.
         02  r9entry pic x(9) occurs res-word-count-9.
       01 r10tab.
        02 filler pic x(090) value "ALPHABETICAREA-VALUECHARACTERSDUPLIC
      -"ATESPROCEDURESREFERENCESSEQUENTIALSORT-MERGESTANDARD-1".
        02 filler pic x(060) value "DEBUG-ITEMDEBUG-LINEDEBUG-NAMEHIGH-V
      -"ALUEPROGRAM-IDDESCENDING".
        02 filler pic x(080) value "CONVERTINGEND-DELETEEND-RETURNEND-SE
      -"ARCHEND-STRINGINITIALIZESTANDARD-2END-DIVIDE".
       01 filler redefines r10tab.
         02  r10entry pic x(10) occurs res-word-count-10.
       01 r11tab.
        02 filler pic x(088) value "CLOCK-UNITSDEBUG-SUB-1DEBUG-SUB-2DEB
      -"UG-SUB-3DESTINATIONEND-OF-PAGEENVIRONMENTHIGH-VALUES".
        02 filler pic x(033) value "SUB-QUEUE-1SUB-QUEUE-2SUB-QUEUE-3".
        02 filler pic x(011) value "I-O-CONTROL".
        02 filler pic x(055) value
           "DAY-OF-WEEKEND-COMPUTEEND-PERFORMEND-RECEIVEEND-REWRITE".
       01 filler redefines r11tab.
         02  r11entry pic x(11) occurs res-word-count-11.
       01 r12tab.
        02 filler pic x(084) value "COMMAND-LINEDATE-WRITTENDECLARATIVES
      -"FILE-CONTROLINPUT-OUTPUTINSTALLATIONORGANIZATION".
        02 filler pic x(096) value "SYNCHRONIZEDLINE-COUNTERPAGE-COUNTER
      -"ALPHANUMERICEND-EVALUATEEND-MULTIPLYEND-SUBTRACTEND-UNSTRING".
       01 filler redefines r12tab.
         02  r12entry pic x(12) occurs res-word-count-12.
       01 r13tab.
        02 filler pic x(078) value "COMMUNICATIONCOMPUTATIONALCONFIGURAT
      -"IONCORRESPONDINGDATE-COMPILEDDECIMAL-POINT".
        02 filler pic x(039) value "LOCKLOW-VALUESEGMENT-LIMITSPECIAL-NA
      -"MES".
       01 filler redefines r13tab.
         02  r13entry pic x(13) occurs res-word-count-13.
       01 r14tab.
        02 filler pic x(084) value "DEBUG-CONTENTSIDENTIFICATIONLINAGE-C
      -"OUNTERLOCKLOW-VALUESNUMERIC-EDITEDPACKED-DECIMAL".
       01 filler redefines r14tab.
         02  r14entry pic x(14) occurs res-word-count-14.
       01 r15tab.
        02 filler pic x(060) value "COMPUTATIONAL-3OBJECT-COMPUTERSOURCE
      -"-COMPUTERWORKING-STORAGE".
       01 filler redefines r15tab.
         02  r15entry pic x(15) occurs res-word-count-15.
       01 r16tab.
        02 filler pic x(032) value "ALPHABETIC-LOWERALPHABETIC-UPPER".
       01 filler redefines r16tab.
         02  r16entry pic x(16) occurs res-word-count-16.
       01 r19tab.
        02 filler pic x(019) value "ALPHANUMERIC-EDITED".
       01 filler redefines r19tab.
         02  r19entry pic x(19) occurs res-word-count-19.

       01  ws-case-linkage.
           03  ws-case-flags.
               05  def-reserved-case       pic x.
               05  def-sentence-case redefines def-reserved-case pic x.
               05  def-data-name-case      pic x.
               05  def-proc-case           pic x.
           03  so-rec.
               05  so-rec-chr             pic x occurs 80.

       linkage section.
       01  case-linkage.
           03  case-flags.
               05  lnk-reserved-case       pic x.
               05  lnk-data-name-case      pic x.
               05  lnk-proc-case           pic x.
           03  record-area             pic x(80).

       procedure division using case-linkage.
       main-prog section.
           move case-linkage to ws-case-linkage.
           if ws-case-flags = spaces or so-rec = spaces
               next sentence
           else
               perform case
               move ws-case-linkage to case-linkage.
           exit program.
           stop run.

       case section.
           move nay to perf-name-expected.
           move nay to alt1-name-expected.
           move nay to alt2-name-expected.
           move nay to go-name-expected.
           move nay to pic-name-expected.
           move nay to literal.
       case1.
           move 8 to start-sub.
           if so-rec-chr(7) = "*"
              go to case-end.
       case2.
           if new-sentence-expected = 1
               move 1 to start-of-sentence
           else
               move 0 to start-of-sentence.
           perform next-word.
           if start-sub > 72
              go to case-end.
           if literal = yes
              move end-sub to start-sub
              go to case2.
           move start-sub to sub.
           if reserved = yes
              if def-reserved-case = "N"
                 move end-sub to start-sub
                 go to case2.
           if pic-name-expected = yes
              go to case3.
           if reserved = nay
              go to case4.
       case3.
           move res-len to editlen.
           move sub to editstart.
           if def-sentence-case = "S" or "s"
               perform convert-to-sentence
           else
           if def-reserved-case = "F" or "f"
               perform convert-to-first
           else
           if def-reserved-case = "U" or "u"
               perform convert-to-upper
           else
           if def-reserved-case = "L" or "l"
               perform convert-to-lower.
           move end-sub to start-sub.
           go to case2.
       case4.
           if start-sub = 8
              go to case6.
           if perf-name-expected = yes
              go to case6.
           if alt1-name-expected = yes
              go to case6.
           if alt2-name-expected = yes
              go to case6.
           if go-name-expected = yes
              go to case6.
           if def-data-name-case= "N"
              move end-sub to start-sub
              go to case2.
       case5.
           move res-len to editlen.
           move sub to editstart.
           if def-sentence-case = "S" or "s"
               perform convert-to-sentence
           else
           if def-data-name-case = "F" or "f"
               perform convert-to-first
           else
           if def-data-name-case= "U" or "u"
               perform convert-to-upper
           else
           if def-data-name-case = "L" or "l"
               perform convert-to-lower.
           move end-sub to start-sub.
           go to case2.
       case6.
           move nay to perf-name-expected.
           move alt1-name-expected to alt2-name-expected.
           move nay to alt1-name-expected.
           if def-proc-case = "N"
              move end-sub to start-sub
              go to case2.
       case7.
           move res-len to editlen.
           move sub to editstart.
           if def-sentence-case = "S" or "s"
               perform convert-to-sentence
           else
           if def-proc-case = "F" or "f"
               perform convert-to-first
           else
           if def-proc-case = "U" or "u"
               perform convert-to-upper
           else
           if def-proc-case = "L" or "l"
               perform convert-to-lower.
           move end-sub to start-sub.
           go to case2.
       case-end.
           exit.
       next-word section.
       next-w1.
           perform find-char.
           if start-sub > 72
              go to next-wend.
           if char = quote
              if literal = yes
                 move nay to literal
                 add 1 to start-sub
                 go to next-w1
              else
                 move yes to literal
                 add 1 to start-sub
                 go to next-w1.
           if char = "."
              move 1 to new-sentence-expected
              if literal = nay
                 move nay to  perf-name-expected
                               alt1-name-expected
                               alt2-name-expected
                               go-name-expected
                               pic-name-expected
                 add 1 to start-sub
                 go to next-w1
              else
                 add 1 to start-sub
                 go to next-w1.
           if literal = yes
               add 1 to start-sub
               go to next-w1.
           move start-sub to end-sub.
           move 1 to res-sub.
           move spaces to res-word-buffer.
       next-w2.
           move char to res-word-buffer-char(res-sub).
           add 1 to end-sub.
           add 1 to res-sub.
           if end-sub > 72
              go to next-w3.
           move so-rec-chr(end-sub) to char.
           if char = space
              go to next-w3
           else if char = "."
              move 1 to new-sentence-expected
              go to next-w3.
           go to next-w2.
       next-w3.
           perform reserved-or-not.
       next-wend.
           exit.
       reserved-or-not section.
       reserv1.
           move 65 to editlen.
           move 1 to editstart.
           perform convert-resv-to-upper.
           move nay to reserved.
           move res-sub to res-len.
           subtract 1 from res-len.
           if res-sub < 3 or res-sub > 20
              go to r20.
           subtract 2 from res-sub.
           go to r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15
                   r16 r20 r20 r19
              depending on res-sub.
       r2.
           move 0 to res-sub.
       r2a.
           add 1 to res-sub.
           if res-sub > res-word-count-2 go to r20.
           if res02 = r2entry(res-sub)
              move yes to reserved
              go to r20.
           go to r2a.
       r3.
           move 0 to res-sub.
       r3a.
           add 1 to res-sub.
           if res-sub > res-word-count-3 go to r20.
           if res03 = r3entry(res-sub)
              move yes to reserved
              go to r20.
           go to r3a.
       r4.
           move 0 to res-sub.
       r4a.
           add 1 to res-sub.
           if res-sub > res-word-count-4 go to r20.
           if res04 = r4entry(res-sub)
              move yes to reserved
              go to r20.
           go to r4a.
       r5.
           move 0 to res-sub.
       r5a.
           add 1 to res-sub.
           if res-sub > res-word-count-5 go to r20.
           if res05 = r5entry(res-sub)
              move yes to reserved
              go to r20.
           go to r5a.
       r6.
           move 0 to res-sub.
       r6a.
           add 1 to res-sub.
           if res-sub > res-word-count-6 go to r20.
           if res06 = r6entry(res-sub)
              move yes to reserved
              go to r20.
           go to r6a.
       r7.
           move 0 to res-sub.
       r7a.
           add 1 to res-sub.
           if res-sub > res-word-count-7 go to r20.
           if res07 = r7entry(res-sub)
              move yes to reserved
              go to r20.
           go to r7a.
       r8.
           move 0 to res-sub.
       r8a.
           add 1 to res-sub.
           if res-sub > res-word-count-8 go to r20.
           if res08 = r8entry(res-sub)
              move yes to reserved
              go to r20.
           go to r8a.
       r9.
           move 0 to res-sub.
       r9a.
           add 1 to res-sub.
           if res-sub > res-word-count-9 go to r20.
           if res09 = r9entry(res-sub)
              move yes to reserved
              go to r20.
           go to r9a.
       r10.
           move 0 to res-sub.
       r10a.
           add 1 to res-sub.
           if res-sub > res-word-count-10 go to r20.
           if res10 = r10entry(res-sub)
              move yes to reserved
              go to r20.
           go to r10a.
       r11.
           move 0 to res-sub.
       r11a.
           add 1 to res-sub.
           if res-sub > res-word-count-11 go to r20.
           if res11 = r11entry(res-sub)
              move yes to reserved
              go to r20.
           go to r11a.
       r12.
           move 0 to res-sub.
       r12a.
           add 1 to res-sub.
           if res-sub > res-word-count-12 go to r20.
           if res12 = r12entry(res-sub)
              move yes to reserved
              go to r20.
           go to r12a.
       r13.
           move 0 to res-sub.
       r13a.
           add 1 to res-sub.
           if res-sub > res-word-count-13 go to r20.
           if res13 = r13entry(res-sub)
              move yes to reserved
              go to r20.
           go to r13a.
       r14.
           move 0 to res-sub.
       r14a.
           add 1 to res-sub.
           if res-sub > res-word-count-14 go to r20.
           if res14 = r14entry(res-sub)
              move yes to reserved
              go to r20.
           go to r14a.
       r15.
           move 0 to res-sub.
       r15a.
           add 1 to res-sub.
           if res-sub > res-word-count-15 go to r20.
           if res15 = r15entry(res-sub)
              move yes to reserved
              go to r20.
           go to r15a.
       r16.
           move 0 to res-sub.
       r16a.
           add 1 to res-sub.
           if res-sub > res-word-count-16 go to r20.
           if res16 = r16entry(res-sub)
              move yes to reserved
              go to r20.
           go to r16a.
       r19.
           move 0 to res-sub.
       r19a.
           add 1 to res-sub.
           if res-sub > res-word-count-19 go to r20.
           if res19 = r19entry(res-sub)
              move yes to reserved
              go to r20.
           go to r19a.
       r20.
           if reserved = nay go to reserv-end.
           if res-word-buffer not = "TO"
              move nay to go-name-expected.
           if res-word-buffer = "PIC" or "PICTURE" or "VALUE"
              move yes to pic-name-expected
              go to reserv-end
           else
              move nay to pic-name-expected.
           if res-word-buffer = "PERFORM" or "THRU" or "THROUGH"
              move yes to perf-name-expected
              go to reserv-end.
           if res-word-buffer = "ALTER"
              move yes to alt1-name-expected
              go to reserv-end.
           if res-word-buffer = "GO"
              move yes to go-name-expected
              go to reserv-end.
       reserv-end.
           exit.
       convert-to-upper section.
           move editstart to ind-1.
           move 1 to ind-2.
       convert-to-upper-loop.
           move so-rec-chr(ind-1) to temp-char
           if temp-char-9 < 123 and temp-char-9 > 96
               subtract 32 from temp-char-9
               move temp-char to so-rec-chr(ind-1).
           add 1 to ind-1
           add 1 to ind-2.
           if ind-2 not > editlen
               go to convert-to-upper-loop.

       convert-to-sentence section.
           move editstart to ind-1.
           move 1 to ind-2.
       convert-to-sentence-loop.
           move so-rec-chr(ind-1) to temp-char.
           if start-of-sentence = 1
               if temp-char-9 < 123 and temp-char-9 > 96
                   subtract 32 from temp-char-9
                   move temp-char to so-rec-chr(ind-1)
                   move 0 to new-sentence-expected
                   move 0 to start-of-sentence
               else
                   if temp-char-9 < 91 and temp-char-9 > 64
                       move 0 to new-sentence-expected
                       move 0 to start-of-sentence
                   else
                       next sentence
           else
               if temp-char-9 < 91 and temp-char-9 > 64
                   add 32 to temp-char-9
                   move temp-char to so-rec-chr(ind-1).
           add 1 to ind-1
           add 1 to ind-2.
           if ind-2 not > editlen
               go to convert-to-sentence-loop.


       convert-to-first section.
           move editstart to ind-1.
           move 1 to ind-2.
       convert-to-first-loop.
           move so-rec-chr(ind-1) to temp-char.
           move so-rec-chr(ind-1 - 1) to prev-char
           if prev-char-separator
               if temp-char-9 < 123 and temp-char-9 > 96
                   subtract 32 from temp-char-9
                   move temp-char to so-rec-chr(ind-1)
               else
                   next sentence
           else
               if temp-char-9 < 91 and temp-char-9 > 64
                   add 32 to temp-char-9
                   move temp-char to so-rec-chr(ind-1).
           add 1 to ind-1
           add 1 to ind-2.
           if ind-2 not > editlen
               go to convert-to-first-loop.

       convert-to-lower section.
           move editstart to ind-1.
           move 1 to ind-2.
       convert-to-lower-loop.
           move so-rec-chr(ind-1) to temp-char
           if temp-char-9 < 91 and temp-char-9 > 64
               add 32 to temp-char-9
               move temp-char to so-rec-chr(ind-1).
           add 1 to ind-1
           add 1 to ind-2.
           if ind-2 not > editlen
               go to convert-to-lower-loop.

       convert-resv-to-upper section.
           move editstart to ind-1.
           move 1 to ind-2.
       convert-resv-to-upper-loop.
           move res-word-buffer-char(ind-1) to temp-char
           if temp-char-9 < 123 and temp-char-9 > 96
               subtract 32 from temp-char-9
               move temp-char to res-word-buffer-char(ind-1).
           add 1 to ind-1
           add 1 to ind-2.
           if ind-2 not > editlen
               go to convert-resv-to-upper-loop.

       find-char section.
           if start-sub < 73
               if so-rec-chr(start-sub) = space
                   add 1 to start-sub
                   go to find-char
               else
                   move so-rec-chr(start-sub) to char
           else
               move space to char.

       end program caseconv.
