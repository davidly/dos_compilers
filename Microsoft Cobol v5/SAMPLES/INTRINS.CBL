      $set mf noosvs ans85
      ************************************************************
      *                                                          *
      *              (C) Micro Focus Ltd. 1991                   *
      *                                                          *
      *                     INTRINS.CBL                          *
      *                                                          *
      *    This program demonstrates some of the ways you can    *
      *    use Intrinsic Functions in your COBOL application.    *
      *    This program uses the FACTORIAL Intrinsic Function    *
      *    to illustrate the following capabilities:             *
      *                                                          *
      *    1) Data item is assigned the value of a function      *
      *    2) Function is used as a data item in an EVALUATE     *
      *           statement                                      *
      *    3) Function is used as a data item in an IF           *
      *           statement                                      *
      *    4) Function uses an array element (fixed index) as    *
      *           an argument                                    *
      *    5) Function uses an array element (variable index)    *
      *           as an argument                                 *
      *    6) Data item is assigned the value of a function of   *
      *           a function                                     *
      *    7) Data item, assigned the value of the function,     *
      *           is used in a COMPUTE statement                 *
      *    8) Data item is assigned the value of the sum of      *
      *           two functions                                  *
      *    9) Function is used in the UNTIL condition of a       *
      *           PERFORM ... UNTIL statement                    *
      *                                                          *
      *                                                          *
      *    To familiarize yourself with the Intrinsic function   *
      *    syntax, try running INTRINS under Animator.           *
      *                                                          *
      *    Compile the program using:                            *
      *                                                          *
      *           COBOL INTRINS ANIM;                            *
      *                                                          *
      *    then animate the program:                             *
      *                                                          *
      *           ANIMATE INTRINS                                *
      *                                                          *
      *                                                          *
      *    For more information see the Language Reference       *
      *    Manual and the COBOL/2 User Guide.                    *
      *                                                          *
      ************************************************************
       working-storage section.
       78 fals value 0.
       78 tru  value 1.

       01 true-or-false    pic 9(1).

       01 factor           pic s9(10).

       01 val              pic s9(10).

       01 indx             pic 9(5) comp-x.

       01 arg              pic 9(2) comp-x value 5.

       01 arr                        value "40537".
           03 elem   occurs 5 times      pic 9.

       procedure division.

       main-section.

      ************************************************************
      * Form 1 - Data item is assigned the value of the function *
      ************************************************************

           compute factor = function factorial(0)

      ************************************************************
      * Form 2 - Function is used as a data item in an EVALUATE  *
      *          statement                                       *
      ************************************************************

           evaluate function factorial(3)
           when 6
               move tru to true-or-false
           when other
               move fals to true-or-false
           end-evaluate

      ************************************************************
      * Form 3 - Function is used as a data item in an IF        *
      *          statement                                       *
      ************************************************************

           if function factorial(arg) = 120 then
               move tru to true-or-false
           else
               move fals to true-or-false
           end-if

      ************************************************************
      * Form 4 - Function uses an array element (fixed index) as *
      *          an argument                                     *
      ************************************************************

           compute factor = function factorial(elem(4))

      ************************************************************
      * Form 5 - Function uses an array element (variable index) *
      *          as an argument                                  *
      ************************************************************

           move 4 to indx
           compute factor = function factorial(elem(indx))

      ************************************************************
      * Form 6 - Data item is assigned the value of a function   *
      *          of a function                                   *
      ************************************************************

           compute factor = function factorial(
                               function factorial(3))

      ************************************************************
      * Form 7 - Data item, assigned the value of the function,  *
      *          is used in a COMPUTE statement                  *
      ************************************************************

           compute val = function factorial(3) + 5

      ************************************************************
      * Form 8 - Data item is assigned the value of the sum of   *
      *          two functions                                   *
      ************************************************************

           compute val = function factorial(3) +
                           function factorial(5)

      ************************************************************
      * Form 9 - Function is used in the UNTIL condition of a    *
      *          PERFORM ... UNTIL statement                     *
      ************************************************************

           move 1 to indx
           perform para-1 until function factorial(indx) > 10
           stop run.

       para-1.
           compute indx = indx + 1.














