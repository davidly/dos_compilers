      $set mf warning(3)
      $set sql sqlinit sqldb(sample)
      ***************************************************************
      *                                                             *
      *     (c) Micro Focus Ltd. 1989                               *
      *                                                             *
      *        SQLGENWS                                             *
      *                                                             *
      *        This program generates COBOL Working Storage         *
      *        host variable structures from OS/2 EE Database       *
      *        Manager's catalog - using SYSIBM.SYSCOLUMNS          *
      *        as the source of information to build the            *
      *        COBOL data definitions. Additionally these options   *
      *        are available:                                       *
      *                                                             *
      *        Option 1: generate NULL indicator array for the      *
      *                  table.                                     *
      *                                                             *
      *        Option 2: generate SELECT statement                  *
      *                  for the table.                             *
      *                                                             *
      *        Option 3: generate FETCH statement                   *
      *                  for the table.                             *
      *                                                             *
      *        FILES                                                *
      *        =====                                                *
      *                                                             *
      *        1. parameter-ds                                      *
      *                                                             *
      *        This file is read-only, and can contain parameters   *
      *        to be used for batch or deteached run modes.         *
      *        Parameters must be one per record.                   *
      *                                                             *
      *        The file name is hard coded.                         *
      *                                                             *
      *        2. target-ds                                         *
      *                                                             *
      *        This file is write-only, and will contain the        *
      *        program output for any particular program run and    *
      *        parameter set.                                       *
      *                                                             *
      *        The file name is specified by parameter.             *
      *                                                             *
      *        3. message-ds                                        *
      *                                                             *
      *        This file is write-only, and recieves the program    *
      *        messages for successive executions. Since this       *
      *        file is appended, occassional clear-up is required.  *
      *                                                             *
      *        The file name is hard coded.                         *
      *                                                             *
      *                                                             *
      *        RUNNING                                              *
      *        =======                                              *
      *                                                             *
      *        The program may be controlled by file, interactive   *
      *        or command line parameters. A mixture of these       *
      *        methods is available by specifying the correct       *
      *        MODE TYPE (MT parameter) value.                      *
      *                                                             *
      *        The program output is timestamped to enable parameter*
      *        and output files to be matched.                      *
      *                                                             *
      *        All parameters are logged in the message-ds file.    *
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
       select target-ds
               assign to dynamic target-ds-z1
               organization is line sequential
               file status is file-status-z1
               .
       select message-ds
               assign to dynamic message-ds-z1
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

       fd target-ds.
      *=============

       01 target-rec.
        03 target-line                     pic x(80).

       fd message-ds.
      *==============

       01 message-rec.
        03 message-line                    pic x(80).

       working-storage section.
      *========================
      *
       exec sql include sqlca end-exec.

       exec sql begin declare section end-exec.

      * Area for retrieval of Database Manager system information
      * from the catalog table SYSCOLUMNS
       01 sysibm-syscolumns-a0.
        03 name-a0                         pic x(18).
        03 tbname-a0                       pic x(18).
        03 tbcreator-a0                    pic x(8).
        03 coltype-a0                      pic x(8).
        03 nulls-a0                        pic x.
        03 length-a0                       pic s9(4) comp-5.
        03 scale-a0                        pic s9(4) comp-5.
        03 colno-a0                        pic s9(4) comp-5.


      * Database host variables used for control and access
       01 dbm-util-a0.
        03 max-columns-a0                  pic s9(4) comp-5.
        03 authorisation-id-a0             pic x(8).
        03 table-name-a0                   pic x(18).

       exec sql end declare section end-exec.

      * Data items used to create COBOL working storage lines
       01 structure-make-a2.
        03 dataname-a2                     pic x(32).
        03 length-char-a2                  pic x(5).
        03 scale-char-a2                   pic x(2).
        03 length-a2                       pic 99999.
        03 scale-a2                        pic 99.
        03 do-null-ind-a2                  pic s9(4) comp-5.
        03 smallint-pic-a2                 pic x(29)
                                           value
           "PIC S9(4) COMP-5.            ".
        03 smallint-plus-pic-a2            pic x(29)
                                           value
           "PIC S9(4) COMP-5+            ".
        03 integer-pic-a2                  pic x(29)
                                           value
           "PIC S9(9) COMP-5.            ".
        03 decimal-pic-a2                  pic x(29)
                                           value
           "PIC S9(+                     ".
        03 char-pic-a2                     pic x(29)
                                           value
           "PIC X(+                      ".
        03 date-pic-a2                     pic x(29)
                                           value
           "PIC X(10).                   ".
        03 time-pic-a2                     pic x(29)
                                           value
           "PIC x(8).                    ".
        03 timestamp-pic-a2                pic x(29)
                                           value
           "PIC X(26).                   ".
        03 full-stop-a2                    pic x
                                           value ".".

      * Area with framework COBOL working storage lines
       01 skeleton-lines-a2.
        03 skeleton-line-a2-n.
         05 skeleton-line-a2-1.
          07 ws-margin-a2-1                pic x(7).
          07 ws-level-a2-1                 pic x(8).
          07 ws-dataname-a2-1              pic x(32).
          07 ws-space-a2-1                 pic x(4).
          07 ws-pic-a2-1                   pic x(29).
         05 skeleton-line-a2-2.
          07 ws-margin-a2-2                pic x(15).
          07 ws-dataname-a2-2              pic x(25).
          07 ws-def-a2-2                   pic x(40).
         05 skeleton-line-a2-3.
          07 param-indent-a2-3             pic x(4).
          07 param-name-a2-3               pic x(12).
          07 param-value-a2-3              pic x(64).
        03 skeleton-line-a2
           redefines
           skeleton-line-a2-n              pic x(80)
                                           occurs 3.

      * Area to store all columns for the specified table
      * to avoid multiple retrieval from the database
       01 columns-a3.
        03 fetch-sub-a3                    pic s9(4) comp-5.
        03 column-sub-a3                   pic s9(4) comp-5.
        03 column-a3                       occurs 255.
         05 name-a3                        pic x(18).
         05 tbname-a3                      pic x(18).
         05 tbcreator-a3                   pic x(8).
         05 coltype-a3                     pic x(8).
         05 nulls-a3                       pic x.
         05 length-a3                      pic s9(4) comp-5.
         05 scale-a3                       pic s9(4) comp-5.
         05 colno-a3                       pic s9(4) comp-5.

      * Same as a3 but with some elements hyphenised
       01 columns-a4.
        03 column-sub-a4                   pic s9(4) comp-5.
        03 column-a4                       occurs 255.
         05 name-a4                        pic x(18).
         05 tbname-a4                      pic x(18).
         05 tbcreator-a4                   pic x(8).
         05 coltype-a4                     pic x(8).
         05 nulls-a4                       pic x.
         05 length-a4                      pic s9(4) comp-5.
         05 scale-a4                       pic s9(4) comp-5.
         05 colno-a4                       pic s9(4) comp-5.

      * General flags, file names, status and control items
       01 utils-z1.
        03 date-z1                         pic x(6).
        03 time-z1                         pic x(8).
        03 parameter-ds-z1                 pic x(64)
                                           value
       'd:\test\sqlgenws\sqlgenws.par'.
        03 end-parameter-ds-z1             pic s9(4) comp-5
                                           value -1.
        03 target-ds-z1                    pic x(64).
        03 message-ds-z1                   pic x(64)
                                           value
           'd:\test\sqlgenws\sqlgenws.log   '.
        03 dbm-message-z1.
         05 dbm-message-text-z1            pic x(72).
         05 dbmcode-z1                     pic -9(6).
        03 dbm-codes-allowable-z1.
         05 allow-dbmcode-z1               pic s9(4) comp-5.
        03 files-opened-z1.
         05 target-ds-open-z1              pic s9(4) comp-5.
         05 message-ds-open-z1             pic s9(4) comp-5.
         05 parameter-ds-open-z1           pic s9(4) comp-5.
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
        03 table-name-hyph-z1              pic x(18).

      * ARea for storage of checked parameters in correct pictures
       01 parameters-z2.
      *                      mode-z2
      *                      database-id-z2
      *                      authorisation-id-z2
      *                      table-name-z2
      *                      target-ds-z2
      *                      before-text-z2
      *                      after-text-z2
      *                      null-indicators-z2
      *                      select-statement-z2
      *                      fetch-statement-z2
        03 mode-z2                         pic x.
        03 database-id-z2                  pic x(8).
        03 authorisation-id-z2             pic x(8).
        03 table-name-z2                   pic x(18).
        03 target-ds-z2                    pic x(64).
        03 before-text-z2                  pic x(4)
                                           value space.
        03 after-text-z2                   pic x(4)
                                           value space.
        03 null-indicators-z2              pic s9(4) comp-5
                                           value -1.
        03 select-statement-z2             pic s9(4) comp-5
                                           value -1.
        03 fetch-statement-z2              pic s9(4) comp-5
                                           value -1.

      * Parameter definition area
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
                                           value 'AI'.
         05 parameter-3-ok-z3              pic s9(4) comp-5.
         05 parameter-4-z3                 pic x(2)
                                           value 'TN'.
         05 parameter-4-ok-z3              pic s9(4) comp-5.
         05 parameter-5-z3                 pic x(2)
                                           value 'TF'.
         05 parameter-5-ok-z3              pic s9(4) comp-5.
         05 parameter-6-z3                 pic x(2)
                                           value 'BT'.
         05 parameter-6-ok-z3              pic s9(4) comp-5.
         05 parameter-7-z3                 pic x(2)
                                           value 'AT'.
         05 parameter-7-ok-z3              pic s9(4) comp-5.
         05 parameter-8-z3                 pic x(2)
                                           value 'NI'.
         05 parameter-8-ok-z3              pic s9(4) comp-5.
         05 parameter-9-z3                 pic x(2)
                                           value 'SG'.
         05 parameter-9-ok-z3              pic s9(4) comp-5.
         05 parameter-10-z3                pic x(2)
                                           value 'FG'.
         05 parameter-10-ok-z3             pic s9(4) comp-5.
        03 parameters-z3
           redefines
           parameter-table-z3              occurs 10.
         05 parameter-name-n-z3            pic x(2).
         05 parameter-ok-n-z3              pic s9(4) comp-5.
        03 parameter-subscript-z3          pic s9(4) comp-5.

      * Temporary area for parameters during checks
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
         05 param-val-5-z4                 pic x(64).
         05 param-val-6-z4                 pic x(64).
         05 param-val-7-z4                 pic x(64).
         05 param-val-8-z4                 pic x(64).
         05 param-val-9-z4                 pic x(64).
         05 param-val-10-z4                pic x(64).
        03 parameters-z4
           redefines
           parameter-table-z4              occurs 10.
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
      *
               perform a-2-initial
               if  parameter-error-z3 negative
                   if  parameter-ok-n-z3(2) positive
                   and parameter-ok-n-z3(3) positive
                   and parameter-ok-n-z3(4) positive
                   and parameter-ok-n-z3(5) positive
                       move zero to max-columns-a0
                       perform b-3-0-get-max-cols
                       if  max-columns-a0 < 1
                       and parameter-error-z3 negative
                           move
                           "No table name as specified in parameters"
                           to   message-line
                           perform z-1-write-message-rec
                           move 1 to parameter-error-z3
                       end-if
                       perform a-8-prepare-target
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
      * Check at least mode type (MT) parameter specified
      * and initialise LOG, prepare TARGET FILE (TF),
      * control parameter reception
      *
               move -1 to target-ds-open-z1
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
                             param-val-n-z4(5)
                             param-val-n-z4(6)
                             param-val-n-z4(7)
                             param-val-n-z4(8)
                             param-val-n-z4(9)
                             param-val-n-z4(10)
               end-unstring
               move -1 to mt-parameter-found-z1
               perform with test before
                       varying parameter-subscript-z4
                       from    1
                       by      1
                       until parameter-subscript-z4 > 10
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
               move "===> SQLGENWS" to ws-margin-a2-2
               move date-z1 to ws-dataname-a2-2
               move time-z1 to ws-def-a2-2
               move skeleton-line-a2-2 to message-line
               perform z-1-write-message-rec
               if  mt-parameter-found-z1 negative
                   move "No mode type parameter specified"
                   to message-line
                   perform z-1-write-message-rec
                   move 1 to parameter-error-z3
               end-if
               perform with test before
                       varying parameter-subscript-z3
                       from 1 by 1
                       until   parameter-subscript-z3 > 10
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
      * Acces the speified database with start_using_database,
      * control program activities based on parameters
      *
               move -1 to do-null-ind-a2
               move zero to db-length
               move database-id-z2 to database
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
               move table-name-z2 to table-name-hyph-z1
               inspect table-name-hyph-z1
                       replacing all "_" by "-"
               perform b-3-1-fetch-syscols
               perform b-3-2-declare-table
               perform b-3-3-cobol-declare
               if null-indicators-z2 positive
                  move 1 to do-null-ind-a2
                  perform b-3-4-null-indicators
                  move -1 to do-null-ind-a2
               end-if
               if select-statement-z2 positive
                  perform b-3-5-select-statement
               end-if
               if fetch-statement-z2 positive
                  perform b-3-6-fetch-statement
               end-if
               .
      *
       a-4-help.
      *=========
      *
      * NOTE. READ THIS SECTION FOR HELP ON PARAMETERS
      *
      * Put help into LOG if command line was blank or help specified
      *
               if  param-cmd-line-z4 = space
               or  param-cmd-line-z4 = "H"
               or  param-cmd-line-z4 = "h"
               or  param-cmd-line-z4 = "HELP"
               or  param-cmd-line-z4 = "Help"
               or  param-cmd-line-z4 = "help"
                   move 1 to parameter-error-z3
                   move "Parameter names and meaning/values."
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "Parameters can be in any sequence."
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "MT=0<value<16 where value is MODE TYPE"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "DB=database name"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "AI=authorisation ID of table"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "TN=table name of DATABASE/AUTHID"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "TF=destination generation output"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "BT=text prior to datanames"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "AT=text after datanames"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "NI=Y - generate NULL inds"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "SG=Y  - generate SELECT"
                   to   message-line
                   perform z-1-write-message-rec
                   perform z-1-write-message-rec
                   move "FG=Y   - generate FETCH"
                   to   message-line
                   perform z-1-write-message-rec
               end-if
               .
      *
       a-5-file-parameters.
      *====================
      *
      * Control reception of file parameters
      *
               move "File parameters:"
               to   message-line
               perform z-1-write-message-rec
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
      * Control reception of command line parameters
      *
               move "Command line parameters:"
               to   message-line
               perform z-1-write-message-rec
               if  parameter-error-z3 negative
                   perform b-2-0-get-pars-c
               end-if
               .
      *
       a-7-interactive-parameters.
      *===========================
      *
      * Control reception of parameters from screen
      *
               move "Interactive parameters:"
               to   message-line
               perform z-1-write-message-rec
               if  parameter-error-z3 negative
                   perform b-2-2-get-pars-i
               end-if
               .
      *
       a-8-prepare-target.
      *===================
      *
      * Put header information into target file including timestamp
      *
               if parameter-error-z3 negative
                   move 'Target' to current-file-z1
                   open output target-ds
                   if  file-status-z1 = '00'
                       move 1 to target-ds-open-z1
                   else
                       move file-status-z1 to last-file-status-z1
                       perform z-4-bad-file-status
                       perform z-9-stop
                   end-if
                   move 'Target data set opened OK' to message-line
                   perform z-1-write-message-rec
                   move "      * TIME"
                   to ws-margin-a2-2
                   move "Date" to ws-dataname-a2-2
                   move "Time" to ws-def-a2-2
                   move skeleton-line-a2-2 to target-line
                   perform z-3-write-target-rec
                   move "      * STAMP"
                   to ws-margin-a2-2
                   move date-z1 to ws-dataname-a2-2
                   move time-z1 to ws-def-a2-2
                   move skeleton-line-a2-2 to target-line
                   perform z-3-write-target-rec
               end-if
               .
      *
       a-9-parameter-sequence.
      *=======================
      *
      * CHOICE OF MANY PARAMETER SOURCES
      * You may want to comment out any you dont want active
      * Parameter values for the same parameter type are overwritten
      * by values from subsequent parameter sources
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
      * Get and control check of command line parameters
      *
               perform with test before
                       varying parameter-subscript-z4
                       from    1
                       by      1
                       until parameter-subscript-z4 > 10
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
                           perform c-2-0-what-par
                       end-if
               end-perform
               .
      *
       b-2-1-get-pars-f.
      *=================
      *
      * Get and control check of file parameters
      *
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
                  perform c-2-0-what-par
               end-if
               end-perform
               .
      *
       b-2-2-get-pars-i.
      *=================
      *
      * Get and control check of interactive parameters
      *
               perform varying parameter-subscript-z3
                       from    2
                       by      1
                       until parameter-subscript-z3 > 10
                       move parameter-name-n-z3(parameter-subscript-z3)
                       to   parameter-name-z3
                       if  parameter-ok-n-z3(parameter-subscript-z3)
                           negative
                           display 'Please enter value for '
                                   parameter-name-z3
                           accept parameter-value-z3
                           perform c-2-0-what-par
                       end-if
               end-perform
               .
      *
       b-3-0-get-max-cols.
      *===================
      *
      * Get maximum number of columns in the specified table to
      * enable program control functions later in the run
      *
               move authorisation-id-z2 to authorisation-id-a0
               move table-name-z2 to table-name-a0
               exec sql
                       select max(colno)
                       into   :max-columns-a0
                       from   SYSIBM.SYSCOLUMNS
                       where  tbcreator = :authorisation-id-a0
                       and    tbname    = :table-name-a0
               end-exec
               if sqlcode not = zero
               and sqlcode not = -305
                  perform z-2-dbm-error
               end-if
               .
      *
       b-3-1-fetch-syscols.
      *====================
      *
      * Read the SYSCOLUMNS information for each column for the specied
      * table
      *
               add 1 to max-columns-a0
               exec sql
                    declare syscols cursor for
                           select
                           name,
                           tbname,
                           tbcreator,
                           coltype,
                           nulls,
                           length,
                           scale,
                           colno
                   from SYSIBM.SYSCOLUMNS
                   where tbcreator = :authorisation-id-a0
                   and   tbname    = :table-name-a0
                   order by colno
               end-exec
               if sqlcode not = zero
                  perform z-2-dbm-error
               end-if
               exec sql
                   open syscols
               end-exec
               if sqlcode not = zero
                  perform z-2-dbm-error
               end-if
               perform with test before
                       varying fetch-sub-a3 from 1 by 1
                       until   fetch-sub-a3 > max-columns-a0
                       or      sqlcode not = zero
               exec sql
                   fetch syscols into
                           :name-a0,
                           :tbname-a0,
                           :tbcreator-a0,
                           :coltype-a0,
                           :nulls-a0,
                           :length-a0,
                           :scale-a0,
                           :colno-a0
               end-exec
               if sqlcode not = zero
                  perform z-2-dbm-error
               end-if
               move sysibm-syscolumns-a0
               to   column-a4(fetch-sub-a3)
               inspect name-a0
                       replacing all "_" by "-"
               inspect tbname-a0
                       replacing all "_" by "-"
               move sysibm-syscolumns-a0
               to   column-a3(fetch-sub-a3)
               end-perform
               exec sql
                   close syscols
               end-exec
               if sqlcode not = zero
                  perform z-2-dbm-error
               end-if
               .
      *
       b-3-2-declare-table.
      *====================
      *
      * Generate SQL table definition for COBOL
      *
               move "      * SQLGENWS produced this"
               to target-line
               perform z-3-write-target-rec
               move "      * SQL TABLE DECLARATION"
               to target-line
               perform z-3-write-target-rec
               string "       EXEC SQL DECLARE "
                      delimited by size
                      tbname-a4(1) delimited by space
                      " TABLE (" delimited by size
               into target-line
               end-string
               perform z-3-write-target-rec
               perform with test before
                       varying column-sub-a4
                       from 1 by 1
                       until column-sub-a4 > max-columns-a0
                       move space to skeleton-line-a2-2
                       move name-a4(column-sub-a4) to ws-dataname-a2-2
                       if coltype-a4(column-sub-a4) = 'LONGVAR'
                          move "LONG VARCHAR +"
                          to   ws-def-a2-2
                       end-if
                       if coltype-a4(column-sub-a4) = 'TIMESTMP'
                          move "TIMESTAMP +"
                          to   ws-def-a2-2
                       end-if
                       if  coltype-a4(column-sub-a4) not = 'LONGVAR'
                       and coltype-a4(column-sub-a4) not = 'TIMESTMP'
                           string coltype-a4(column-sub-a4)
                                  delimited by space
                                  " +" delimited by size
                           into   ws-def-a2-2
                           end-string
                       end-if
                       move length-a4(column-sub-a4) to length-a2
                       move length-a2 to length-char-a2
                       if  coltype-a4(column-sub-a4) = 'CHAR'
                       or  coltype-a4(column-sub-a4) = 'VARCHAR'
                           string ws-def-a2-2 delimited by "+"
                                  "(" delimited by size
                                  length-char-a2
                                  delimited by size
                                  ") +" delimited by size
                           into   ws-def-a2-2
                           end-string
                       end-if
                       move scale-a4(column-sub-a4) to scale-a2
                       move scale-a2 to scale-char-a2
                       if  coltype-a4(column-sub-a4) = 'DECIMAL'
                           string ws-def-a2-2 delimited by "+"
                                  "(" delimited by size
                                  length-char-a2
                                  delimited by size
                                  "," delimited by size
                                  scale-char-a2
                                  delimited by size
                                  ") +" delimited by size
                           into   ws-def-a2-2
                           end-string
                       end-if
                       if  nulls-a4(column-sub-a4) = 'N'
                           string ws-def-a2-2 delimited by "+"
                                  "NOT NULL +" delimited by size
                           into   ws-def-a2-2
                           end-string
                       end-if
                       if  column-sub-a4 < max-columns-a0
                           string ws-def-a2-2 delimited by "+"
                                  "," delimited by size
                           into   ws-def-a2-2
                           end-string
                       else
                           string ws-def-a2-2 delimited by "+"
                                  " " delimited by size
                           into   ws-def-a2-2
                           end-string
                       end-if
                       move skeleton-line-a2-2 to target-line
                       perform z-3-write-target-rec
               end-perform
               move "        )"
               to target-line
               perform z-3-write-target-rec
               move "        END-EXEC"
               to target-line
               perform z-3-write-target-rec
               .
      *
       b-3-3-cobol-declare.
      *====================
      *
      * Generate database host variables for COBOL working storage
      *
               move '      * SQLGENWS produced this COBOL'
               to target-line
               perform z-3-write-target-rec
               move '      * SQL host variable structure'
               to target-line
               perform z-3-write-target-rec
               perform with test before
                       varying column-sub-a3
                       from 1 by 1
                       until column-sub-a3 > max-columns-a0
                   move space to skeleton-line-a2-1
                   move space to dataname-a2
                   if column-sub-a3 = 1
                      perform c-3-1-01-level
                   end-if
                   string before-text-z2 delimited by space
                          name-a3(column-sub-a3)
                                         delimited by space
                          after-text-z2  delimited by space
                   into   dataname-a2
                   end-string
                   move dataname-a2 to ws-dataname-a2-1
                   evaluate true
                       when coltype-a3(column-sub-a3) = "SMALLINT"
                        perform c-3-2-smallint
                       when coltype-a3(column-sub-a3) = "INTEGER"
                        perform c-3-3-integer
                       when coltype-a3(column-sub-a3) = "DECIMAL"
                        perform c-3-4-decimal
                       when coltype-a3(column-sub-a3) = "CHAR"
                        perform c-3-5-char
                       when coltype-a3(column-sub-a3) = "VARCHAR"
                        perform c-3-6-varchar
                       when coltype-a3(column-sub-a3) = "LONGVAR"
                        perform c-3-7-longvar
                       when coltype-a3(column-sub-a3) = "DATE"
                        perform c-3-8-date
                       when coltype-a3(column-sub-a3) = "TIME"
                        perform c-3-9-time
                       when coltype-a3(column-sub-a3) = "TIMESTMP"
                        perform c-3-10-timestmp
                       when coltype-a3(column-sub-a3) = "FLOAT"
                        perform c-3-11-float
                       when other
                        perform c-3-12-other
                   end-evaluate
                   move skeleton-line-a2-1 to target-line
                   perform z-3-write-target-rec
               end-perform
               .
      *
       b-3-4-null-indicators.
      *======================
      *
      * Generate database NULL indicator variables for the specified
      * table
      *
               move space to skeleton-line-a2-1
               perform with test before
                       varying column-sub-a3
                       from 1 by 1
                       until column-sub-a3 > max-columns-a0
                   if column-sub-a3 = 1
                       perform c-3-13-null-01-03
                   end-if
                   move space to dataname-a2
                   string before-text-z2 delimited by space
                          name-a3(column-sub-a3)
                                         delimited by space
                          after-text-z2  delimited by space
                   into   dataname-a2
                   end-string
                   move dataname-a2 to ws-dataname-a2-1
                   perform c-3-2-smallint
                   move skeleton-line-a2-1 to target-line
                   perform z-3-write-target-rec
                   move space to skeleton-line-a2-1
               end-perform
               perform c-3-14-null-03red
               .
      *
       b-3-5-select-statement.
      *=======================
      *
      * Generate a SQL SELECT statement for the specified table
      *
               move "      *" to target-line
               perform z-3-write-target-rec
               move "      * SELECT STATEMENT" to target-line
               perform z-3-write-target-rec
               move "               SELECT" to target-line
               perform z-3-write-target-rec
               perform with test before
                       varying column-sub-a4
                       from    1 by 1
                       until   column-sub-a4 > max-columns-a0 - 1
                       string "               " delimited by size
                              name-a4(column-sub-a4) delimited by space
                              "," delimited by size
                       into   target-line
                       end-string
                       perform z-3-write-target-rec
               end-perform
               string "               " delimited by size
                      name-a4(column-sub-a4) delimited by space
               into   target-line
               end-string
               perform z-3-write-target-rec
               string "               FROM " delimited by size
                      tbname-a4(1) delimited by space
               into   target-line
               perform z-3-write-target-rec
               .
      *
       b-3-6-fetch-statement.
      *======================
      *
      * Generate a SQL FETCH statement for the spefied table
      *
               move "      *" to target-line
               perform z-3-write-target-rec
               move "      * FETCH STATEMENT" to target-line
               perform z-3-write-target-rec
               move "               FETCH CURSOR-NAME INTO"
               to   target-line
               perform z-3-write-target-rec
               perform with test before
                       varying column-sub-a3
                       from    1 by 1
                       until   column-sub-a3 > max-columns-a0 - 1
                       string "               :" delimited by size
                              before-text-z2 delimited by space
                              name-a3(column-sub-a3) delimited by space
                              after-text-z2 delimited by space
                              "," delimited by size
                       into   target-line
                       end-string
                       perform z-3-write-target-rec
               end-perform
               string "               :" delimited by size
                      before-text-z2 delimited by space
                      name-a3(column-sub-a3) delimited by space
                      after-text-z2 delimited by space
               into   target-line
               end-string
               perform z-3-write-target-rec
               .
      *
       c-2-0-what-par.
      *===============
      *
      * Determine the current parameter type
      *
               move space to skeleton-line-a2-3
               string parameter-name-z3 delimited by space
                      "=" delimited by size
               into   param-name-a2-3
               end-string
               move parameter-value-z3 to param-value-a2-3
               move skeleton-line-a2-3 to message-line
               perform z-1-write-message-rec
               evaluate true
                        when parameter-name-z3 = 'MT'
                               perform c-2-2-mode
                        when parameter-name-z3 = 'DB'
                               perform c-2-3-database
                        when parameter-name-z3 = 'AI'
                               perform c-2-4-authid
                        when parameter-name-z3 = 'TN'
                               perform c-2-5-tablename
                        when parameter-name-z3 = 'TF'
                               perform c-2-6-targetfile
                        when parameter-name-z3 = 'BT'
                               perform c-2-7-beforetext
                        when parameter-name-z3 = 'AT'
                               perform c-2-8-aftertext
                        when parameter-name-z3 = 'NI'
                               perform c-2-9-nullindgen
                        when parameter-name-z3 = 'SG'
                               perform c-2-10-selectgen
                        when parameter-name-z3 = 'FG'
                               perform c-2-11-fetchgen
                        when other
                               perform c-2-1-pars-error
               end-evaluate
               .
      *
       c-2-1-pars-error.
      *=================
      *
      * LOG a parameter error
      *
               move 1 to parameter-error-z3
               move 'Unknown or invalid parameter specified'
               to   message-line
               perform z-1-write-message-rec
               move 'Parameter as specified follows:'
               to   message-line
               perform z-1-write-message-rec
               move parameter-name-z3 to message-line
               perform z-1-write-message-rec
               .
      *
       c-2-2-mode.
      *===========
      *
      * Specific check/move for MODE TYPE parameter
      *
               if parameter-error-z3 negative
                  move parameter-value-z3 to mode-z2
                  move 1 to parameter-ok-n-z3(1)
               end-if
               .
      *
       c-2-3-database.
      *===============
      *
      * Specific check/move for DATABASE parameter
      *
               if  parameter-value-z3 not = space
                   move parameter-value-z3 to database-id-z2
                   move 1 to parameter-ok-n-z3(2)
               else
                   perform c-2-1-pars-error
               end-if
               .
      *
       c-2-4-authid.
      *=============
      *
      * Specific check/move for AUTHORISATION ID parameter
      *
               if  parameter-value-z3 not = space
                   move parameter-value-z3 to authorisation-id-z2
                   move 1 to parameter-ok-n-z3(3)
               else
                   perform c-2-1-pars-error
               .
      *
       c-2-5-tablename.
      *================
      *
      * Specific check/move for TABLENAME parameter
      *
               if  parameter-value-z3 not = space
                   move parameter-value-z3 to table-name-z2
                   move 1 to parameter-ok-n-z3(4)
               else
                   perform c-2-1-pars-error
               .
      *
       c-2-6-targetfile.
      *=================
      *
      * Specific check/move for TARGETFILE parameter
      *
               if  parameter-value-z3 not = space
                   move parameter-value-z3 to target-ds-z1
                   move parameter-value-z3 to target-ds-z2
                   move 1 to parameter-ok-n-z3(5)
               else
                   perform c-2-1-pars-error
               .
      *
       c-2-7-beforetext.
      *=================
      *
      * Spefific check/move for BEFORETEXT parameter
      *
               if  parameter-value-z3 not = space
                   move parameter-value-z3 to before-text-z2
               else
                   move space to before-text-z2
               end-if
               move 1 to parameter-ok-n-z3(6)
               .
      *
       c-2-8-aftertext.
      *================
      *
      * Specific check/move for AFTERTEXT parameter
      *
               if  parameter-value-z3 not = space
                   move parameter-value-z3 to after-text-z2
               else
                   move space to after-text-z2
               end-if
               move 1 to parameter-ok-n-z3(7)
               .
      *
       c-2-9-nullindgen.
      *=================
      *
      * Specific check/move for NULLINDGEN parameter
      *
               if parameter-value-z3  = 'Y'
                  move 1 to null-indicators-z2
               end-if
               move 1 to parameter-ok-n-z3(8)
               .
      *
       c-2-10-selectgen.
      *=================
      *
      * Specific check/move for SELECTGEN parameter
      *
               if parameter-value-z3 = 'Y'
                  move 1 to select-statement-z2
               end-if
               move 1 to parameter-ok-n-z3(9)
               .
      *
       c-2-11-fetchgen.
      *================
      *
      * Specific check/move for FETCHGEN parameter
      *
               if parameter-value-z3 = 'Y'
                  move 1 to fetch-statement-z2
               end-if
               move 1 to parameter-ok-n-z3(10)
               .
      *
       c-3-1-01-level.
      *===============
      *
      * Generate COBOL 01 level line
      *
               move '01  ' to ws-level-a2-1
               string before-text-z2 delimited by space
                   table-name-hyph-z1 delimited by space
                   after-text-z2  delimited by space
               into   dataname-a2
               end-string
               string dataname-a2 delimited by space
                      "." delimited by size
               into   dataname-a2
               end-string
               move dataname-a2 to ws-dataname-a2-1
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move space to dataname-a2
               .
      *
       c-3-2-smallint.
      *===============
      *
      * Generate COBOL line for database SMALLINT
      *
               move "  10" to ws-level-a2-1
               if do-null-ind-a2 positive
                   string ws-dataname-a2-1 delimited by after-text-z2
                          "-NULL" delimited by size
                          after-text-z2 delimited by space
                   into   ws-dataname-a2-1
                   end-string
               end-if
               move smallint-pic-a2 to ws-pic-a2-1
               .
      *
       c-3-3-integer.
      *==============
      *
      * Generate COBOL line for database INTEGER
      *
               move "  10" to ws-level-a2-1
               move integer-pic-a2 to ws-pic-a2-1
               .
      *
       c-3-4-decimal.
      *==============
      *
      * Generate COBOL line for database DECIMAL
      *
               move "  10" to ws-level-a2-1
               move length-a3(column-sub-a3) to length-a2
               move length-a2 to length-char-a2
               move scale-a3(column-sub-a3) to scale-a2
               move scale-a2 to scale-char-a2
               string decimal-pic-a2 delimited by "+"
                      length-char-a2 delimited by space
                      "+" delimited by size
               into   ws-pic-a2-1
               end-string
               if scale-a2 = zero
                   string ws-pic-a2-1 delimited by "+"
                          ")." delimited by size
                   into   ws-pic-a2-1
                   end-string
               else
                   string ws-pic-a2-1 delimited by "+"
                          ")V9(" delimited by size
                          scale-char-a2 delimited by space
                          ")." delimited by size
                   into   ws-pic-a2-1
                   end-string
               .
      *
       c-3-5-char.
      *===========
      *
      * Generate COBOL line for database CHAR
      *
               move "  10" to ws-level-a2-1
               move char-pic-a2 to ws-pic-a2-1
               move length-a3(column-sub-a3) to length-a2
               move length-a2 to length-char-a2
               string ws-pic-a2-1 delimited by "+"
                      length-char-a2 delimited by space
                      ")." delimited by size
               into   ws-pic-a2-1
               end-string
               .
      *
       c-3-6-varchar.
      *==============
      *
      * Generate COBOL line for database VARCHAR
      *
               move "  10" to ws-level-a2-1
               string ws-dataname-a2-1 delimited by space
                      "." delimited by size
               into ws-dataname-a2-1
               end-string
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move "    49" to ws-level-a2-1
               move space to ws-dataname-a2-1
               string dataname-a2 delimited by after-text-z2
                      "-LEN" delimited by size
                      after-text-z2 delimited by space
               into   ws-dataname-a2-1
               end-string
               move smallint-pic-a2 to ws-pic-a2-1
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move "    49" to ws-level-a2-1
               move space to ws-dataname-a2-1
               string dataname-a2 delimited by after-text-z2
                      "-TEXT" delimited by size
                      after-text-z2 delimited by space
               into   ws-dataname-a2-1
               end-string
               move char-pic-a2 to ws-pic-a2-1
               move length-a3(column-sub-a3) to length-a2
               move length-a2 to length-char-a2
               string ws-pic-a2-1 delimited by "+"
                      length-char-a2 delimited by space
                      ")." delimited by size
               into   ws-pic-a2-1
               end-string
               .
      *
       c-3-7-longvar.
      *==============
      *
      * Generate COBOL line for database LONG VARCHAR
      * (Same as VARCHAR)
      *
               perform c-3-6-varchar
               .
      *
       c-3-8-date.
      *===========
      *
      * Generate COBOL line for database DATE
      *
               move "  10" to ws-level-a2-1
               move date-pic-a2 to ws-pic-a2-1
               .
      *
       c-3-9-time.
      *===========
      *
      * Generate COBOL line for database TIME
      *
               move "  10" to ws-level-a2-1
               move time-pic-a2 to ws-pic-a2-1
               .
      *
       c-3-10-timestmp.
      *================
      *
      * Generate COBOL line for database TIMESTAMP
      *
               move "  10" to ws-level-a2-1
               move timestamp-pic-a2 to ws-pic-a2-1
               .
      *
       c-3-11-float.
      *=============
      *
      * Generate warning for database FLOAT datatype
      * Not supported in COBOL/2 version
      *
               move "*******" to target-line
               perform z-3-write-target-rec
               move "******* WARNING:" to target-line
               perform z-3-write-target-rec
               move "******* FLOAT DATA TYPE NOT SUPPORTED *******"
               to   target-line
               perform z-3-write-target-rec
               .
      *
       c-3-12-other.
      *=============
      *
      * LOG error and stop run if any other types
      *
               move "INVALID DATA TYPE IN TABLE"
               to   message-line
               perform z-1-write-message-rec
               move "SQLGENWS RUN ABANDONED"
               to   message-line
               perform z-1-write-message-rec
               perform z-9-stop
               .
      *
       c-3-13-null-01-03.
      *==================
      *
      * Generate NULL indicator 01 and 03 level
      *
               move "      *" to target-line
               perform z-3-write-target-rec
               move "      * NULL INDICATOR VARIABLES"
               to   target-line
               perform z-3-write-target-rec
               move '01  ' to ws-level-a2-1
               string before-text-z2 delimited by space
                      table-name-hyph-z1 delimited by space
                      "-NULL-INDS" delimited by size
                      after-text-z2  delimited by space
                      "." delimited by size
               into   dataname-a2
               end-string
               move dataname-a2 to ws-dataname-a2-1
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move space to dataname-a2
               move ' 03 ' to ws-level-a2-1
               string before-text-z2 delimited by space
                      table-name-hyph-z1 delimited by space
                      "-NULLS" delimited by size
                      after-text-z2  delimited by space
                      "." delimited by size
               into   dataname-a2
               end-string
               move dataname-a2 to ws-dataname-a2-1
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move space to dataname-a2
               .
      *
       c-3-14-null-03red.
      *==================
      *
      * Generate NULL indicator redefinition line
      *
               move ' 03 ' to ws-level-a2-1
               string before-text-z2 delimited by space
                      table-name-hyph-z1 delimited by space
                      "-NULL" delimited by size
                      after-text-z2  delimited by space
               into   dataname-a2
               end-string
               move dataname-a2 to ws-dataname-a2-1
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move space to dataname-a2
               move "REDEFINES" to ws-dataname-a2-1
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move space to dataname-a2
               string before-text-z2 delimited by space
                      table-name-hyph-z1 delimited by space
                      "-NULLS" delimited by size
                      after-text-z2  delimited by space
               into   dataname-a2
               end-string
               move dataname-a2 to ws-dataname-a2-1
               move smallint-plus-pic-a2
               to   ws-pic-a2-1
               string ws-pic-a2-1 delimited by "+"
                      " " delimited by size
               into   ws-pic-a2-1
               end-string
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move space to dataname-a2
               move max-columns-a0 to length-a2
               move length-a2 to length-char-a2
               move "OCCURS +" to ws-pic-a2-1
               string ws-pic-a2-1 delimited by "+"
                      length-char-a2 delimited by size
                      "." delimited by size
               into ws-pic-a2-1
               end-string
               move skeleton-line-a2-1 to target-line
               perform z-3-write-target-rec
               move space to skeleton-line-a2-1
               move space to dataname-a2
               .
      *
       z-1-write-message-rec.
      *======================
      *
      * Write a line to the LOG file
      *
               write message-rec
               move space to message-line
               .
      *
       z-2-dbm-error.
      *==============
      *
      * LOG a database error - if SQLCODE bad
      *
               if  sqlcode not = allow-dbmcode-z1
                   move sqlcode to dbmcode-z1
                   move 'sqlcode returned with bad value'
                   to   dbm-message-text-z1
                   move dbm-message-z1 to message-line
                   perform z-1-write-message-rec
                   perform z-9-stop
               .
      *
       z-3-write-target-rec.
      *=====================
      *
      * Write a line to the TARGETFILE
      *
               write target-rec
               move space to target-line
               .
      *
       z-4-bad-file-status.
      *====================
      *
      * Write LOG of file error
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
      * Breathe a sigh of relief and retire.
      * LOG the end of run <==== EYECATCHER <====
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
               if  target-ds-open-z1 positive
                   close target-ds
               end-if
               if  message-ds-open-z1 positive
                   close message-ds
               end-if
               .
      *
       z-9-999.
      *========
      *
      * Thats all folks.
      *
               stop run
               .
