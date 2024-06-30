      $SET WARNING(3) NOOSVS ANS85 mf
      *****************************************************************
      *                                                               *
      *                   (C) Micro Focus Ltd. 1991                   *
      *                                                               *
      *                         CALC.CBL                              *
      *                                                               *
      *  This program demonstrates function key handling, screen      *
      *     section capabilities, and D9 calls.                       *
      *                                                               *
      *****************************************************************


       SPECIAL-NAMES.
           crt status is key-status.
       WORKING-STORAGE SECTION.
       78  Return-key                      value X"3030".
       78  Equals-key                      value X"333D".
       01  key-status.
           03  key-type                    pic x.
               88  function-key            value "1".
               88  data-key                value "3".
           03  key-code-1                  pic 99  comp-x.
           03  key-code-1-x redefines
               key-code-1                  pic x.
               88  Operator-entered        value "*" "-" "/" "+".
               88  CLear-key               value "C" "c".
           03  key-code-2                  pic x.
       01  redefines key-status.
           03                              pic xx.
               88  escape-key-pressed      value X"3100".
      * Answer needed "=" or <CR>
               88  answer-needed           value Return-key Equals-key.
           03                              pic x.
       01  set-bit-pairs                   pic 99  comp-x  value 1.
       01  data-key-control.
           03  data-key-setting            pic 99  comp-x.
               88  key-is-disabled                         value zero.
               88  act-as-a-function-key   value 1.
               88  character-into-field    value 2.
           03                              pic x  value "3".
           03  first-data-key              pic x.
           03  number-of-data-keys         pic 99  comp-x  value 1.
       01  user-key-control.
           03  User-key-setting            pic 99  comp-x  value 1.
           03                              pic x           value "1".
           03  first-user-key              pic 99  comp-x  value 0.
           03  number-of-keys              pic 99  comp-x  value 1.
       78  No-of-data-keys                 value 7.
       01  keys-to-enable                  pic x(no-of-data-keys)
           value "/*-+Cc=".
       01  redefines keys-to-enable.
           03  key-to-enable occurs no-of-data-keys times
               indexed by key-enable-index pic x.
       01  Entered-Value                   PIC S9(11)V9(7) BINARY.
       01  Saved-Value                     PIC S9(11)V9(7) BINARY.
       01  saved-operator                  pic x.
       01  is-there-a-key-waiting          pic x   comp-x.
           88  no-key-waiting              value zero.
           88  key-waiting                 value 1 thru 255.
       01                                  pic 99  comp-x.
           88  calculation-ok              value zero.
           88  numeric-overflow            value 1.
       SCREEN SECTION.
       01  Calculator-screen.
           05  BLANK SCREEN.
           05  LINE 1  COL 1 VALUE "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»".
           05  LINE 2  COL 1 VALUE "º ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» º".
           05  LINE 3  COL 1 VALUE "º º                      º º".
           05  LINE 4  COL 1 VALUE "º ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ º".
           05  LINE 5  COL 1 VALUE "º   ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄÄ¿   º".
           05  LINE 6  COL 1 VALUE "º   ³   ³³   ³³   ³³   ³   º".
           05  LINE 7  COL 1 VALUE "º   ÀÄÄÄÙÀÄÄÄÙÀÄÄÄÙÀÄÄÄÙ   º".
           05  LINE 8  COL 1 VALUE "º   ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄÄ¿   º".
           05  LINE 9  COL 1 VALUE "º   ³   ³³   ³³   ³³   ³   º".
           05  LINE 10 COL 1 VALUE "º   ÀÄÄÄÙÀÄÄÄÙÀÄÄÄÙ³   ³   º".
           05  LINE 11 COL 1 VALUE "º   ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄÄ¿³   ³   º".
           05  LINE 12 COL 1 VALUE "º   ³   ³³   ³³   ³³   ³   º".
           05  LINE 13 COL 1 VALUE "º   ÀÄÄÄÙÀÄÄÄÙÀÄÄÄÙÀÄÄÄÙ   º".
           05  LINE 14 COL 1 VALUE "º   ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄÄ¿ÚÄÄÄ¿   º".
           05  LINE 15 COL 1 VALUE "º   ³   ³³   ³³   ³³   ³   º".
           05  LINE 16 COL 1 VALUE "º   ÀÄÄÄÙÀÄÄÄÙÀÄÄÄÙ³   ³   º".
           05  LINE 17 COL 1 VALUE "º   ÚÄÄÄÄÄÄÄÄ¿ÚÄÄÄ¿³   ³   º".
           05  LINE 18 COL 1 VALUE "º   ³        ³³   ³³   ³   º".
           05  LINE 19 COL 1 VALUE "º   ÀÄÄÄÄÄÄÄÄÙÀÄÄÄÙÀÄÄÄÙ   º".
           05  LINE 20 COL 1 VALUE "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼".
           05 HIGHLIGHT.
               10  entry-field.
                   15  LINE 3  COL 5 PIC -(11)9.9(7)
                       USING Entered-Value PROMPT spaces.
               10 LINE 6  COL 7  VALUE "C".
               10         COL 12 VALUE "/".
               10         COL 17 VALUE "*".
               10         COL 22 VALUE "-".
               10 LINE 9  COL 7  VALUE "7".
               10         COL 12 VALUE "8".
               10         COL 17 VALUE "9".
               10 LINE 10 COL 22 VALUE "+".
               10 LINE 12 COL 7  VALUE "4".
               10         COL 12 VALUE "8".
               10         COL 17 VALUE "6".
               10 LINE 15 COL 7  VALUE "1".
               10         COL 12 VALUE "2".
               10         COL 17 VALUE "3".
               10 LINE 16 COL 22 VALUE "=".
               10 LINE 18 COL 9  VALUE "0".
               10         COL 17 VALUE ".".
       PROCEDURE DIVISION.
       main-1.
           perform initialization-routines
           DISPLAY Calculator-screen
           perform with test after until escape-key-pressed
               if operator-entered or numeric-overflow
      *    Position the cursor at the first integer position of the
      *    entry field which waiting for a character to be pressed
                   if numeric-overflow
                       display low-values at 0321
                   else
                       display low-values at 0316
                   end-if
      *    Leave the previous value in th field until a value is
      *    entered
                   set no-key-waiting to true
                   perform with test after until key-waiting
                       call X"D9" using is-there-a-key-waiting
                   end-perform
                   move zero to entered-value
               end-if
               display Entry-field
               ACCEPT Calculator-screen
               if data-key or answer-needed
                   perform data-key-terminated-accept
               end-if
           end-perform
           exit program
           STOP RUN.
       data-key-terminated-accept.
           evaluate true
               when Operator-entered
                   if saved-operator not = spaces
                       perform calculate-answer
      *    Display current intermediate result  whilst waiting for next
      *    keystoke which will require the field to be cleared
                       display Entry-field
                   end-if
                   move key-code-1-x to saved-operator
                   move entered-value to saved-value
               when CLear-key
                   move zero to entered-value saved-value
                   move spaces to saved-operator
               when answer-needed
                   perform calculate-answer
                   move spaces to saved-operator
           end-evaluate.
       calculate-answer.
           set calculation-ok to true
           evaluate saved-operator
               when "*"
                   compute entered-value = saved-value * entered-value
                       on size error perform size-error-action
               when "-"
                   compute entered-value = saved-value - entered-value
                       on size error perform size-error-action
               when "+"
                   compute entered-value = saved-value + entered-value
                       on size error perform size-error-action
               when "/"
                   compute entered-value = saved-value / entered-value
                       on size error perform size-error-action
           end-evaluate.
       size-error-action.
           move zero to entered-value saved-value
           move spaces to saved-operator
           display "Numeric Overflow    " at 0305 with highlight
           set numeric-overflow to true.
       initialization-routines.
      *    activate "*" "/" "-" "+" "C" "c" and "="
      *    to terminate an accept.
           set act-as-a-function-key to true
           perform varying key-enable-index from 1 by 1
                   until key-enable-index > No-of-data-keys
               move key-to-enable(key-enable-index) to first-data-key
               call X"AF" using set-bit-pairs data-key-control
           end-perform
           move zero to entered-value saved-value
      *    Enable function key zero - The Escape key.
           call X"AF" using set-bit-pairs user-key-control.
