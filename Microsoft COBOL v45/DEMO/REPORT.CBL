      $set ans85 noosvs mf
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     REPORT.CBL                           *
      *                                                          *
      *    This is a REPORT WRITER sample.                       *
      *                                                          *
      ************************************************************
       environment division.
       input-output section.
       file-control.
           select datafile assign to "data1.dat"
           organization is line sequential.
           select print-file assign to "idw.dat".
       data division.
       file section.
       fd  datafile.
           01  filler  pic x(80).
       fd  print-file
           record contains 80 characters
           report is control-break.
           01  out-buffer      pic x(80).
       working-storage section.
       01  temp-buffer.
           05  data1   pic x(15).
           05  filler  pic x(65).
       01  flags.
           05  eof-flag        pic xxx value "no ".
               88  end-of-file         value "yes".
       report section.
       rd  control-break
           controls are final data1
           page limit is 63 lines
           heading 1
           first detail 5
           last detail 10.
       01  type is page heading.
           05  line number 1.
               10  column number 50    pic xxxx value "page".
               10  column number 55    pic zzzz9 source page-counter.
       01  detail-line type is detail.
           05  line number plus 1.
               10  column number 5 pic x(15) source data1.
       01  type is control footing final.
           05  line number plus 5.
               10  column number 24    pic x(13) value "this is final".
       procedure division.
           open input datafile.
           open output print-file.
           initiate control-break.
           read datafile into temp-buffer
               at end move "yes" to eof-flag.
           perform 010-read-and-print until end-of-file.
           terminate control-break.
           close datafile print-file.
           stop run.

       010-read-and-print.
           generate detail-line.
           read datafile into temp-buffer
           at end move "yes" to eof-flag.
