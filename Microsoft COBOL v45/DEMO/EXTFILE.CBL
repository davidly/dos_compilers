      $set ans85 mf noosvs
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1989                   *
      *                                                          *
      *                     EXTFILE.CBL                          *
      *                                                          *
      *    This program demonstrates how to use EXTERNAL files.  *
      *    It calls WRITEFIL to write some records to a data     *
      *    file and READFILE to read the same records back       *
      *    (without opening or closing the file between calls).  *
      *    READFILE displays the output.                         *
      *                                                          *
      ************************************************************
       identification division.
       program-id. extfile.
       environment division.
       input-output section.
       file-control.
           select finfile assign to "isamfil.dat"
               organization is indexed
               record key is fd-tran-date
               access mode is dynamic.

       file section.
       fd finfile
          is external
          record contains 50 characters.
       01 fd-finfile-record.
           05 fd-tran-date     pic x(4).
           05 fd-with-or-dep   pic x(2).
           05 fd-amount        pic 9(5)v99.


       procedure division.
       main-line.
           perform open-file
           perform write-to-the-file
           perform start-file
           perform read-the-file
           perform close-file
           stop run.

       open-file.
           open i-o finfile.

       start-file.
           move 1111 to fd-tran-date
           start finfile key = fd-tran-date.

       write-to-the-file.
           call "writefil".

       read-the-file.
           call "readfile".

       close-file.
           close finfile.
       end program extfile.
      ************************************************************
       identification division.
       program-id. readfile.
       environment division.
       input-output section.
       file-control.
           select finfile assign to "isamfil.dat"
               organization is indexed
               record key is fd-tran-date
               access mode is dynamic.

       file section.
       fd finfile
          is external
          record contains 50 characters.
       01 fd-finfile-record.
           05 fd-tran-date     pic x(4).
           05 fd-with-or-dep   pic x(2).
           05 fd-amount        pic 9(5)v99.

       working-storage section.
       01 ws-end-of-file       pic 9       value 0.
       01 ws-subtotal          pic s9(5)v99 value 0.
       01 ws-total             pic -(4)9.99.

       procedure division.
       main-line.
           perform read-the-file.
           perform until ws-end-of-file = 1
               perform calculate-totals
               perform read-the-file
           end-perform.
           perform display-output.
           exit program.
           stop run.

       read-the-file.
           read finfile next record at end move 1 to ws-end-of-file.

       calculate-totals.
           evaluate fd-with-or-dep
             when "WI"
                 subtract fd-amount from ws-subtotal
             when "DE"
                 add fd-amount to ws-subtotal
           end-evaluate.

       display-output.
           move ws-subtotal to ws-total
           display "account balance = ", ws-total.

       end program readfile.
      ************************************************************
       identification division.
       program-id. writefil.
       environment division.
       input-output section.
       file-control.
           select finfile assign to "isamfil.dat"
               organization is indexed
               record key is fd-tran-date
               access mode is dynamic.

       file section.
       fd finfile
          is external
          record contains 50 characters.
       01 fd-finfile-record.
           05 fd-tran-date     pic x(4).
           05 fd-with-or-dep   pic x(2).
           05 fd-amount        pic 9(5)v99.

       procedure division.
       main-line.
           perform write-records
           exit program
           stop run.

       write-records.

      * write a WIthdrawal record
           move 1111 to fd-tran-date.
           move 'WI' to fd-with-or-dep.
           move 23.55 to fd-amount.
           write fd-finfile-record.

      * write a DEposit record
           move 2222 to fd-tran-date.
           move 'DE' to fd-with-or-dep.
           move 123.55 to fd-amount.
           write fd-finfile-record.

       end program writefil.
