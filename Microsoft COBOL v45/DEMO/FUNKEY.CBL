      $set noosvs mf ans85
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1991                   *
      *                                                          *
      *                      FUNKEY.CBL                          *
      *                                                          *
      *    This program demonstrates how to decode function keys *
      *    using the x"af" call.                                 *
      *                                                          *
      ************************************************************
       special-names.
           crt status is key-status.

       working-storage section.
       01 flag                   pic 9(2) comp-x value 1.
       01 user-key-control.
          05 enable-fn-keys      pic 9(2) comp-x value 1.
          05 filler              pic x           value "1".
          05 first-user-key      pic 9(2) comp-x value 1.
          05 number-of-keys      pic 9(2) comp-x value 10.

       01 key-status.
          05 key-type            pic x.
          05 key-code-1          pic 9(2) comp-x.
          05 filler              pic x.
       01 any-data               pic x.
       01 key-code-1-display     pic z9.

       procedure division.
           perform enable-keys
           perform accept-function-key
           perform tell-which-key-was-pressed
           perform stop-run.

       enable-keys.
           call x"af" using flag user-key-control.

       accept-function-key.
           display spaces upon crt
           display "Press a function key: F1 to F10" at 0505
           accept any-data at 0540.

       tell-which-key-was-pressed.
           evaluate key-type
              when 0 display "You pressed <Enter>" at 0705
              when 1
                   move key-code-1 to key-code-1-display
                   display "You pressed function key" at 0705
                   display key-code-1-display         at 0730
           end-evaluate.

       stop-run.
           stop run.
