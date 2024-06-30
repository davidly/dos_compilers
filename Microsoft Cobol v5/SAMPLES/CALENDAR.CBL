      $SET ANS85 NOOSVS WARNING(3) NOMFCOMMENT
      ******************************************************************
      *                                                                *
      *                 (C) Micro Focus Ltd. 1991                      *
      *                                                                *
      *                        CALENDAR.CBL                            *
      *                                                                *
      *  This program displays a calendar on the screen                *
      *                                                                *
      *  This program demonstrates:                                    *
      *                                                                *
      *    o How to work out what day of the week the first day of the *
      *      month is;                                                 *
      *    o How to find out whether a particular year is a leap year; *
      *    o Using a run-time system routine to determine whether the  *
      *      monitor is color or mono.                                 *
      *                                                                *
      *  COBOL features used in this program include:                  *
      *                                                                *
      *    o The Intrinsic functions - REM, DATE-OF-INTEGER,           *
      *      DAY-OF-INTEGER and INTEGER-OF-DATE;                       *
      *    o ACCEPT...TIME-OUT;                                        *
      *    o level 78 literals;                                        *
      *    o CONTROL to dynamically set colors;                        *
      *    o Nested OCCURS in SCREEN SECTION;                          *
      *    o ANSI '85 omission of FILLER;                              *
      *    o CODASYL continuation lines;                               *
      *    o In line comments                                          *
      *    o Reference modification.                                   *
      *                                                                *
      ******************************************************************
       01  wrk-date.
           03  wrk-date-yyyymmdd           PIC 9(8).
           03  redefines wrk-date-yyyymmdd.
             04 wrk-date-yyyy.
               05  wrk-date-cc             PIC 99.
               05  wrk-date-yy             PIC 99.
             04 .
               05  wrk-date-mm             PIC 99.
               05  wrk-date-dd             PIC 99.
           03  wrk-time.
               05  wrk-date-hh             PIC 99.
               05  wrk-date-min            PIC 99.
               05                          PIC X(9).
       01  tmp-date-yyyymmdd               PIC 9(8).
       01  REDEFINES tmp-date-yyyymmdd.
           03                              PIC x(6).
           03  tmp-date-dd                 PIC 99.
       01  tmp-date-yyyy0228-grp.
           03 tmp-date-yyyy0228-year       PIC 9(4).
           03                              PIC 9(4)          VALUE 0228.
       01  tmp-date-yyyy0228 REDEFINES tmp-date-yyyy0228-grp PIC 9(8).
       01  tmp-date-yyyy0301-grp.
           03 tmp-date-yyyy0301-year       PIC 9(4).
           03                              PIC 9(4)          VALUE 0301.
       01  tmp-date-yyyy0301 REDEFINES tmp-date-yyyy0301-grp PIC 9(8).
       01  am-pm-fld                       PIC XX.
       01  month-values.
           03  PIC X(10)  VALUE " JANUARY ".   *>  Note that "FILLER"
           03  PIC X(10)  VALUE " FEBRUARY ".  *>  is missing
           03  PIC X(10)  VALUE "  MARCH  ".
           03  PIC X(10)  VALUE "  APRIL  ".
           03  PIC X(10)  VALUE "   MAY   ".
           03  PIC X(10)  VALUE "  JUNE   ".
           03  PIC X(10)  VALUE "  JULY   ".
           03  PIC X(10)  VALUE " AUGUST  ".
           03  PIC X(10)  VALUE "SEPTEMBER".
           03  PIC X(10)  VALUE " OCTOBER ".
           03  PIC X(10)  VALUE "NOVEMBER ".
           03  PIC X(10)  VALUE "DECEMBER ".
       01  month-value REDEFINES month-values OCCURS 12 PIC X(10).
       01  no-of-days-in-month-table PIC X(24) VALUE
               "310031303130313130313031".
       01  no-of-days-in-month REDEFINES
               no-of-days-in-month-table OCCURS 12 PIC 99.
       01  month-table-days PIC x(62) Value "0102030405"
            & "0607080910111213141516171819202122232425262728293031" .
       01  day-flds.
           03  OCCURS 5.
               05  OCCURS 7.
                   07  scr-day-fld         PIC 99     VALUE ZERO.
           03  day-36                      PIC 99     VALUE ZERO.
           03  day-37                      PIC 99     VALUE ZERO.
       78  no-of-date-display-flds         VALUE 37.
       01  REDEFINES day-flds.
           03  day-fld OCCURS
                   no-of-date-display-flds     PIC 99.
       01  Screen-Attributes.
           03  hi-flds.
               05  OCCURS 5.
                   07  OCCURS 7.
                       09  scr-hi-fld      PIC X(80).
               05  hi-36                   PIC X(80).
               05  hi-37                   PIC X(80).
           03  REDEFINES hi-flds.
               05  hi-fld OCCURS no-of-date-display-flds
                       INDEXED BY hi-fld-index PIC X(80).
                   88  highlight-fld       VALUE "HIGHLIGHT".
           03  time-colour                 PIC X(80).
           03  day-col                     PIC X(80).
           03  fld-col                     PIC X(80).
           03  mnt-col                     PIC X(80).
       01  day-of-year-group               PIC 9(7).
       01  REDEFINES day-of-year-group.
           03                              PIC 9999.
           03  day-of-year                 PIC 999.
       01  day-of-month-day-1              PIC 99     COMP-X.
       01  stop-fld                        PIC X.
           88  asked-to-stop               VALUE "1".
       01  today-no                        PIC 9(8).
       01  time-fld                        PIC 9      VALUE 1.
       01  A7-TEST-MONITOR-FUNCTION        PIC X      COMP-X  VALUE 25.
       01  A7-TEST-MONITOR-PARAMETER       PIC X      COMP-X.
           88 colour-display               VALUE 1.
      *******************************************************************
      * The following are color literals for use in CONTROL clause,     *
      * have to be alphanumeric rather than numeric since they're used  *
      * in a STRING statement.                                          *
      *******************************************************************
       78  BLUE                            VALUE "1".
       78  GREEN                           VALUE "2".
       78  CYAN                            VALUE "3".
       78  RED                             VALUE "4".
       78  MAGENTA                         VALUE "5".
       78  YELLOW                          VALUE "6".
       SCREEN SECTION.
       01 calendar-screen.
         02 calendar-screen-text.
           03 BLANK SCREEN.
           03 LINE 3  COL 57 VALUE "Time:" CONTROL IS time-colour.
           03         COL 66 VALUE ":"     CONTROL IS time-colour.
           03 LINE 6  COL 52 VALUE "S   M   T   W   T   F   S"
                   CONTROL IS day-col.
           03 LINE 12 COL 61 VALUE "Day of Year:" CONTROL IS day-col.
         02 calendar-screen-flds.
           03 LINE 3 COL 64 PIC Z9 FROM wrk-date-hh  CONTROL IS fld-col.
           03        COL 67 PIC 99 FROM wrk-date-min CONTROL IS fld-col.
           03        COL 70 PIC XX FROM am-pm-fld    CONTROL IS fld-col.
           03 LINE 5 COL 53 PIC 99 FROM wrk-date-cc  CONTROL IS fld-col.
           03        COL 55 PIC 99 FROM wrk-date-yy  CONTROL IS fld-col.
           03        COL 60 PIC X(10) FROM month-value(wrk-date-mm)
                        CONTROL IS mnt-col.
           03        COL 72 PIC 99 FROM wrk-date-cc  CONTROL IS fld-col.
           03        COL 74 PIC 99 FROM wrk-date-yy  CONTROL IS fld-col.
           03 LINE 7 COL 51.
           03 OCCURS 5.
              05 OCCURS 7.
                 07 PIC 99 FROM scr-day-fld BLANK WHEN ZERO
                        CONTROL IS scr-hi-fld.
                 07  COL + 3.
              05 LINE + 1 COL - 28.
           03 LINE 12.
           03 COL 51 PIC ZZ FROM day-fld(36) BLANK WHEN ZERO
                   CONTROL IS hi-fld(36).
           03 COL 55 PIC ZZ FROM day-fld(37) BLANK WHEN ZERO
                   CONTROL IS hi-fld(37).
           03 COL 74 PIC 999 FROM day-of-year CONTROL IS fld-col.

       PROCEDURE DIVISION.
       Calender-Main SECTION.
           PERFORM Initial-setup
           PERFORM VARYING today-no from today-no by 1 until
                   asked-to-stop
               INITIALIZE day-flds hi-flds
               PERFORM Set-colours
               COMPUTE day-of-year-group =
                   FUNCTION DAY-OF-INTEGER (today-no)
               COMPUTE wrk-date-yyyymmdd =
                   FUNCTION DATE-OF-INTEGER (today-no)
               PERFORM Find-Day-1-Of-Month
               PERFORM Set-Time
               PERFORM Set-Day-Flds
               DISPLAY calendar-screen-flds
               ACCEPT stop-fld AT 0101 TIME-OUT AFTER time-fld
                       WITH NO-ECHO AUTO-SKIP
                   ON EXCEPTION        CONTINUE
                   NOT ON EXCEPTION    SET asked-to-stop TO TRUE
               END-ACCEPT
          END-PERFORM
       GOBACK.
       Initial-setup.
          MOVE FUNCTION CURRENT-DATE to wrk-date
          COMPUTE today-no =
               FUNCTION INTEGER-OF-DATE (wrk-date-yyyymmdd)
          INITIALIZE Screen-Attributes
          CALL X"A7" USING A7-TEST-MONITOR-FUNCTION
                           A7-TEST-MONITOR-PARAMETER
          IF FUNCTION REM (A7-TEST-MONITOR-PARAMETER , 2) = 1
              SET colour-display TO TRUE
              STRING "HIGHLIGHT FOREGROUND-COLOUR "
                     CYAN DELIMITED BY SIZE INTO time-colour
              STRING "HIGHLIGHT FOREGROUND-COLOUR "
                     BLUE DELIMITED BY SIZE INTO day-col
              STRING "HIGHLIGHT FOREGROUND-COLOUR "
                     RED DELIMITED BY SIZE INTO fld-col
              STRING "HIGHLIGHT FOREGROUND-COLOUR "
                     MAGENTA DELIMITED BY SIZE INTO mnt-col
          END-IF
          DISPLAY calendar-screen-text.
       Set-colours.
          IF colour-display
              PERFORM VARYING hi-fld-index FROM 1 BY 1 UNTIL
                  hi-fld-index > no-of-date-display-flds
                  STRING "FOREGROUND-COLOUR "
                     YELLOW DELIMITED BY SIZE INTO hi-fld(hi-fld-index)
              END-PERFORM
          END-IF.
       Find-Day-1-Of-Month.    *> Sunday is Zero - Saturday is 6
          MOVE wrk-date-yyyymmdd TO tmp-date-yyyymmdd
          MOVE 01 TO tmp-date-dd
          COMPUTE day-of-month-day-1 =
              FUNCTION REM (
              FUNCTION INTEGER-OF-DATE (tmp-date-yyyymmdd)  , 7).
       Set-Time.
          ACCEPT wrk-time FROM TIME
          EVALUATE wrk-date-hh
              WHEN 0 thru 11
                  MOVE "AM" TO am-pm-fld
              WHEN 12
                  MOVE "PM" TO am-pm-fld
              WHEN 13 thru 23
                  SUBTRACT 12 FROM wrk-date-hh
                  MOVE "PM" TO am-pm-fld
          END-EVALUATE.
       Set-Day-Flds.
          IF wrk-date-mm = 2
              move wrk-date-yyyy to tmp-date-yyyy0228-year
                                    tmp-date-yyyy0301-year
              IF (FUNCTION INTEGER-OF-DATE (tmp-date-yyyy0228) + 2) =
                 FUNCTION INTEGER-OF-DATE  (tmp-date-yyyy0301)
                  MOVE 29 TO no-of-days-in-month(2)
              ELSE
                  MOVE 28 TO no-of-days-in-month(2)
              END-IF
          END-IF
          MOVE month-table-days(1 : no-of-days-in-month(wrk-date-mm)
                * 2 ) TO
                day-flds((2 * day-of-month-day-1) + 1 :
                no-of-days-in-month(wrk-date-mm) * 2)
          COMPUTE tmp-date-dd = wrk-date-dd + day-of-month-day-1
          IF colour-display
              STRING "HIGHLIGHT FOREGROUND-COLOUR "
                      GREEN DELIMITED BY SIZE INTO hi-fld(tmp-date-dd)
          ELSE
              SET highlight-fld(tmp-date-dd) TO TRUE
          END-IF.
