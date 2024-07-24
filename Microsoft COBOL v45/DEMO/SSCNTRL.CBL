      $set ans85 noosvs mf
      *****************************************************************
      *                                                               *
      *              (C) Micro Focus Ltd. 1989                        *
      *                                                               *
      *                     SSCNTRL.CBL                               *
      *                                                               *
      * Demonstration of the use of dynamic attributes in screen      *
      * section.  This example shows how to use the CONTROL clause    *
      * in a screen section to indicate invalid fields after an       *
      * accept statement.  Monochrome terminal users can also see     *
      * the use of attribute strings to set reverse video; color      *
      * terminal users can "uncomment" the line changing colors to    *
      * view the use of attribute strings to set colors.             *
      *****************************************************************

       working-storage section.
       01 field1  pic x(4) value spaces.
       01 field2  pic x(4) value spaces.
       01 field3  pic x(4) value spaces.
       01 attr-string  pic X(50).

       78 ws-reverse-video value 'reverse-video'.
       78 ws-highlight    value 'highlight'.
       78 ws-blink        value 'blink'.
       78 ws-red-on-white value 'foreground-color 4 background-color 7'.

       screen section.
       01 blank-screen blank screen.

       01 screen-1.
           05 line 3 col 15
                   value 'Fill the fields with data'.
           05 line 6 col 20 value 'Field 1 : '.
           05 pic xxxx using field1 auto-skip full required.
           05 line 8 col 20 value 'Field 2 : '.
           05 pic xxxx using field2
                       control attr-string auto-skip full required.
           05 line 10 col 20 value 'Field 3 : '.
           05 pic xxxx using field3 required.

       01 error-screen.
           05 line 24 col 10
                   value 'Field 2 must contain ''9999'' to terminate'.

       procedure division.
           display blank-screen
           perform until field2 = '9999'
               display screen-1
               accept screen-1
               if field2 not    = '9999'
                   display error-screen
*******            move ws-red-on-white  to attr-string
                   move ws-reverse-video to attr-string
               end-if
           end-perform.
           stop run.

