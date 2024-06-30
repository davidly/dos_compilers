      $set mf ans85 noosvs
      *******************************************************************
      *                                                                 *
      *                                                                 *
      *                  (C) Micro Focus Ltd. 1989                      *
      *                                                                 *
      *                            ADD.CBL                              *
      *                                                                 *
      * This program shows how to call the assembler routine ADDEM.ASM. *
      * It can be called dynamically as a .EXE or .DLL file, or         *
      * statically linked.                                              *
      *                                                                 *
      * To statically link you must compile this program with the       *
      * LITLINK directive (or change the call below to call "__addem"). *
      *                                                                 *
      * To dynamically link, compile the program as it is without the   *
      * LITLINK directive.                                              *
      *                                                                 *
      * The assembler routine gets the value of the first parameter,    *
      * adds it to the value of second-param and returns the result     *
      * in res-ult.                                                     *
      *                                                                 *
      *******************************************************************

       working-storage section.
       01 comp-fields.
           03 first-param      pic 99 comp value 3.
           03 second-param     pic 99 comp value 5.
           03 res-ult          pic 99 comp.

       01 display-first-param  pic Z9.
       01 display-second-param pic Z9.
       01 display-res-ult      pic Z9.

       procedure division.

      * call to assembler routine
           call "addem" using first-param, second-param, res-ult.

      *set up display fields
           move first-param  to display-first-param.
           move second-param to display-second-param.
           move res-ult      to display-res-ult.

      * display results of the call
           display display-first-param " + "
                   display-second-param " = "
                   display-res-ult.
       stop run.
