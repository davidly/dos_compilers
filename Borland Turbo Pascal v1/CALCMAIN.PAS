{ Compile this file if you get the error message: "Compiler overflow"
  when compiling the file CALC.PAS.

  When developing programs it is a good idea to split the program into
  several include files, and then have a small main file containing the
  global variables and Include directives for the different source code
  modules.You may want to spit the file CALC.PAS into such modules.

  If you want to edit the file CALC.PAS then select it as Work file using
  the W command.

  The calc demo prorgam CALC.PAS is now included:
}


{$ICALC.PAS}

{ If you have more than 128K RAM it is possible to have the following in
  RAM at the same time:

   Compiler and Editor
   CALC.PAS
   Object code generated for CALC.PAS
   Data area for CALC.PAS

}

