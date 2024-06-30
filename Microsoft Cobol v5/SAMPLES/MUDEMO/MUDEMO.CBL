      $set ans85 noosvs mf
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989, 1992             *
      *                                                          *
      *                      MUDEMO.CBL                          *
      *                                                          *
      *                      MULTI-USER                          *
      *                      ==========                          *
      *                 DEMONSTRATION PROGRAM                    *
      *                 =====================                    *
      *                                                          *
      *  This program demonstrates the file and record locking   *
      *  facilities of this COBOL system.   This is the          *
      *  main program in a suite of programs that demonstrate    *
      *  how to use this COBOL in a multi-user environment.      *
      *                                                          *
      ************************************************************

       configuration section.
       special-names.
          console is crt.

       data division.

       working-storage section.
       01  mudemo01-00   .
           03 filler           pic x(0407).
           03 mudemo01-00-0608 pic x(0060) value "This is a demonstratio
      -    "n program for use with COBOL.        ".
           03 FILLER           PIC X(0100).
           03 MUDEMO01-00-0808 PIC X(0058) VALUE "This program demonstra
      -    "tes how multi-user COBOL can        ".
           03 filler           pic x(0102).
           03 mudemo01-00-1008 pic x(0028) value "lock both records and
      -    "files.".
           03 FILLER           PIC X(0212).
           03 MUDEMO01-00-1308 PIC X(0062) VALUE "the program allows an
      -    "indexed file to be opened in a number of".
           03 filler           pic x(0098).
           03 mudemo01-00-1508 pic x(0046) value "modes, which demonstra
      -    "te the locking facility.".
           03 FILLER           PIC X(0114).
           03 MUDEMO01-00-1708 PIC X(0063) VALUE "For more information o
      -    "n locking refer to the COBOL User Guide. ".
           03 filler           pic x(0097).
           03 mudemo01-00-1908 pic x(0007) value "       ".
           03 filler           pic x(0146).
           03 mudemo01-00-2101 pic x(0080) value "----------------------
      -    "----------------------------------------------------------".

       01  options.
           03  filler                   pic x(02).
           03  option-1                 pic x(07)
                   value "1.Input".
           03  filler                   pic x(02).
           03  option-2                 pic x(25)
                   value "2.I-O Lock Mode Automatic".
           03  filler                   pic x(02).
           03  option-3                 pic x(22)
                   value "3.I-O Lock Mode Manual".
           03  filler                   pic x(02).
           03  option-4                 pic x(08)
                   value "4.Output".
           03  filler                   pic x(02).
           03  option-5                 pic x(06)
                   value "5.Exit".


       01  date-to-day.
           03  days                     pic 99.
           03  filler                   pic x.
           03  month                    pic 99.
           03  filler                   pic x.
           03  year                     pic 99.

       01  up-to-date-time.
           03  hours                    pic 99.
           03  filler                   pic x.
           03  mins                     pic 99.

       01  temp-date.
           03  temp-year                pic xx.
           03  temp-month               pic xx.
           03  temp-day                 pic xx.
       01  temp-time.
           03  temp-hours               pic 99.
           03  temp-mins                pic 99.
           03  temp-rest                pic 9999.

       01  choice                       pic 9 value 0.

      **********************************************************
      * Main Program                                           *
      **********************************************************

       procedure division.
       ent-ry.
           display space
           display mudemo01-00
           perform display-date
           perform display-time
           display options at 2201
           display "INPUT CHOICE [ ]" at 2431 upon crt-under.

       re-enter-choice.
           accept choice at 2445.
           evaluate choice
             when 1        call "STOCKIN"
                           cancel "STOCKIN"
             when 2        call "STOCKIOA"
                           cancel "STOCKIOA"
             when 3        call "STOCKIOM"
                           cancel "STOCKIOM"
             when 4        call "STOCKOUT"
                           cancel "STOCKOUT"
             when 5        go to endit
             when other    go to re-enter-choice
           end-evaluate.
           go to ent-ry.

       endit.
           stop run.


      ***********************************************************
      * Date and Time Routines                                  *
      ***********************************************************

       display-date.
          accept temp-date from date.
          move   temp-day to days.
          move   temp-month to month.
          move   temp-year to year.
          display "Date   /  /" at 0164.
          display date-to-day at 0169.

       display-time.
          accept temp-time from time.
          move   temp-hours to hours.
          move   temp-mins to mins.
          display "Time   :" at 0264.
          display up-to-date-time at 0269.
