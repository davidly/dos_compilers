      *************************************************************
      *                                                           *
      *            (C) Micro Focus Ltd. 1991                      *
      *                                                           *
      *                    FUNCTEST.CBL                           *
      *                                                           *
      *   This program demonstrates the use of some of the        *
      *   Intrinsic Functions. Specifically, this program         *
      *   shows:                                                  *
      *      1) the tangent function                              *
      *      2) the mean function                                 *
      *      3) the conversion from Julian date to Gregorian date *
      *      4) the case conversion function                      *
      *      5) the annunity computation function                 *
      *                                                           *
      *************************************************************

       identification division.
       program-id. functest.

       environment division.
       special-names.
           console is crt.
       data division.

       working-storage section.
       01  pi                  pic 9v9(5) value 3.14159.
       01  angle               pic 99v9(5).
       01  mean                pic 99v9(5).
       01  tangent             pic 9v9(5).
       01  real-date           pic 9(8).
       01  jul-date            pic 9(6).
       01  ws-text1            pic x(25) value "Mary had a little lamb".
       01  ws-text2            pic x(25).
       01  annuity             pic 9(4)v99.
       01  percent             pic 9v99  value 8.5.
       01  period              pic 999   value 100.

       01  display-mean        pic z9.9(5).
       01  display-tangent     pic 9.9(5).
       01  display-date        pic 9999/99/99.
       01  display-annuity     pic z(3)9.99.

       01  answer              pic x.

       procedure division.

       runstart.
           display space upon crt.
           display " " at 0901.
           perform tangent-test
           perform mean-test
           perform date-test
           perform string-test
           perform financial-test
           stop run.

       tangent-test.
           move pi to angle
           divide 4 into angle
           compute tangent = function tan(angle)
           move tangent to display-tangent
           display "Tangent of 45 is: "  at 1001
           display  display-tangent at 1040
           display "Press 'Enter' to Continue" at 1515
           perform inbetween.

       mean-test.
           compute mean = function mean(2,7,9,6,11,14)
           move mean to display-mean
           display "Mean of 2,7,9,6,11,14 is: "  at 1001
           display  display-mean at 1040
           display "Press 'Enter' to Continue" at 1515
           perform inbetween.

       date-test.
           move 142566 to jul-date
           compute real-date = function date-of-integer(jul-date)
           move real-date to display-date
           display "Date of Julian Date 142566 is: "  at 1001
           display  display-date at 1040
           display "Press 'Enter' to Continue" at 1515
           perform inbetween.

       string-test.
           move function upper-case(ws-text1) to ws-text2
           display "Upper case of: "  at 1001
           display  ws-text1  at 1020
           display  " is: "  at 1101
           display  ws-text2 at 1120
           display "Press 'Enter' to Continue" at 1515
           perform inbetween.

       financial-test.
           compute annuity = function annuity(percent,period)
           move annuity to display-annuity
           display "Annuity for 8.5% for a period of 100 is: "
              at 1001
           display display-annuity at 1040
           display "Press 'Enter' to Continue" at 1515
           perform inbetween.

       inbetween.
           accept answer at 2401
           display space upon crt.
