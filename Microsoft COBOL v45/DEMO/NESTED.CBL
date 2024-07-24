      $set ans85 nestcall noosvs mf
      *******************************************************************
      *                                                                 *
      *                                                                 *
      *                  (C) Micro Focus Ltd. 1989                      *
      *                                                                 *
      *                         NESTED.CBL                              *
      *                                                                 *
      *  This demo shows how to structure a nested COBOL program.       *
      *  There are two nested programs NEST1 and NEST2 each of which    *
      *  have their own local data. It also demonstrates a simple use   *
      *  of GLOBAL data.                                                *
      *                                                                 *
      *******************************************************************
       identification division.
       program-id.   main.
       working-storage section.
       01 counter is global            pic 9999.
       01 local-item                   pic x(20) value all 'a'.

       procedure division.
           move 1 to counter.
           display 'in main program, '.
           display '            value of global counter = ', counter.
           display '            value of ''local-item'' = ', local-item.
           display 'calling nest1'.
           display ' '.

           call 'nest1'.
           display 'back in main program, '.
           display '            value of global counter = ', counter.
           display '            value of ''local-item'' = ', local-item.
           display ' '.

           display 'calling nest2, '.
           call 'nest2'.
           display 'back in main program, '.
           display '            value of global counter = ', counter.
           display '            value of ''local-item'' = ', local-item.
           display ' '.
           stop run.

      * Here is the first nested program.
      * Nested programs can access any GLOBAL data and have their own
      * local data.
       identification division.
       program-id.   nest1.
       working-storage section.
       01 local-item                   pic x(20) value all 'b'.
       procedure division.
           add 1 to counter.
           display 'in nest1,   adding one to counter '.
           display '            value of ''local-item'' = ', local-item.
           display ' '.
       end program nest1.

      * here is the second nested program
       identification division.
       program-id.   nest2.
       working-storage section.
       01 local-item                   pic x(20) value all 'c'.
       procedure division.
           add 1 to counter.
           display 'in nest2,   adding one to counter '.
           display '            value of ''local-item'' = ', local-item.
           display ' '.
       end program nest2.

       end program main.
