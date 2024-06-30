      $set ans85 noosvs mf
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989, 1992             *
      *                                                          *
      *                     STOCKIOA.CBL                         *
      *                                                          *
      *                      MULTI-USER                          *
      *                      ==========                          *
      *                DEMONSTRATION PROGRAM                     *
      *                =====================                     *
      *                                                          *
      *  This program demonstrates the file and record locking   *
      *     facilities of this MULTI-USER COBOL. This            *
      *   subprogram, which is called by MUDEMO, locks single    *
      *  records automatically. This is the default locking in   *
      *          this COBOL multi-user environment.              *
      *                                                          *
      ************************************************************

       configuration section.
       special-names.
          console is crt.
       input-output section.
       file-control.
           select stock-file assign "MUSTOCK.DAT"
                organization indexed
                access dynamic
                record key stock-key
                status file-status
                lock mode automatic.
      /
       data division.

      ***********************************************************
      * File Definition                                         *
      ***********************************************************

       file section.
       fd  stock-file.
       01  stock-record.
           03  stock-key                        pic 9(06).
           03  stock-data.
               05  stock-description-1          pic x(53).
               05  stock-description-2          pic x(53).
               05  stock-description-3          pic x(53).
               05  stock-held                   pic 9(06).
               05  stock-cost                   pic 9(06)v99.
      /
       working-storage section.
       01     stock-00   .
           03    stock-00-0101 pic x(0080) value "----------------------
      -    "----------------------------------------------------------".
           03    stock-00-0201 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-0280 pic x(0001) value "|".
           03    stock-00-0301 pic x(0001) value "|".
           03 filler           pic x(0031).
           03    stock-00-0333 pic x(0011) value " Acme Inc. ".
           03 filler           pic x(0020).
           03    stock-00-0364 pic x(0017) value "Date   /  /     |".
           03    stock-00-0401 pic x(0001) value "|".
           03 filler           pic x(0031).
           03    stock-00-0433 pic x(0011) value "===========".
           03 filler           pic x(0020).
           03    stock-00-0464 pic x(0017) value "Time   :        |".
           03    stock-00-0501 pic x(0001) value "|".
           03 filler           pic x(0027).
           03    stock-00-0529 pic x(0020) value "Stock Control System".
           03 filler           pic x(0031).
           03    stock-00-0580 pic x(0001) value "|".
           03    stock-00-0601 pic x(0001) value "|".
           03 filler           pic x(0027).
           03    stock-00-0629 pic x(0020) value "====================".
           03 filler           pic x(0031).
           03    stock-00-0680 pic x(0001) value "|".
           03    stock-00-0701 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-0780 pic x(0001) value "|".
           03    stock-00-0801 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-0880 pic x(0001) value "|".
           03    stock-00-0901 pic x(0025) value "|  Stock Code    [
      -    "  ]".
           03 filler           pic x(0054).
           03    stock-00-0980 pic x(0001) value "|".
           03    stock-00-1001 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-1080 pic x(0001) value "|".
           03    stock-00-1101 pic x(0022) value "|  Stock Description [
      -    "".
           03 FILLER           PIC X(0053).
           03    STOCK-00-1176 PIC X(0005) VALUE "]   |".
           03    stock-00-1201 pic x(0001) value "|".
           03 filler           pic x(0020).
           03    stock-00-1222 pic x(0001) value "[".
           03 filler           pic x(0053).
           03    stock-00-1276 pic x(0005) value "]   |".
           03    stock-00-1301 pic x(0001) value "|".
           03 filler           pic x(0020).
           03    stock-00-1322 pic x(0001) value "[".
           03 filler           pic x(0053).
           03    stock-00-1376 pic x(0005) value "]   |".
           03    stock-00-1401 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-1480 pic x(0001) value "|".
           03    stock-00-1501 pic x(0025) value "|  Stock Held    [
      -    "  ]".
           03 filler           pic x(0054).
           03    stock-00-1580 pic x(0001) value "|".
           03    stock-00-1601 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-1680 pic x(0001) value "|".
           03    stock-00-1701 pic x(0028) value "|  Cost per Unit [
      -    "     ]".
           03 filler           pic x(0051).
           03    stock-00-1780 pic x(0001) value "|".
           03    stock-00-1801 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-1880 pic x(0001) value "|".
           03    stock-00-1901 pic x(0001) value "|".
           03 filler           pic x(0078).
           03    stock-00-1980 pic x(0001) value "|".
           03    stock-00-2101 pic x(0080) value "----------------------
      -    "----------------------------------------------------------".
           03    stock-00-2201 pic x(0040)
                 value "-----Open Mode----Lock Mode--Last Operat".
           03    stock-00-2241 pic x(0040)
                 value "ion-----------Outcome------File Status--".
           03 filler           pic x(1037).

       01     stock-01    redefines    stock-00   .
           03 filler           pic x(0658).
           03   stock-01-code           pic 9(0006).
           03 filler           pic x(0158).
           03   stock-01-description-1  pic x(0053).
           03 filler           pic x(0027).
           03   stock-01-description-2  pic x(0053).
           03 filler           pic x(0027).
           03   stock-01-description-3  pic x(0053).
           03 filler           pic x(0103).
           03   stock-01-held           pic 9(0006).
           03 filler           pic x(0154).
           03   stock-01-cost           pic $$$$$9.99.
           03 filler           pic x(0579).
           03   choice                  pic 9.

      ***********************************************************
      * File Status Variables                                   *
      ***********************************************************

       01  file-status.
           03  status-1                 pic x.
           03  status-2                 pic x.

       01  binary-status redefines file-status pic 9(04) comp.

      ***********************************************************
      * Date and Time Variables                                 *
      ***********************************************************

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

      ***********************************************************
      * Information Line                                        *
      ***********************************************************

       01  status-line.
           03  filler                   pic x(02).
           03  open-mode                pic x(14).
           03  filler                   pic x(02).
           03  lock-mode                pic x(09)
                   value "Automatic".
           03  filler                   pic x(03).
           03  last-operation           pic x(11).
           03  filler                   pic x(03).
           03  was-it-successful        pic x(20).
           03  filler                   pic x(08).
           03  error-code.
               05 stat-1                pic x.
               05 filler                pic x.
               05 stat-2                pic 9(03).

       01  hyphen-line                  pic x(80)
               value all "-".

       01  yesno                        pic x.

       01    inpopt.
           03   inpopt-00      pic x(0040)
                 value "1.Read on Key  2.Read next  3.Start not ".
           03   inpopt-01      pic x(0040)
                 value "<  4.Write  5.Rewrite  6.Delete  7.Exit".

      **********************************************************
      * Program for locking single records automatically       *
      **********************************************************

       procedure division.
       main.
           initialize choice
                      stock-01.
           display space.
           display stock-00.
           display inpopt at 2301.
           display "Input Choice [ ]" at 2433 upon crt-under.
           open i-o stock-file.
           move "---Open I-O---" to open-mode.
           move "-Open I-O--" to last-operation.
           perform status-check.
           if was-it-successful not = "----------Successful"
               move "----Closed----" to open-mode
               display hyphen-line at 2201 upon crt-under
               display status-line at 2201 upon crt-under
               go to endit.

      ***********************************************************
      * MAIN LOOP                                               *
      ***********************************************************

       ent-ry.
           accept temp-date from date.
           perform display-date.
           accept temp-time from time.
           perform display-time.
           display hyphen-line at 2201 upon crt-under
           display status-line at 2201 upon crt-under
           accept stock-01.
           evaluate choice
               when    1 perform read-on-key
               when    2 perform read-next
               when    3 perform start-not-less-than
               when    4 perform write-record
               when    5 perform rewrite-record
               when    6 perform delete-record
               when    7 go to wrap-up
           end-evaluate.
           go to ent-ry.

      ***********************************************************
      * Close down paragraphs                                   *
      ***********************************************************

       wrap-up.
           close stock-file.
           move "----Closed----" to open-mode.
           move "------Closed" to last-operation.
           perform status-check.
           display hyphen-line at 2201 upon crt-under.
           display status-line at 2201 upon crt-under.

       endit.
           display "Do you wish to restart (Y/N) [ ]"
               at 2424 upon crt-under.
           accept yesno at 2454.
           evaluate yesno
                       when "Y"      go to main
                       when "y"      go to main
                       when "N"      exit program
                       when "n"      exit program
                       when other    go to endit
           end-evaluate.

      ***********************************************************
      * File Handling Routines                                  *
      ***********************************************************

       read-on-key.
           move "Read on key" to last-operation.
           perform move-key-from-screen-to-rec.
           read stock-file.
           perform status-check.
           perform move-from-rec-to-screen.
           display stock-01.

       read-next.
           move "--Read Next" to last-operation.
           read stock-file next.
           perform status-check.
           perform move-from-rec-to-screen.
           display stock-01.

       start-not-less-than.
           move "Start not <" to last-operation.
           perform move-key-from-screen-to-rec.
           start stock-file key not less than stock-key.
           perform status-check.

       write-record.
           move "---Write---" to last-operation.
           perform move-from-screen-to-rec.
           write stock-record.
           perform status-check.

       rewrite-record.
           move "--Rewrite--" to last-operation.
           perform move-from-screen-to-rec.
           rewrite stock-record.
           perform status-check.

       delete-record.
           move "--Delete---" to last-operation.
           perform move-key-from-screen-to-rec.
           delete stock-file.
           perform status-check.

      ***********************************************************
      *    File Status Checking Routines.                       *
      ***********************************************************

       status-check.
           move status-1 to stat-1
           if status-1 = 9
               move binary-status to stat-2
           else
               move status-2 to stat-2
           end-if
           evaluate status-1
                  when   "0"
               move "----------Successful" to was-it-successful
                  when   "1"
               move "---------End of file" to was-it-successful
                  when   "2"
               move "---------Invalid Key" to was-it-successful
                  when   "9"
               perform look-up-error thru error-end
           end-evaluate.
      ***********************************************************
      *     Look up error number                                *
      ***********************************************************

       look-up-error.
           move low-values to status-1.
           move binary-status to stat-2.
           evaluate stat-2
                 when  002
               move "-------File not open" to was-it-successful
                 when  007
               move "Disk space exhausted" to was-it-successful
                 when  013
               move "------File not found" to was-it-successful
                 when  024
               move "----------Disk error" to was-it-successful
                 when  041
               move "---Corrupt ISAM file" to was-it-successful
                 when  065
               move "---------File locked" to was-it-successful
                 when  068
               move "-------Record locked" to was-it-successful
                 when  139
               move "Record inconsistency" to was-it-successful
                 when  146
               move "---No current record" to was-it-successful
                 when  180
               move "------File malformed" to was-it-successful
                 when  208
               move "-------Network error" to was-it-successful
                 when  213
               move "------Too many locks" to was-it-successful
           end-evaluate.
       error-end.
           exit.


      ***********************************************************
      *     Move data to and from the screen                    *
      ***********************************************************

       move-key-from-screen-to-rec.
          move stock-01-code to stock-key.

       move-from-screen-to-rec.
          move stock-01-code to stock-key.
          move stock-01-description-1 to stock-description-1.
          move stock-01-description-2 to stock-description-2.
          move stock-01-description-3 to stock-description-3.
          move stock-01-held to stock-held.
          move stock-01-cost to stock-cost.

       move-from-rec-to-screen.
          move stock-key to stock-01-code.
          move stock-description-1 to stock-01-description-1.
          move stock-description-2 to stock-01-description-2.
          move stock-description-3 to stock-01-description-3.
          move stock-held to stock-01-held.
          move stock-cost to stock-01-cost.

      ***********************************************************
      * Date and Time Routines                                  *
      ***********************************************************

       display-date.
          move temp-day to days.
          move temp-month to month.
          move temp-year to year.
          display date-to-day at 0369.

       display-time.
          move temp-hours to hours.
          move temp-mins to mins.
          display up-to-date-time at 0469.
