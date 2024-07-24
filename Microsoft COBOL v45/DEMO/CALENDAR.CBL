      $SET ans85 noosvs noqual noalter nobell warning(3) noseg align(1)
       WORKING-STORAGE SECTION.
       01  wrk-date.
           03  yymmdd-yy                   PIC 99.
           03  yymmdd-mm                   PIC 99.
           03  yymmdd-dd                   PIC 99.
       01  date-year                       PIC 99  COMP-X.
       01  date-lyear                      PIC 99  COMP-X.
           88  leap-year                   VALUE 1.
       01  am-pm-fld                       PIC XX.
       01  hh-fld                          PIC 99.
       01  month-values.
           03  FILLER                      PIC X(9)  VALUE " JANUARY ".
           03  FILLER                      PIC X(9)  VALUE " FEBUARY ".
           03  FILLER                      PIC X(9)  VALUE "  MARCH  ".
           03  FILLER                      PIC X(9)  VALUE "  APRIL  ".
           03  FILLER                      PIC X(9)  VALUE "   MAY   ".
           03  FILLER                      PIC X(9)  VALUE "  JUNE   ".
           03  FILLER                      PIC X(9)  VALUE "  JULY   ".
           03  FILLER                      PIC X(9)  VALUE " AUGUST  ".
           03  FILLER                      PIC X(9)  VALUE "SEPTEMBER".
           03  FILLER                      PIC X(9)  VALUE " OCTOBER ".
           03  FILLER                      PIC X(9)  VALUE "NOVEMBER ".
           03  FILLER                      PIC X(9)  VALUE "DECEMBER ".
       01  month-value REDEFINES month-values OCCURS 12 PIC X(9).
       01  no-of-days-in-month-table       PIC X(24)
           VALUE "312831303130313130313031".
       01  no-of-days-in-month REDEFINES
           no-of-days-in-month-table
           OCCURS 12                       PIC 99.
       01  day-flds.
           03  OCCURS 5.
               05  OCCURS 7.
                   07  scr-day-fld         PIC 99      COMP-X.
           03  day-36                      PIC 99      COMP-X.
           03  day-37                      PIC 99      COMP-X.
       01  FILLER REDEFINES day-flds.
           03  day-fld OCCURS 37           PIC 99      COMP-X.
       01  hi-flds.
           03  OCCURS 5.
               05  OCCURS 7.
                   07  scr-hi-fld          PIC X(80).
           03  hi-36                       PIC X(80).
           03  hi-37                       PIC X(80).
       01  FILLER REDEFINES hi-flds.
           03  hi-fld OCCURS 37           PIC X(80).
               88  highlight-fld          VALUE "HIGHLIGHT".
       01  day-of-year-group.
           03  FILLER                      PIC XX.
           03  day-of-year                 PIC 999.
       01  day-of-week-fld                 PIC 99.
       01  time-fld.
           03  time-fld-hh                 PIC 99.
           03  time-fld-mm                 PIC 99.
           03  FILLER                      PIC X(4).
       01  day-index                       PIC 99      COMP-X.
       01  count-fld                       PIC 99      COMP-X.
       01  century-fld                     PIC 99      COMP-X.
       01  non-full-week-days              PIC 99      COMP-X.
       01  day-of-month-day-1              PIC 99      COMP-X.
       01  no-of-full-weeks-in-month       PIC 99      COMP-X.
       01  current-day-scr-fld-index       PIC 99      COMP-X.
      /
       Screen SECTION.
       01  calender-screen.
           03  BLANK screen.
           03  LINE 3 COL 64 PIC Z9 FROM hh-fld.
           03         COL 67 PIC 99 FROM time-fld-mm.
           03         COL 70 PIC XX FROM am-pm-fld.
           03  LINE 5 COL 53 PIC 99 FROM century-fld.
           03         COL 55 PIC 99 FROM yymmdd-yy.
           03         COL 60 PIC X(9) FROM month-value(yymmdd-mm).
           03         COL 72 PIC 99 FROM century-fld.
           03         COL 74 PIC 99 FROM yymmdd-yy.
           03  LINE 7 COL 51.
           03  OCCURS 5.
               05  OCCURS 7.
                   07  PIC ZZ FROM scr-day-fld BLANK WHEN ZERO
                           CONTROL IS scr-hi-fld.
                   07  COL + 3.
               05  LINE + 1 COL - 28.
           03  LINE 12.
           03  COL 51 PIC ZZ FROM day-fld(36) BLANK WHEN ZERO
               CONTROL IS hi-fld(36).
           03  COL 55 PIC ZZ FROM day-fld(37) BLANK WHEN ZERO
               CONTROL IS hi-fld(37).
           03  COL 74 PIC 999 FROM day-of-year.
           03  LINE 3 COL 57 VALUE "Time:".
           03  LINE 3 COL 66 VALUE ":".
           03  LINE 6 COL 52 VALUE "S   M   T   W   T   F   S".
           03  LINE 12 COL 61 VALUE "Day of Year:".
      /
       PROCEDURE DIVISION.
       Calender-Main SECTION.
           PERFORM Init-Date-Manipulation.
           DISPLAY calender-screen.
       Program-Exit.
           EXIT PROGRAM.
           STOP RUN.
       Init-Date-Manipulation.
           INITIALIZE day-flds hi-flds
           ACCEPT wrk-date             FROM DATE
           ACCEPT time-fld             FROM TIME
           ACCEPT day-of-week-fld      FROM DAY-OF-WEEK
           ACCEPT day-of-year-group    FROM DAY
           PERFORM Find-Day-1-Of-Month
           PERFORM Set-Time
           PERFORM Set-Century
           PERFORM Set-Day-Flds.
      /
       Find-Day-1-Of-Month.
           DIVIDE yymmdd-dd BY 7 GIVING no-of-full-weeks-in-month
                  REMAINDER non-full-week-days
           IF day-of-week-fld < (non-full-week-days - 1)
               ADD 7 TO day-of-week-fld
           END-IF
           COMPUTE day-of-month-day-1 = day-of-week-fld -
                                        (non-full-week-days - 2)
           IF day-of-month-day-1 > 7
               SUBTRACT 7 FROM day-of-month-day-1
           END-IF.
       Set-Time.
           IF time-fld-hh > 12
               SUBTRACT 12 FROM time-fld-hh GIVING hh-fld
               MOVE "PM" TO am-pm-fld
           ELSE
               MOVE "AM" TO am-pm-fld
               MOVE time-fld-hh TO hh-fld
           END-IF.
       Set-Century.
           IF yymmdd-yy < 88
               MOVE "20" TO century-fld
           ELSE
               MOVE "19" TO century-fld
           END-IF.
       Set-Day-Flds.
           MOVE ZERO TO count-fld
           IF yymmdd-mm = 2
               COMPUTE date-lyear = yymmdd-yy / 4
               COMPUTE date-lyear = date-lyear * 4
               COMPUTE date-year = date-lyear - yymmdd-yy
               COMPUTE date-year = date-year / 4
               IF leap-year
                   ADD 1 to no-of-days-in-month(yymmdd-mm)
               END-IF
           END-IF
           PERFORM VARYING DAY-INDEX FROM 1 BY 1 UNTIL DAY-INDEX > 37
               IF day-index >= day-of-month-day-1 and
                  < (day-of-month-day-1 +
                    no-of-days-in-month(yymmdd-mm))
                   ADD 1 TO count-fld
                   MOVE count-fld TO day-fld(day-index)
               ELSE
                   MOVE ZERO TO day-fld(day-index)
           END-PERFORM
           COMPUTE yymmdd-dd = yymmdd-dd + day-of-month-day-1 - 1
           SET highlight-fld(yymmdd-dd) TO TRUE.
