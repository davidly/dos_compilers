      $set ans85 noosvs mf
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                      TSTDEBUG.CBL                        *
      *                                                          *
      *         This program demonstrates how to make use of     *
      *         the ANSI DEBUGGER facility available within      *
      *         COBOL. ANIMATOR debugging tool is also available *
      *         and would normally be used in preference to      *
      *         the ANSI debugger Essential lines to include     *
      *         are in upper-case                                *
      *                                                          *
      *         To make use of the ANSI debugging facility       *
      *         the program needs to be run with the +D run      *
      *         time switch.                                     *
      *                                                          *
      *         Any line containing a D in column 7 will be      *
      *         treated as a comment line when the               *
      *         WITH DEBUGGING MODE option is removed from the   *
      *         source.                                          *
      *                                                          *
      ************************************************************


       environment division.
       source-computer.  ibm-pc    with debugging mode.
       object-computer.  ibm-pc.
       special-names.
                   console is crt.
       file-control.
       select file1 assign "tst.fil"
       status is file1-stat.
       data division.
       fd file1.
       01 f1-rec pic x(80).
       working-storage section.
       01 counts   pic 99 value 1.
       01 file1-stat.
           02 s1   pic x.
           02 s2   pic x.
       01 stat-bin redefines file1-stat pic 9(4) comp.
       01 display-stat.
           02 messag   pic x(16) value "RUN-TIME ERROR ".
           02 s1-disp  pic x.
           02 filler   pic x value space.
           02 s2-disp  pic 9(4).
       01 out-buff     pic x(80) value all "A".

      ***************************************************************
      *                                                             *
      * OUTS should be 56 bytes + the length of your longest record *
      *                                                             *
      ***************************************************************

         01 outs         pic x(136) value spaces.
      /
       procedure division.

      ***************************************************************
      *                                                             *
      *    DEBUG-ITEM is created by the compiler when the WITH      *
      *    DEBUGGING MODE is specified, and can only be accessed    *
      *    by the use of a MOVE to another 'PIC X(nnn)' field       *
      *                                                             *
      ***************************************************************

       declaratives.
       animator section.
             use for debugging on all procedures.
           display "debugging line" at 2430.
           add 1 to counts.
             move debug-item to outs.
             display outs at 2001.
           display counts at 2445.
       end declaratives.

       main section.
           display spaces
           open output file1.
           if s1 not = 0 perform sect1.
           write f1-rec from out-buff.
           if s1 not = 0 perform sect1.
       close-up section.
           close file1.
           if s1 not = 0 perform sect1.
           stop run.
       sect1 section.
           move s1 to s1-disp.
           move low-values to s1.
           move stat-bin to s2-disp.
           display display-stat.


