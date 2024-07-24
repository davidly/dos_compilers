      $set ans85 noosvs mf
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     PRINTESC.CBL                         *
      *                                                          *
      *    This program demonstrates how to send escape          *
      *    sequences to a printer.  In this case, an Okidata 93  *
      *    parallel printer was used and the escape sequences in *
      *    question were to set form length to either "7" or     *
      *    "11".  To determine the proper escape sequences for   *
      *    the printer in question, consult your printer manual. *
      *                                                          *
      ************************************************************

       file-control.
           select   print-file            assign "LPT1".

       data division.
       file section.
       fd  print-file.
       01  print-record                   pic x(60).

       working-storage section.

       01  form-length-11                 pic x(4)  value x"1b43000b".
       01  form-length-7                  pic x(4)  value x"1b430007".
       01  form-feed                      pic x     value x"0c".
       01  first-line                     pic x(10) value "First Line".
       01  last-line                      pic x(9)  value "Last Line".

       procedure division.
       main-line.
           open output print-file.
           perform set-printer-to-7-inches.
           perform set-printer-to-11-inches.
       main-line-end.

       exit program.
           close print-file.
           stop run.
       exit-program-end.

       set-printer-to-7-inches.
           write print-record from form-length-7.
           write print-record from first-line.
           write print-record from form-feed.
           write print-record from last-line.
       set-printer-to-7-inches-end.

       set-printer-to-11-inches.
           write print-record from form-length-11.
           write print-record from first-line.
           write print-record from form-feed.
           write print-record from last-line.
       set-printer-to-11-inches-end.
