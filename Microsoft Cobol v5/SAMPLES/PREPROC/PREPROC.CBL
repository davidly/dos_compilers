      $set ans85 mf

      /*****************************************************************
      *                                                                *
      *  Beginning of the example Integrated Pre-Processor             *
      *                                                                *
      ******************************************************************

       identification division.
           program-id.    integrated-preprocessor.
           author.        Micro Focus.
           installation.  Micro Focus COBOL/2 Workbench.
           date-written.  8 August 1986.
           date-compiled. 8 August 1986.
           security.      Copyright protection.

       environment division.
           configuration section.
           source-computer. ibm-pc.
           object-computer. ibm-pc.

       special-names.
           command-line is cmd-line.

       select main-file assign main-file-name
            organization line sequential
            status is file-stat.

       select copy-file assign copy-file-name
           organization line sequential
           status is file-stat.

       select trace-file assign "trace.cbl"
            organization line sequential
            status is file-stat.

       select console-file assign "con:"
           organization line sequential
           status is file-stat.

       select dir-file assign dir-file-name
           organization line sequential
           status is file-stat.

       file section.

       fd main-file.
       01  main-rec.
          02 filler pic x(80).

       fd copy-file.
       01  copy-rec.
          02 filler pic x(80).

       fd trace-file.
       01  trace-rec.
          02 filler pic x(80).

       fd console-file.
       01  console-rec.
          02 filler pic x(80).

       fd dir-file.
       01  dir-rec.
          02 filler pic x(80).
      /
       working-storage section.

       01  file-stat.
           02 stat-1           pic 9.
           02 stat-2           pic 9.

       77  token-pos           pic 9(2)    comp-x.
       77  unfinished-action   pic 9(2)    comp-x.
       77  separate-verbs      pic 9(2)   comp-x.
       77  copy-file-active    pic 9(2)    comp-x.
       77  input-empty         pic 9(2)    comp-x.
       77  output-ready        pic 9(2)    comp-x.
       77  input-to-return     pic 9(2)    comp-x.
       77  edit-active         pic 9(2)    comp-x.
       77  edit-to-return      pic 9(2)    comp-x.
       77  overflow-active     pic 9(2)    comp-x.
       77  prep-active         pic 9(2)    comp-x.

       77  token               pic 9(2)    comp-x.
       77  token-delimit       pic 9(2)    comp-x.
       77  char                pic 9(2)    comp-x.
       77  pp                  pic 9(2)    comp-x.
       77  temp                pic 9(2)    comp-x.
       77  temp-2              pic 9(2)    comp-x.
       77  temp-X              pic X.
       77  error-message-text  pic x(40)   value
                                     "Pre-Processor Syntax in error".

       01  input-buffer.
           02  input-byte          pic 9(2)    comp-x      occurs 80.
           02  input-layout redefines input-byte.
               03  filler          pic x(6).
               03  in-col-7        pic 9(2)    comp-x.
               03  filler          pic x(65).
               03  in-col-73       pic 9(2)    comp-x.
               03  filler          pic x(7).
       01  input-flags.
           02  in-col-5            pic 9(2)    comp-x.
           02  in-col-6            pic 9(2)    comp-x.
       77  input-count             pic 9(2)    comp-x.

       01  output-buffer.
           02  output-byte         pic 9(2)    comp-x      occurs 80.
           02  output-layout redefines output-byte.
               03   filler         pic x(6).
               03   out-col-7-80   pic x(74).
       01  output-flags.
           02  out-col-5           pic 9(2)    comp-x.
           02  out-col-6           pic 9(2)    comp-x.
       77  output-count            pic 9(2)    comp-x.

       01  overflow-buffer.
           02  overflow-byte       pic 9(2)    comp-x      occurs 80.
           02  overflow-msg redefines overflow-byte.
               03  msg-number      pic x(7).
               03  filler          pic x(73).
       01  overflow-flags.
           02  over-col-5          pic 9(2)    comp-x.
           02  over-col-6          pic 9(2)    comp-x.
       77  overflow-count          pic 9(2)    comp-x.

       01  cmdline                 pic x(80).

       01  next-prep               pic x(8).

       01  lex-buffer.
           02  lex-byte            pic 9(2)    comp-x      occurs 80.
           02  lex-layout redefines lex-byte.
               03  lex-1-30        pic X(30).
               03  filler          pic X(50).
       77  lex-count               pic 9(2)    comp-x.
       77  saved-lex-1-30          pic x(30).
      /
       78  do-copy                                value  1.
       78  do-error                               value  2.

       78  val-A                                  value  H"41".
       78  val-Z                                  value  H"5A".
       78  val-a-lc                               value  H"61".
       78  val-z-lc                               value  H"7A".
       78  val-lc-to-UC                           value  H"20".
       78  val-zero                               value  H"30".
       78  val-nine                               value  H"39".
       78  val-space                              value  H"20".
       78  val-file-slash                         VALUE  H"5C".

       78  val-eor                                value  H"FF".
       78  val-eoc                                value  H"FE".
       78  val-eof                                value  H"FD".
       78  val-eol                                value  H"7F".
       78  val-period                             value  H"2E".
       78  val-plus                               value  H"2B".
       78  val-minus                              value  H"2D".
       78  val-quote                              value  H"22".
       78  val-apostrophe                         value  H"27".
       78  val-mult                               value  H"2A".
       78  val-asterisk                           value  H"2A".
       78  val-div                                value  H"2F".
       78  val-slash                              value  H"2F".
       78  val-lbkt                               value  H"28".
       78  val-rbkt                               value  H"29".
       78  val-equal                              value  H"3D".
       78  val-gt                                 value  H"3E".
       78  val-lt                                 value  H"3C".
       78  val-semi                               value  H"3B".
       78  val-comma                              value  H"2C".

       78  tok-word                               value  1.
       78  tok-numb                               value  2.
       78  tok-eor                                value  3.
       78  tok-eoc                                value  4.
       78  tok-eof                                value  5.
       78  tok-period                             value  6.
       78  tok-plus                               value  7.
       78  tok-minus                              value  8.
       78  tok-an-lit                             value  9.
       78  tok-mult                               value  10.
       78  tok-div                                value  11.
       78  tok-lbkt                               value  12.
       78  tok-rbkt                               value  13.
       78  tok-equal                              value  14.
       78  tok-gt                                 value  15.
       78  tok-lt                                 value  16.
       78  tok-ge                                 value  17.
       78  tok-le                                 value  18.
       78  tok-error                              value  19.

       78  val-false                              value  0.
       78  val-true                               value  1.

       78  sound-beep                             value X"E5".
       78  keybd-read                             value X"83".

      /*****************************************************************
      *                                                                *
      * when trace-flag = val-true then TRACE.CBL is created as a trace*
      * file, to contain a copy of buffer for every return from the    *
      * pre-processor to the compiler ... a useful debugging aide.     *
      *                                                                *
      ******************************************************************


       77  trace-flag              pic 9(2)    comp-x  value val-false.

       linkage section.

       01  mode-flag               pic 9(2)    comp-x.
       01  buffer                  pic x(80).
       01  response.
           03  response-status     pic 9(2)    comp-x.
           03  response-code       pic 9(4)    comp-x.
           03  filler redefines response-code.
               05  filler          pic x.
               05  resp-main       pic 9(2)    comp-x.
           03  response-code-2     pic 9(4)    comp-x.
           03  filler redefines response-code-2.
               05  filler          pic x.
               05  resp-more       pic 9(2)    comp-x.


      /*****************************************************************
      *                                                                *
      * Procedure Division.                                            *
      *                                                                *
      ******************************************************************

       procedure division using mode-flag, buffer, response.

       start-para section.
           move 0 to response-status
           if mode-flag = 0
               move val-false to prep-active
               accept input-buffer from cmd-line
               if input-buffer not = spaces
                   perform analyse-command-line
               else
                   perform open-main-file
               end-if
               move val-true  to input-empty
               move val-false to copy-file-active
               move val-false to output-ready
               move val-false to input-to-return
               move val-false to edit-active
               move val-false to edit-to-return
               move val-false to overflow-active
               move val-false to separate-verbs
               move 7 to output-count
               move 12 to overflow-count
               move 0 to unfinished-action
               open output console-file
           else
               perform preprocess until output-ready = val-true
               if input-to-return = val-true
                   move input-buffer to buffer
                   move 0 to response-code
                   move 0 to response-code-2
                   move in-col-5 to resp-more
                   move in-col-6 to resp-main
                   move val-false to input-to-return
                   move edit-to-return to output-ready
               else
                   if edit-to-return = val-true
                       move output-buffer to buffer
                       move 0 to response-code
                       move 0 to response-code-2
                       move out-col-5 to resp-more
                       move out-col-6 to resp-main
                       move spaces to output-buffer
                       move spaces to output-flags
                       move 7 to output-count
                       move overflow-active to output-ready
                       move overflow-active to edit-to-return
                       if overflow-active = val-true
                           move overflow-buffer to output-buffer
                           move overflow-flags to output-flags
                           move overflow-count  to output-count
                           move spaces to overflow-buffer
                           move spaces to overflow-flags
                           move 12 to overflow-count
                           move val-false to overflow-active
                       end-if
                   end-if
               end-if
           perform trace-record
           end-if.
       start-x.
           exit program.


      /*****************************************************************
      *                                                                *
      * open, close and main and copy source code files                *
      *                                                                *
      ******************************************************************

       open-main-file section.
           move buffer to main-file-name.
           open input main-file.
           if stat-1 not = 0
               move 255 to response-status
           else
               if trace-flag = val-true
                   open output trace-file
                   if stat-1 not = 0
                       move 255 to response-status
                   end-if
               end-if
           end-if.

       close-main-file section.
           close main-file console-file
           if trace-flag = val-true
               close trace-file
           end-if
           move 0 to in-col-6
           move val-true to output-ready.

       trace-record section.
           if trace-flag = val-true
               move buffer to trace-rec
               write trace-rec
           end-if.

      /*****************************************************************
      *                                                                *
      *    routine to process copy verb                                *
      *    if the copy file is on two lines then set flag & get        *
      *    name of the copy file next time through.                    *
      *    otherwise get the name of copy file and open it.            *
      *                                                                *
      ******************************************************************

       open-copy-file section.
           move 3 to in-col-6
           move input-count to in-col-5
           subtract 5 from in-col-5
           perform read-token
           evaluate token
               when tok-word
               when tok-an-lit
                   move lex-1-30 to copy-file-name
                   open input copy-file
                   if stat-1 not = 0
                       move 255 to response-status
                   else
                       move val-true to copy-file-active
                   end-if
               when tok-eor
                   move do-copy to unfinished-action
               when other
                   move 255 to response-status
           end-evaluate
           move val-true to output-ready
           move val-true to input-empty.

       continue-copy-file section.
           perform open-copy-file
           move 0 to in-col-5
           move 4 to in-col-6.

       close-copy-file section.
           close copy-file
           move val-false to copy-file-active
           move spaces to input-buffer
           move val-true to input-empty
           move 128 to in-col-6
           move val-true to output-ready.

      /*****************************************************************
      *                                                                *
      * read main and copy source code files                           *
      *                                                                *
      ******************************************************************

       read-record section.
           move spaces to input-flags
           if copy-file-active = val-false
               if prep-active = val-true
                   move spaces to input-buffer
                   move 0 to resp-more
                   move 0 to resp-main
                   call next-prep using mode-flag input-buffer response
                   move resp-more to in-col-5
                   move resp-main to in-col-6
               else
                   read main-file
                       at end
                           move spaces to input-buffer
                           move val-eof to in-col-73
                       not at end
                           move main-rec to input-buffer
                           move val-eor to in-col-73
               end-if
           else
               read copy-file
                   at end
                       move spaces to input-buffer
                       move val-eoc to in-col-73
                   not at end
                       move copy-rec to input-buffer
                       move val-eor to in-col-73
           end-if
            evaluate in-col-6
               when 0 move spaces to input-buffer
                      move spaces to input-flags
                      move val-eof to in-col-73
                      move val-space to char
      *for the moment we'll not change modified lines
               when 1 move val-eor to char
               when 2 move val-eor to char
               when 3 move val-eor to char
               when 4 move val-eor to char
               when 5 move val-eor to char
               when 6 move val-eor to char
               when 128 move val-eor to char
               when other
                   if in-col-7 = val-asterisk or in-col-7 = val-slash
                       move val-eor to char
                   else
                       move val-space to char
                   end-if
           end-evaluate
           move 8 to input-count
           if prep-active = val-false
               move val-space to in-col-6
           end-if
           move val-false to input-empty.
           move val-true to input-to-return.

      ******************************************************************
      *                                                                *
      *  RDCH        read a character from the input record            *
      *                                                                *
      ******************************************************************

       rdch section.
           move input-byte (input-count) to char.
           add 1 to input-count.

       ppch section.
           move input-byte (input-count) to pp.

       lexch section.
           move char to lex-byte (lex-count).
           add 1 to lex-count.


      /*****************************************************************
      *                                                                *
      *  EDIT-SETUP      prepare to output an edited record            *
      *                                                                *
      ******************************************************************

       edit-setup section.
           if separate-verbs = val-false
               if edit-active = val-false
                   move input-count to temp
                   subtract lex-count from temp
                   perform until output-count = temp
                       move input-byte (output-count) to
                                              output-byte (output-count)
                       add 1 to output-count
                   end-perform
               end-if
           else
               perform until output-count = 12
                   move val-space to output-byte(output-count)
                   add 1 to output-count
               end-perform
               move val-false to separate-verbs
           end-if
           move val-true to edit-active.

       move-token section.
           move lex-count to temp
           add output-count to temp
           if token = tok-an-lit
              subtract 1 from lex-count
              if input-count not =  74
                  add 1 to temp
              end-if
           end-if.
           if temp > 72
               move val-true to overflow-active
               move 0         to over-col-5
               move out-col-6 to over-col-6
           end-if
           move 1 to temp
           perform move-delimit
           if overflow-active = val-false
               perform until temp > lex-count
                   move lex-byte (temp) to output-byte (output-count)
                   add 1 to temp
                   add 1 to output-count
               end-perform
           else
               perform until temp > lex-count
                   move lex-byte(temp) to overflow-byte (overflow-count)
                   add 1 to temp
                   add 1 to overflow-count
               end-perform
           end-if
           perform move-delimit.

       move-delimit section.
           if token = tok-an-lit
               if overflow-active = val-false
                   move token-delimit to output-byte (output-count)
                   add 1 to output-count
               else
                   move token-delimit to overflow-byte (overflow-count)
                   add 1 to overflow-count
               end-if
           end-if.

      /*****************************************************************
      *                                                                *
      *  READ-TOKEN  -  main lexical analysis subroutine               *
      *                                                                *
      *                 input : char     = next character from input   *
      *                                                                *
      *                 result: token    = lexical token type          *
      *                         LEX-1-30 = lexical symbol string       *
      *                                                                *
      ******************************************************************

       read-token section.
           move 1 to lex-count.
           move spaces to lex-1-30.
       rt-loop.
           perform rdch
               until char not = val-space
           move input-count to token-pos
           subtract 1 from token-pos
           evaluate char
               when val-A thru val-Z
                   perform rt-word
               when val-a-lc thru val-z-lc
                   subtract val-lc-to-uc from char
                   perform rt-word
               when val-zero thru val-nine
                   perform rt-numb
               when val-eor
                   move tok-eor to token
               when val-period
                   move tok-period to token
                   perform rt-numb-query
               when val-plus
                   move tok-plus to token
                   perform rt-numb-query
               when val-minus
                   move tok-minus to token
                   perform rt-numb-query
               when val-quote
               when val-apostrophe
                   perform rt-lit
               when val-mult
                   move tok-mult to token
                   perform rdch
               when val-div
                   move tok-div  to token
                   perform rdch
               when val-lbkt
                   move tok-lbkt to token
                   perform rdch
               when val-rbkt
                   move tok-rbkt to token
                   perform rdch
               when val-equal
                   move tok-equal to token
                   perform rdch
               when val-gt
                   move tok-gt to token
                   perform rt-compare
               when val-lt
                   move tok-lt to token
                   perform rt-compare
               when val-semi
               when val-comma
                   perform rdch
                   go to rt-loop
               when val-eoc
                   move tok-eoc to token
               when val-eof
                   move tok-eof to token
               when val-file-slash
                   perform rt-word
               when val-eol
                   continue
               when other
                   move tok-error to token
                   display "Preprocessor error: unrecognised token"
           end-evaluate.
      *
      /*****************************************************************
      *                                                                *
      *  RT-WORD       read a word.  leaves CHAR = next character      *
      *                                                                *
      ******************************************************************

       rt-word section.
           move tok-word to token.
       rt-word-l.
           perform lexch.
           perform rdch.
           evaluate char
               when val-A thru val-Z
               when val-zero thru val-nine
               when val-minus
               WHEN val-file-slash
                   go to rt-word-l
               when val-a-lc thru val-z-lc
                   subtract val-lc-to-uc from char
                   go to rt-word-l
           end-evaluate.


      ******************************************************************
      *                                                                *
      *  RT-NUMB       read a number. leaves CHAR = next character     *
      *                                                                *
      ******************************************************************

       rt-numb section.
           move tok-numb to token.
       rt-numb-l.
           perform lexch.
           perform rdch.
           evaluate char
               when val-zero thru val-nine
                   go to rt-numb-l
               when val-period
                   perform ppch
                   if pp >= val-zero and pp <= val-nine
                       go to rt-numb-l
                   end-if
           end-evaluate.

       rt-numb-query section.
           perform lexch.
           perform rdch.
           evaluate char
               when val-zero thru val-nine
               perform rt-numb
           end-evaluate.

      /*****************************************************************
      *                                                                *
      *  RT-LIT        read alphanumeric literal. leaves CHAR = next ch*
      *                eliminates lead & trail quote/apostrophe        *
      *                                                                *
      ******************************************************************

       rt-lit section.
           move char to token-delimit.
           move tok-an-lit to token.
       rt-lit-l.
           perform rdch
           evaluate char
               when val-quote
               when val-apostrophe
                   if char = token-delimit
                       perform rdch
                   else
                       perform lexch
                       go to rt-lit-l
                   end-if
               when val-eor
                   move val-eor to char
               when other
                   perform lexch
                   go to rt-lit-l
           end-evaluate.


      ******************************************************************
      *                                                                *
      *  RT-COMPARE    read a comparator symbol ( <= >= ). leaves CHAR=*
      *                                                                *
      ******************************************************************

       rt-compare section.
           perform lexch.
           perform rdch.
           if char = val-equal
               if token = tok-gt then move tok-ge to token
                                 else move tok-le to token
               end-if
               perform lexch
               perform rdch
           end-if.
       rt-compare-x.
           exit.


      /*****************************************************************
      *                                                                *
      * PREPROCESS      the main program                               *
      *                                                                *
      ******************************************************************

       preprocess section.
           if input-empty = val-true
               perform read-record
           end-if
           if unfinished-action not = 0
               perform tidy-up
           else
               if separate-verbs = val-false
                   perform read-token
               else
                   move tok-word to token
                   move saved-lex-1-30 to lex-1-30
                   move val-false to edit-active
               end-if
               evaluate token
                   when tok-word
                       evaluate lex-1-30
                           when "MOV"
                               perform mov-routine
                           when "DIS"
                               perform dis-routine
                           when "WARN"
                               perform warn-routine
                           when "ERROR"
                               perform error-routine
                           when "CPY"
                               perform cpy-routine
                           when "COPY"
                               perform open-copy-file
                           when other
                               if edit-active = val-true
                                   perform move-token
                               end-if
                       end-evaluate
                   when tok-eor
                       if edit-active = val-true
                           move val-true to edit-to-return
                           move val-false to edit-active
                       end-if
                       move val-true to output-ready
                       move val-true to input-empty
                   when tok-eof
                       perform close-main-file
                   when tok-eoc
                       perform close-copy-file
                   when tok-error
                       move 255 to response-status
                       move val-true to output-ready
                   when other
                       if edit-active = val-true
                           perform move-token
                       end-if
               end-evaluate
           end-if.


      /*****************************************************************
      *                                                                *
      * routines to tidy-up the various pre-processor tasks            *
      *                                                                *
      ******************************************************************

       tidy-up section.
           move unfinished-action to temp
           move 0 to unfinished-action
           evaluate temp
               when do-copy
                   perform continue-copy-file
               when do-error
                   perform continue-error-routine
               when other
                   display "TIDY-UP: ENTRY - BUT NOT ACTIVE !"
                   move 255 to response-status
           end-evaluate.


      /*****************************************************************
      *                                                                *
      *    routine to process MOV verb                                 *
      *                                                                *
      ******************************************************************


       mov-routine section.
           if edit-active = val-true
               move val-true to output-ready
               move val-true to edit-to-return
               move lex-1-30 to saved-lex-1-30
               move val-true to separate-verbs
           else
               perform edit-setup
               move "MOVE " to lex-1-30
               move 5 to lex-count
               move 2 to  in-col-6
               move 1 to out-col-6
               move token-pos to out-col-5
               perform move-token
           end-if.


      ******************************************************************
      *                                                                *
      *    routine to process DIS verb                                 *
      *                                                                *
      ******************************************************************

       dis-routine section.
           if edit-active = val-true
               move val-true to output-ready
               move val-true to edit-to-return
               move lex-1-30 to saved-lex-1-30
               move val-true to separate-verbs
           else  
               perform edit-setup
               move 2 to  in-col-6
               move 1 to out-col-6
               move token-pos to out-col-5
               move "DISPLAY SPACE UPON CRT " to lex-1-30
               move 23 to lex-count
               perform move-token
               move "DISPLAY " to lex-1-30
               move 8 to lex-count
               perform move-token
           end-if.

      /*****************************************************************
      *                                                                *
      *    routine to process CPY verb                                 *
      *                                                                *
      ******************************************************************


       cpy-routine section.
           if edit-active = val-true
               move val-true to output-ready
               move val-true to edit-to-return
               move lex-1-30 to saved-lex-1-30
               move val-true to separate-verbs
           else
               perform edit-setup
               move "COPY " to lex-1-30
               move 5 to lex-count
               move 2 to  in-col-6
               move 1 to out-col-6
               move token-pos to out-col-5
               perform move-token
           end-if.


      ******************************************************************
      *                                                                *
      * this routine will insert a warning into the list file.         *
      * the warning must have the format of a comment line.            *
      *                                                                *
      ******************************************************************

        warn-routine section.
           move 0 to out-col-5
           move 5 to out-col-6
           move "* EXAMPLE WARNING MESSAGE" to out-col-7-80
           move val-true to edit-to-return.




      /*****************************************************************
      *                                                                *
      * This routine can signal the compiler to switch into the editor.*
      * at the point in the source code where the pre-processor finds  *
      * an error.                                                      *
      * Note: all open source files are closed before switching to the *
      * editor.  Also, note that a record is passed back to the compiler
      * to flush out a buffered listing record in the compiler, BEFORE *
      * entering the interactive Y/N sequence.  The flush record ..... *
      * "* ... warning ... etc" appears on the user screen AFTER the   *
      * interactive sequence, if the user choses to continue, as the   *
      * compiler treats the warning message as another buffered record.*
      *                                                                *
      ******************************************************************

        error-routine section.
           move 0 to out-col-5
           move 5 to out-col-6
           move "*  WARNING .... PRE-PROCESSOR ERROR" to out-col-7-80
           move val-true to output-ready
           move val-true to input-to-return
      * make a comment so the checker doesn't object to it
           move val-asterisk to in-col-7
           move val-true to edit-to-return
           move val-false to overflow-active
           move spaces to overflow-buffer
           move 12 to overflow-count
           move do-error to unfinished-action.


        continue-error-routine section.
           move "**nnn-S" to msg-number
           perform varying temp from 8 by 1 until temp = input-count
               move val-asterisk to overflow-byte ( temp )
           end-perform
           write console-rec from overflow-buffer
           write console-rec from error-message-text
           write console-rec from "CONTINUE CHECKING PROGRAM ?   Yes/No"
           call sound-beep
           call keybd-read using temp-X
           if temp-X = 'N' or temp-X = 'n'
               display error-message-text upon cmd-line
               move 6 to in-col-6
               close main-file
               close copy-file
           else
               move 7 to in-col-6
               move 2 to in-col-5
           end-if
           move spaces to input-buffer
           move val-true to input-empty
           move val-true to output-ready
           move val-true to input-to-return
           move val-false to edit-to-return.

      /*****************************************************************
       analyse-command-line section.
           move 1 to input-count.
       analyse-again.
           perform read-token
               evaluate lex-1-30
                   when "PREPROCESS"
                     move val-true to prep-active
      *write to command line
                     perform read-token
                     perform read-token
                     move input-count to temp
                     add 1 to temp
                     subtract temp from 80 giving temp-2
                     move input-buffer(temp:temp-2) to cmdline
                     display cmdline upon cmd-line
      *call next preprocessor
                     move lex-1-30(1:8) to next-prep
                     call next-prep using mode-flag buffer response
                 when "DIRECTIVES"
                     perform read-directives
                     move 1 to input-count
                     perform read-token
                     go to analyse-again
                 when spaces
                     perform open-main-file
                 when other
                   move tok-error to token
                   display "PREPROC ERROR: UNRECOGNISED PARAMETER"
                 end-evaluate.


      /*****************************************************************
       read-directives section.
           perform read-token
           move input-count to temp-2
           perform read-token
           move lex-1-30 to dir-file-name
           subtract temp-2 from input-count giving temp
           add 1 to temp
           perform read-token
           move lex-1-30 to dir-file-name(temp:1)
           add 1 to temp
           perform read-token
           move lex-1-30 to dir-file-name(temp:3)

               open input dir-file
               if stat-1 not = 0
                   move tok-error to token
                   display "PREPROC ERROR: INVALID DIRECTIVES FILE"
               else
                   read dir-file
      *only allowing a one line file at present
                   move dir-rec to input-buffer
                   close dir-file.

      ******************************************************************
      *                                                                *
      * End of example Integrated Pre-Processor                        *
      *                                                                *
      ******************************************************************
