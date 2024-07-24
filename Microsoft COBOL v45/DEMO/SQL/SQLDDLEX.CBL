      $set mf warning(3)
      $set sql sqlinit
      ***************************************************************
      *                                                             *
      *     (c) Micro Focus Ltd. 1990                               *
      *                                                             *
      *        SQLDDLEX                                             *
      *                                                             *
      *        This program  executes single or multiple SQL DDL    *
      *        Data Definition Language statements from a file      *
      *        defined by user parameters.                          *
      *        Parameters may be command line, file or interactive. *
      *        SQL DDL statements must be delimited, the delimiter  *
      *        is specified by user parameter, the default is <;>   *
      *        (semi-colon).                                        *
      *                                                             *
      *        FILES                                                *
      *        =====                                                *
      *                                                             *
      *        1. parameter-ds                                      *
      *                                                             *
      *        This file is read-only, and can contain parameters   *
      *        to control the execution of the program in 'batch'   *
      *        or 'detached' run modes.                             *
      *                                                             *
      *        The name of this file is hard coded.                 *
      *                                                             *
      *        2. message-ds                                        *
      *                                                             *
      *        This file is write-only, and logs program activity.  *
      *        Each run appends to the file, so occasional clearing *
      *        is required.                                         *
      *                                                             *
      *        The name of this file is hard coded.                 *
      *                                                             *
      *        3. dbmddl-ds                                         *
      *                                                             *
      *        This file is read-only, and contains the OS/2        *
      *        Database Manager SQL Data Definition Language (DDL)  *
      *        which is to be executed against the database         *
      *        in the parameters.                                   *
      *                                                             *
      *        The name of this file is specified by parameter.     *
      *                                                             *
      *        RUNNING                                              *
      *        =======                                              *
      *                                                             *
      *        The program is controlled by parameters.             *
      *        The parameters may be specified interactively,       *
      *        in a file, and on the command line.                  *
      *                                                             *
      *        These methods of specifying parameters may be        *
      *        mixed by entering the correct run MODE TYPE (MT)     *
      *        parameter when invoking the program.                 *
      *                                                             *
      ***************************************************************
       environment division.
      *=====================
       configuration section.
      *======================
       special-names.
      *==============
               command-line is os2-cmd-line.
      *
       input-output section.
      *=====================
      *
       file-control.
      *=============
      *
       select parameter-ds
               assign to dynamic parameter-ds-z1
               organization is line sequential
               file status is file-status-z1
               .
       select message-ds
               assign to dynamic message-ds-z1
               organization is line sequential
               file status is file-status-z1
               .
       select dbmddl-ds
               assign to dynamic dbmddl-ds-z1
               organization is line sequential
               file status is file-status-z1
               .

       data division.
      *==============

       file section.
      *=============

       fd parameter-ds
       recording mode v.
      *=================

       01 parameter-rec.
        03 parameter-line                  pic x(80).

       fd message-ds.
      *==============

       01 message-rec.
        03 message-line                    pic x(80).

       fd dbmddl-ds.
      *=============

       01 dbmddl-rec.
        03 dbmddl-line                     pic x(80).
      * Redefines enables character by character move of DDL
      * into the PREPARE buffer to remove redundant spaces
        03 dbmddl-char
           redefines
           dbmddl-line                     pic x
                                           occurs 80.

       working-storage section.
      *========================
      *
       exec sql include sqlca end-exec.

       exec sql begin declare section end-exec.

      * Large buffer for SQL PREPARE
       01 dbm-util-a0.
        03 dbm-statement-a0.
         49 dbm-statement-len-a0           pic s9(4) comp-5.
         49 dbm-statement-text-a0          pic x(32640).

       exec sql end declare section end-exec.

      * Area for set up of PREPARE buffer defined as occurs
      * to enable character by character move / space stripping
       01 dbm-util-a1.
        03 dbm-statement-a1.
         49 dbm-ddl-char-a1                pic x
                                           occurs 32640.

      * Log file formatted message area
       01 message-line-01-a1.
        03 message-lines-a1.
         05 mess-line-1-a1.
          07 margin-a1                     pic x(20).
          07 literal-1-1-a1                pic x(8).
          07 date-a1                       pic x(8).
          07 literal-1-2-a1                pic x(8).
          07 time-a1                       pic x(6).
          07 space-1-1-a1                  pic x(30).
         05 mess-line-2-a1.
          07 mess-text-a1.
           09 param-name-a1                pic x(2).
           09 space-2-1-a1                 pic x(6).
           09 param-value-a1               pic x(32).
           09 space-2-2-a1                 pic x(30).
          07 mess-dbmcode-a1               pic -9(9).
        03 message-line-n-a1
           redefines
           message-lines-a1                pic x(80)
                                           occurs 2.

      * Flags, hard coded names, counts, file status etc
       01 utils-z1.
        03 delimiter-found-z1              pic s9(4) comp-5.
        03 dbm-statement-found-z1          pic s9(4) comp-5.
        03 date-z1                         pic x(6).
        03 time-z1                         pic x(8).
        03 parameter-ds-z1                 pic x(64)
                                           value
       'd:\test\SQLDDLEX\SQLDDLEX.par'.
        03 end-parameter-ds-z1             pic s9(4) comp-5
                                           value -1.
        03 end-dbmddl-ds-z1                pic s9(4) comp-5
                                           value -1.
        03 message-ds-z1                   pic x(64)
                                           value
           'd:\test\SQLDDLEX\SQLDDLEX.log   '.
        03 dbmddl-ds-z1                    pic x(64).

        03 dbm-message-z1.
         05 dbm-message-text-z1            pic x(70).
         05 dbmcode-z1                     pic -9(9).
        03 dbm-error-z1                    pic s9(4) comp-5
                                           value -1.
        03 dbm-codes-allowable-z1.
         05 allow-dbmcode-z1               pic s9(4) comp-5.
        03 files-opened-z1.
         05 message-ds-open-z1             pic s9(4) comp-5.
         05 parameter-ds-open-z1           pic s9(4) comp-5.
         05 dbmddl-ds-open-z1              pic s9(4) comp-5.
        03 file-status-z1                  pic x(2).
        03 last-file-status-z1.
         05 last-file-status-x-z1          pic x.
         05 last-file-status-b-z1          pic 99 comp-x.
        03 display-file-status-z1.
         05 literal-status-z1              pic xx
                                           value "9/".
         05 display-status-z1              pic 999.
        03 current-file-z1                 pic x(12)
                                           value space.
        03 mt-parameter-found-z1           pic s9(4) comp-5.
        03 mode-type-save-z1               pic x(2).
        03 char-sub-1-z1                   pic s9(4) comp-5.
        03 char-sub-2-z1                   pic s9(4) comp-5.
        03 dbm-statement-sub-z1            pic s9(4) comp-5.
        03 ddl-char-action-z1              pic s9(4) comp-5.

      * Area for parameter storage in correct pictures
       01 parameters-z2.
        03 mode-z2                         pic x.
        03 db-z2                           pic x(8).
        03 delimiter-z2                    pic x
                                           value ";".
        03 dbmddl-ds-z2                    pic x(64).

      * Area for parameter specification
       01 parameter-util-z3.
        03 param-cmd-line-z3.
         05 param-cmd-line-1-z3            pic x(120).
        03 parameter-name-z3               pic x(4).
        03 parameter-value-z3              pic x(64).
        03 parameter-error-z3              pic s9(4) comp-5
                                           value -1.
        03 last-parameter-z3               pic s9(4) comp-5
                                           value -1.
        03 parameter-table-z3.
         05 parameter-1-z3                 pic x(2)
                                           value 'MT'.
         05 parameter-1-ok-z3              pic s9(4) comp-5.
         05 parameter-2-z3                 pic x(2)
                                           value 'DB'.
         05 parameter-2-ok-z3              pic s9(4) comp-5.
         05 parameter-3-z3                 pic x(2)
                                           value 'DL'.
         05 parameter-3-ok-z3              pic s9(4) comp-5.
         05 parameter-4-z3                 pic x(2)
                                           value 'FN'.
         05 parameter-4-ok-z3              pic s9(4) comp-5.
        03 parameters-z3
           redefines
           parameter-table-z3              occurs 4.
         05 parameter-name-n-z3            pic x(2).
         05 parameter-ok-n-z3              pic s9(4) comp-5.
        03 parameter-subscript-z3          pic s9(4) comp-5.
        03 get-pars-type-z3                pic x.

      * Temporary area for parameters whilst checked
       01 parameter-util-z4.
        03 param-cmd-line-z4.
         05 param-cmd-line-1-z4            pic x(120).
        03 parameter-name-z4               pic x(4).
        03 parameter-value-z4              pic x(64).
        03 parameter-error-z4              pic s9(4) comp-5
                                           value -1.
        03 parameter-table-z4.
         05 param-val-1-z4                 pic x(64).
         05 param-val-2-z4                 pic x(64).
         05 param-val-3-z4                 pic x(64).
         05 param-val-4-z4                 pic x(64).
        03 parameters-z4
           redefines
           parameter-table-z4              occurs 4.
         05 param-val-n-z4                 pic x(64).
        03 parameter-subscript-z4          pic s9(4) comp-5.

      * Data items for DBM CALL to start_using_database
       01 dbm-call.
        03 spare1                         pic 9(4) comp-5 value 0.
        03 db-length                      pic 9(4) comp-5 value 0.
        03 spare2                         pointer.
        03 database                       pic x(10).
        03 d-use                          pic 9(4) comp-5.
        03 u                              pic x redefines d-use.

       procedure division.
      *===================
      *
       a-1-start.
      *==========
      *
      * Start up and main control
               perform a-2-initial
               if  parameter-error-z3 negative
                   if  parameter-ok-n-z3(2) positive
                   and parameter-ok-n-z3(4) positive
                      perform a-3-main
                   else
                      move "Not all mandatory parameters specified"
                      to   message-line
                      perform z-1-write-message-rec
                   end-if
               end-if
               perform z-9-stop
               .
      *
       a-2-initial.
      *============
      *
      * Examine command line invoking program and ensure
      * at least MT (mode type) parameter specified
      *
      * Initialise log for this run, control parameter read and check
      *
               move -1 to message-ds-open-z1
               move -1 to parameter-ds-open-z1
               move -1 to allow-dbmcode-z1
               accept param-cmd-line-z4 from os2-cmd-line
               unstring param-cmd-line-z4
                        delimited by space
                        into
                             param-val-n-z4(1)
                             param-val-n-z4(2)
                             param-val-n-z4(3)
                             param-val-n-z4(4)
               end-unstring
               move -1 to mt-parameter-found-z1
               perform with test before
                       varying parameter-subscript-z4
                       from    1
                       by      1
                       until parameter-subscript-z4 > 4
                       or    mt-parameter-found-z1 positive
                       move space to parameter-name-z4
                       move space to parameter-value-z4
                       unstring param-val-n-z4(parameter-subscript-z4)
                          delimited by "="
                          into
                          parameter-name-z4
                          parameter-value-z4
                       end-unstring
                       if  parameter-name-z4 = "MT"
                           move 1 to mt-parameter-found-z1
                           move parameter-value-z4 to mode-type-save-z1
                       end-if
               end-perform
               move 'Messages' to current-file-z1
               open extend message-ds
               if  file-status-z1 = '00'
                   move 1 to message-ds-open-z1
               else
                   move file-status-z1 to last-file-status-z1
                   perform z-4-bad-file-status
                   perform z-9-stop
               end-if
               accept date-z1 from date
               accept time-z1 from time
               move space to message-line-01-a1
               move "===> SQLDDLEX" to margin-a1
               move " Date:  " to literal-1-1-a1
               move date-z1 to date-a1
               move " Time:  " to literal-1-2-a1
               move time-z1 to time-a1
               move message-line-n-a1(1) to message-line
               perform z-1-write-message-rec
               move space to message-line-01-a1
               if  mt-parameter-found-z1 negative
                   move "No mode type parameter specified"
                   to message-line
                   perform z-1-write-message-rec
                   move 1 to parameter-error-z3
               end-if
               perform with test before
                       varying parameter-subscript-z3
                       from 1 by 1
                       until   parameter-subscript-z3 > 4
                       move -1
                       to parameter-ok-n-z3(parameter-subscript-z3)
               end-perform
               perform a-4-help
               perform a-9-parameter-sequence
               .
      *
       a-3-main.
      *=========
      *
      *
      * Parameters are OK, so now open up the DDL file and start
      * using the correct datbase.
      *
      * Control for the reception and execution of DDL statements
      *
               move 'SQLDDL' to current-file-z1
               open input dbmddl-ds
               if  file-status-z1 = '00'
                   move 1 to dbmddl-ds-open-z1
               else
                   move file-status-z1 to last-file-status-z1
                   perform z-4-bad-file-status
                   perform z-9-stop
               end-if
               move "++++++++ DDL follows (if found) ++++++++"
               to   message-line
               perform z-1-write-message-rec
               move db-z2 to database
               move zero to db-length
               inspect database
                       tallying db-length
                       for characters before initial space
      * Value 83 here causes character <S> in u data item of CALL
      * This sets database usage to SHARE
               move 83 to d-use
               call    "__SQLGSTPD"
               using   sqlca
               if  sqlcode not = 0
                   perform z-2-dbm-error
               end-if
               call    "__SQLGSTRD"
               using   database
                       spare2
                       sqlca
                       by value d-use
                       by value db-length
                       by value spare1
               if  sqlcode not = 0
                   perform z-2-dbm-error
               end-if
               perform with test before
                       until end-dbmddl-ds-z1 positive
                       or    dbm-error-z1     positive
                   perform b-3-1-get-ddl-statement
                   if  dbm-statement-found-z1 positive
                       perform b-3-2-exec-ddl-statement
                   end-if
               end-perform
               .
      *
       a-4-help.
      *=========
      *
      * If no parameters specified or help requested
      * put parameter details into LG
      *
               if  param-cmd-line-z4 = space
               or  param-cmd-line-z4 = "H"
               or  param-cmd-line-z4 = "h"
               or  param-cmd-line-z4 = "HELP"
               or  param-cmd-line-z4 = "Help"
               or  param-cmd-line-z4 = "help"
                   move 1 to parameter-error-z3
                   move "Parameter names and meaning/values follow."
                   to   message-line
                   perform z-1-write-message-rec
                   move "Parameters can be in any sequence."
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "MT=0<value<16 where value is mode-type"
                   to   message-line
                   perform z-1-write-message-rec
                   move "DB=<database name>"
                   to message-line
                   perform z-1-write-message-rec
                   move "DL=<delimiter character>"
                   to   message-line
                   perform z-1-write-message-rec
                   move "FN=<Source file name for DDL statements>"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
               end-if
               .
      *
       a-5-file-parameters.
      *====================
      *
      * Initialisation and control of reception of file parameters
      *
               if  parameter-error-z3 negative
                   move 'Parameters' to current-file-z1
                   open input parameter-ds
                   if  file-status-z1 = '00'
                       move 1 to parameter-ds-open-z1
                   else
                       move file-status-z1 to last-file-status-z1
                       perform z-4-bad-file-status
                       perform z-9-stop
                   end-if
                   perform b-2-1-get-pars-f
               end-if
               .
      *
       a-6-command-parameters.
      *=======================
      *
      * Control of reception of command line parameters
      *
               if  parameter-error-z3 negative
                   perform b-2-0-get-pars-c
               end-if
               .
      *
       a-7-interactive-parameters.
      *===========================
      *
      * Control of reception of interactive parameters
      *
               if  parameter-error-z3 negative
                   perform b-2-2-get-pars-i
               end-if
               .
      *
       a-9-parameter-sequence.
      *=======================
      *
      * LOTS OF CHOICE HERE - ALL POSSIBLE COMBINATIONS
      * You may want to comment out the ones you don't want active
      *
      * The differing sequence of reading parameters may offer a
      * suitable choice for your environment or specific needs
      *
      * NOTE that the MT parameter is ONLY valid on the command line
      *
               if  parameter-error-z3 negative
                   evaluate true
                   when  mode-type-save-z1 = "1"
                       perform a-6-command-parameters
                   when  mode-type-save-z1 = "2"
                       perform a-5-file-parameters
                   when  mode-type-save-z1 = "3"
                       perform a-7-interactive-parameters
                   when  mode-type-save-z1 = "4"
                       perform a-6-command-parameters
                       perform a-5-file-parameters
                   when  mode-type-save-z1 = "5"
                       perform a-5-file-parameters
                       perform a-6-command-parameters
                   when  mode-type-save-z1 = "6"
                       perform a-6-command-parameters
                       perform a-7-interactive-parameters
                   when  mode-type-save-z1 = "7"
                       perform a-7-interactive-parameters
                       perform a-6-command-parameters
                   when  mode-type-save-z1 = "8"
                       perform a-5-file-parameters
                       perform a-7-interactive-parameters
                   when  mode-type-save-z1 = "9"
                       perform a-7-interactive-parameters
                       perform a-5-file-parameters
                   when  mode-type-save-z1 = "10"
                       perform a-6-command-parameters
                       perform a-7-interactive-parameters
                       perform a-5-file-parameters
                   when  mode-type-save-z1 = "11"
                       perform a-7-interactive-parameters
                       perform a-6-command-parameters
                       perform a-5-file-parameters
                   when  mode-type-save-z1 = "12"
                       perform a-6-command-parameters
                       perform a-5-file-parameters
                       perform a-7-interactive-parameters
                   when  mode-type-save-z1 = "13"
                       perform a-5-file-parameters
                       perform a-6-command-parameters
                       perform a-7-interactive-parameters
                   when  mode-type-save-z1 = "14"
                       perform a-5-file-parameters
                       perform a-7-interactive-parameters
                       perform a-6-command-parameters
                   when  mode-type-save-z1 = "15"
                       perform a-7-interactive-parameters
                       perform a-5-file-parameters
                       perform a-6-command-parameters
                   when other
                       move "Invalid mode type (MT) specified follows:"
                       to   message-line
                       perform z-1-write-message-rec
                       move mode-type-save-z1
                       to   message-line
                       perform z-1-write-message-rec
                       move 1 to parameter-error-z3
                   end-evaluate
               end-if
               .
      *
       b-2-0-get-pars-c.
      *=================
      *
      * Get parameters from the command line
      * LOG the source and each parameter
      *
               move 'Command line parameters:'
               to   message-line
               perform z-1-write-message-rec
               perform with test before
                       varying parameter-subscript-z4
                       from    1
                       by      1
                       until parameter-subscript-z4 > 4
                       or    parameter-error-z3 positive
                       or    last-parameter-z3 positive
                       move space to parameter-name-z4
                       move space to parameter-value-z4
                       unstring param-val-n-z4(parameter-subscript-z4)
                          delimited by "="
                          into
                          parameter-name-z4
                          parameter-value-z4
                       end-unstring
                       if  parameter-name-z4 = space
                           move 1 to last-parameter-z3
                       else
                           move parameter-name-z4
                           to   parameter-name-z3
                           move parameter-value-z4
                           to   parameter-value-z3
                           move 'C' to get-pars-type-z3
                           perform c-2-0-what-par
                       end-if
               end-perform
               .
      *
       b-2-1-get-pars-f.
      *=================
      *
      * Get and control check for parameters from the parameter file
      * LOG the source and each parameter
      *
               move 'File parameters file name follows:'
               to   message-line
               perform z-1-write-message-rec
               move parameter-ds-z1
               to   message-line
               perform z-1-write-message-rec
               perform until end-parameter-ds-z1 = 1
                       or    parameter-error-z3 positive
                   read parameter-ds
                        at end
                        move 1 to end-parameter-ds-z1
                   end-read
                   if end-parameter-ds-z1 negative
                      unstring parameter-line
                               delimited by '='
                               into parameter-name-z3
                                    parameter-value-z3
                      end-unstring
                      move 'F' to get-pars-type-z3
                      perform c-2-0-what-par
                   end-if
               end-perform
               .
      *
       b-2-2-get-pars-i.
      *=================
      *
      * Get and control check for parameters from the screen
      * LOG the source and each parameter
      *
               move 'Interactive parameters:'
               to   message-line
               perform z-1-write-message-rec
               perform varying parameter-subscript-z3
                       from    2
                       by      1
                       until parameter-subscript-z3 > 4
                       move parameter-name-n-z3(parameter-subscript-z3)
                       to   parameter-name-z3
                       if  parameter-ok-n-z3(parameter-subscript-z3)
                           negative
                           display 'Please enter value for '
                                   parameter-name-z3
                           accept parameter-value-z3
                           move 'I' to get-pars-type-z3
                           perform c-2-0-what-par
                       end-if
               end-perform
               .
      *
       b-3-1-get-ddl-statement.
      *========================
      *
      * Move the DDL file SQL statements into the PREPARE buffer
      * one character at a time, ignoring redundant spaces and comments
      * until the delimiter is reached or file end on the DDL file
      * LOG each line read from the DDL file
      *
               move -1 to delimiter-found-z1
               move zero to dbm-statement-sub-z1
               move -1 to dbm-statement-found-z1
               perform until delimiter-found-z1 positive
                       or    end-dbmddl-ds-z1   positive
                   perform z-3-read-dbmddl-ds
                   if  end-dbmddl-ds-z1 negative
                       move dbmddl-rec to message-line
                       perform z-1-write-message-rec
                       perform with test before
                           varying char-sub-1-z1
                           from 1 by 1
                           until char-sub-1-z1 > 80
                       if  char-sub-1-z1 < 80
                           add 1 char-sub-1-z1
                               giving char-sub-2-z1
                       end-if
                       if  dbmddl-char(char-sub-1-z1)
                           = space
                       and dbmddl-char(char-sub-2-z1)
                           = space
                           move 0 to ddl-char-action-z1
                       end-if
                       if  dbmddl-char(char-sub-1-z1)
                           not = space
                       and dbmddl-char(char-sub-1-z1)
                           not = delimiter-z2
                       and dbmddl-char(char-sub-1-z1)
                           not = "-"
                           move 1 to ddl-char-action-z1
                           add 1 to dbm-statement-sub-z1
                           move dbmddl-char(char-sub-1-z1)
                           to   dbm-ddl-char-a1(dbm-statement-sub-z1)
                           move 1 to dbm-statement-found-z1
                       end-if
                       if  dbmddl-char(char-sub-1-z1)
                           = space
                       and dbmddl-char(char-sub-2-z1)
                           not = space
                           move 2 to ddl-char-action-z1
                           add 1 to dbm-statement-sub-z1
                           move dbmddl-char(char-sub-1-z1)
                           to   dbm-ddl-char-a1(dbm-statement-sub-z1)
                       end-if
                       if  dbmddl-char(char-sub-1-z1)
                           = space
                       and char-sub-1-z1 = 80
                           move 2 to ddl-char-action-z1
                           add 1 to dbm-statement-sub-z1
                           move dbmddl-char(char-sub-1-z1)
                           to   dbm-ddl-char-a1(dbm-statement-sub-z1)
                       end-if
                       if  dbmddl-char(char-sub-1-z1)
                           = "-"
                       and dbmddl-char(char-sub-2-z1)
                           = "-"
                           move 3 to ddl-char-action-z1
                           move 80 to char-sub-1-z1
                       end-if
                       if  dbmddl-char(char-sub-1-z1)
                           = delimiter-z2
                           move 4 to ddl-char-action-z1
                           move 1 to delimiter-found-z1
                           move dbm-statement-sub-z1
                           to   dbm-statement-len-a0
                       end-if
                   end-if
               end-perform
               move dbm-statement-a1 to dbm-statement-text-a0
               .
      *
       b-3-2-exec-ddl-statement.
      *=========================
      *
      * PREPARE and EXECUTE the DDL statement from the buffer
      * LOG the SQLCODEs
      *
               exec sql
                       prepare dbmddl1
                       from :dbm-statement-a0
               end-exec
               if  sqlcode not = 0
                   perform z-2-dbm-error
               end-if
               move "**** PREPARE SQL CODE:"
               to dbm-message-text-z1
               move sqlcode to dbmcode-z1
               move dbm-message-z1 to message-line
               perform z-1-write-message-rec
               exec sql
                       execute dbmddl1
               end-exec
               if  sqlcode not = 0
                   perform z-2-dbm-error
               end-if
               move "**** EXECUTE SQL CODE:"
               to dbm-message-text-z1
               move sqlcode to dbmcode-z1
               move dbm-message-z1 to message-line
               perform z-1-write-message-rec
               .
      *
       c-2-0-what-par.
      *===============
      *
      * Determine which parameter type is current
      * Control specific check for each type
      *
               move space to mess-line-2-a1
               string parameter-name-z3 delimited by space
                      "=" delimited by size
               into   param-name-a1
               end-string
               move parameter-value-z3 to param-value-a1
               move mess-line-2-a1 to message-line
               perform z-1-write-message-rec
               evaluate true
                        when parameter-name-z3 = 'MT'
                               perform c-2-2-mode
                        when parameter-name-z3 = 'DB'
                               perform c-2-3-db
                        when parameter-name-z3 = 'DL'
                               perform c-2-4-dl
                        when parameter-name-z3 = 'FN'
                               perform c-2-5-fn
                        when other
                               perform c-2-1-pars-error
               end-evaluate
               .
      *
       c-2-1-pars-error.
      *=================
      *
      * LOG parameter error and current parameter
      *
               move 1 to parameter-error-z3
               if  get-pars-type-z3 not = 'C'
               and parameter-name-z3 = 'MT'
                   move 'MT invalid from file or interactive'
                   to   message-line
                   perform z-1-write-message-rec
               else
                   move 'Unknown or invalid parameter specified'
                   to   message-line
                   perform z-1-write-message-rec
               end-if
               move 'See last parameter in above list.'
               to   message-line
               perform z-1-write-message-rec
               .
      *
       c-2-2-mode.
      *===========
      *
      * Specific check/move for MODE TYPE
      *
               if parameter-error-z3 negative
                  move parameter-value-z3 to mode-z2
                  move 1 to parameter-ok-n-z3(1)
                  if get-pars-type-z3 not = 'C'
                     perform c-2-1-pars-error
                  end-if
               end-if
               .
      *
       c-2-3-db.
      *=========
      *
      * Specific check/move for DATABASE
      *
               if parameter-error-z3 negative
                  move parameter-value-z3 to db-z2
                  move 1 to parameter-ok-n-z3(2)
               end-if
               .
      *
       c-2-4-dl.
      *=========
      *
      * Specific check/move for DELIMITER
      *
               if parameter-error-z3 negative
                  move parameter-value-z3 to delimiter-z2
                  move 1 to parameter-ok-n-z3(3)
               end-if
               .
      *
       c-2-5-fn.
      *=========
      *
      * Specific check/move for file name
      *
               if parameter-error-z3 negative
                  move parameter-value-z3 to dbmddl-ds-z1
                  move parameter-value-z3 to dbmddl-ds-z2
                  move 1 to parameter-ok-n-z3(4)
               end-if
               .
      *
       z-1-write-message-rec.
      *======================
      *
      * Write out a line to the LOG File
      *
               write message-rec
               move space to message-line
               .
      *
       z-2-dbm-error.
      *==============
      *
      * SQLCODE was bad, so write message and code to LOG
      *
               if  sqlcode not = allow-dbmcode-z1
                   move 1 to dbm-error-z1
                   move sqlcode to dbmcode-z1
                   move 'sqlcode returned with bad value'
                   to   dbm-message-text-z1
                   move dbm-message-z1 to message-line
                   perform z-1-write-message-rec
                   move "SQLCA sqlerrmc contents follow:"
                   to message-line
                   perform z-1-write-message-rec
                   move sqlerrmc
                   to   dbm-message-text-z1
                   move dbm-message-z1 to message-line
                   perform z-1-write-message-rec
                   perform z-9-stop
               .
      *
       z-3-read-dbmddl-ds.
      *===================
      *
      * Read the DDL file
      *
               read dbmddl-ds
                   at end
                       move 1 to end-dbmddl-ds-z1
               .
      *
       z-4-bad-file-status.
      *====================
      *
      * LOG bad file status code
      *
               move "Bad file status on open."
               to   message-line
               perform z-1-write-message-rec
               move "File name and status follow:"
               to   message-line
               perform z-1-write-message-rec
               move current-file-z1
               to   message-line
               perform z-1-write-message-rec
               move last-file-status-b-z1
               to   display-status-z1
               move display-file-status-z1
               to   message-line
               perform z-1-write-message-rec
               .
      *
       z-9-stop.
      *=========
      *
      * JOY or MISERY depending on what happened back there
      * LOG end of run <==== EYECATCHER <====
      *
               move "<=== End of RUN" to message-line
               perform z-1-write-message-rec
               perform z-9-100
               perform z-9-999
               .
      *
       z-9-100.
      *========
      *
               if  parameter-ds-open-z1 positive
                   close parameter-ds
               end-if
               if  message-ds-open-z1 positive
                   close message-ds
               end-if
               if  dbmddl-ds-open-z1 positive
                   close dbmddl-ds
               end-if
               .
      *
       z-9-999.
      *========
      *
      * Finally its all over!
      *
               stop run
               .
