      $set mf noosvs ans85
      *****************************************************************
      *                                                               *
      *              (C) Micro Focus Ltd. 1989                        *
      *                                                               *
      *                     STATUS.CBL                                *
      *                                                               *
      * This program demonstrates how to interpret values returned    *
      * in the second of the two status bytes.  Status bytes are set  *
      * up after EVERY file operation (assuming that you have declared*
      * them in the select clause) and it is important to check the   *
      * values returned after every operation.  This program shows how*
      * to do this.                                                   *
      *                                                               *
      * The program tries to open and close a file called INPUT.FIL.  *
      * If the operations fail it displays the corresponding file     *
      * status bytes                                                  *
      *                                                               *
      *****************************************************************

       identification division.
       program-id.    check-file-status.

       select input-file assign "input.fil"
       organization sequential
       status stat.

       fd input-file.
       01 input-record pic x(80).

       working-storage section.

      * define status bytes and redefinition as follows
      * (note that the picture clauses are important)
       01 stat.
           03 s1   pic x.
           03 s2   pic x.
           03 s2-bin redefines s2
                   pic 9(2) comp-x.

      * have a display item too.
       01 stat-display.
           03 s1-display pic x.
           03 filler     pic x.
           03 s2-display pic 9(3).

       procedure division.
           open input input-file.
           perform check-status.

           close input-file.
           perform check-status.

           stop run.

       check-status.
      * a value of "00" indicates a successful operation
           if stat not = "00" then
               move s1 to s1-display
               if s1 = "9" then
                   move s2-bin to s2-display
               else
                   move s2 to s2-display
               end-if
               display "operation fails - current status = "
                       stat-display
           end-if.
