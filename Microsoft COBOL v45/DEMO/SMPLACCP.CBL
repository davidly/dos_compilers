      $set ans85 noosvs mf
      *******************************************************************
      *                                                                 *
      *                    (C) Micro Focus Ltd. 1990                    *
      *                                                                 *
      *                           SMPLACCP.CBL                          *
      *                                                                 *
      *  This program demonstrates some simple screen handling          *
      *  extensions. It uses DISPLAY and ACCEPT statements to show how  *
      *  you could achieve password masking and reverse-video.          *
      *                                                                 *
      *******************************************************************
       special-names.
           console is crt.

       working-storage section.
       01 into-field          pic x(10).
       01 pass-word           pic x(08).

       procedure division.
           display spaces upon crt.
           display "Please enter your password"    at 0310 upon
                                                           crt-under.
           accept pass-word                        at 0338 with no-echo.
           display "Enter data to be accepted"     at 0510.
           accept into-field                       at 0538 with
                                                           reverse-video
                                                           blink.
           display "The data you entered was => "  at 0710.
           display into-field                      at 0738.

           stop run.
