      $set ans85 mf noosvs
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     DECLARE.CBL                          *
      *                                                          *
      *    This program demonstrates how to use declaratives.    *
      *                                                          *
      ************************************************************

       select input-file   assign to file-name
                           organization sequential
                           file status is file-stat.

       data division.
       file section.

       fd  input-file.
       01  input-rec       pic x(80).

       working-storage section.
       01  file-stat.
           03  f-stat-1    pic x.
           03  f-stat-2    pic x.
           03  f-stat-2-bin redefines f-stat-2
                           pic 9(2) comp-x.
       01  stat-disp.
           03  disp1       pic x.
           03  filler      pic x.
           03  disp2       pic 9(3).

       procedure division.
       declaratives.
       dec-laratives section.
       use after standard error procedure on input-file.
           move f-stat-1 to disp1
           if f-stat-1 = "9"
               move f-stat-2-bin to disp2
           else
               move f-stat-2 to disp2
           end-if
           display "file status :" at 1029
           display stat-disp       at 1049
           stop run.
       end declaratives.

       main section.
       sta-rt.
           display spaces upon crt
           display "enter a non-existant file name :" at 0810
           accept file-name at 0849
           open input input-file
           display "Open worked. Try a different filename."
           stop run.
