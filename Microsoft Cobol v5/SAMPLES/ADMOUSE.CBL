      $set noosvs mf novsc2
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1990,1992              *
      *                                                          *
      *                     ADMOUSE.CBL                          *
      *                                                          *
      *    This program demonstrates the use of a mouse in       *
      *    ADIS ACCEPT statements.                               *
      *                                                          *
      ************************************************************
       identification division.
       data division.

       working-storage section.
       01 filler.
           03 occurs 6.
               05 occurs 10.
                   07 ws-item      pic 999 value zero.
       01 mouse-param              pic 99 comp-x.
       01 use-mouse                pic 99 comp-x value 64.
       01 use-panels               pic 99 comp-x value 49.

       screen section.
       01 g-admouse.
         02 background-color 7 foreground-color 1.
          03 blank screen.
          03 line 2 col 15 value "USING THE MOUSE POINTER TO MOVE AROUND
      -                          " FIELDS" background-color 3 underline.
          03 line 4 col 8  value "Move the mouse to the field in which y
      -                          "ou wish to enter data, then".
          03 line 5 col 8  value "press the left hand  button  on the mo
      -                          "use to move the text cursor".
          03 line 6 col 8  value "to the selected field.  Press 'Enter'
      -                          "key to terminate.".
          03 line 8 col 4 value "SALES FIGURES" foreground-color 4
                                                underline.
         02 background-color 7 foreground-color 6.
          03 line 10 col 13 value "  JAN   FEB   MAR   APR   MAY   JUN
      -" JUL   AUG   SEP   OCT".
          03 line 11 col 13 value "ÚÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂ
      -"ÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄ¿".
          03 occurs 6.
           05 line + 1 col 13 value "³     ³     ³     ³     ³     ³
      -" ³     ³     ³     ³     ³".
           05 line + 1 col 13  value "ÃÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄ
      -"ÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄ´".
          03 line 23 col 13 value "ÀÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁ
      -"ÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÙ".
          03 line 12 col 4 value "Jam".
          03 line + 2 col 4 value "Honey".
          03 line + 2 col 4 value "Sugar".
          03 line + 2 col 4 value "Bread".
          03 line + 2 col 4 value "Flour".
          03 line + 2 col 4 value "Butter".
          03 line 12 col 15.
         02 background-color 7 foreground-color 0.
           04 occurs 6.
            05 occurs 10.
             06 pic 999 using ws-item.
             06 col + 4.
            05 line + 2 col - 60.

       procedure division.
           call x"af" using use-mouse mouse-param
      * activate the mouse
           move 1 to mouse-param
           call x"af" using use-mouse mouse-param
           display g-admouse
           accept g-admouse
      * terminate the mouse
           move 0 to mouse-param
           call x"af" using use-mouse mouse-param
           stop run.
