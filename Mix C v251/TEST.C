/*  This is a simple program that tests whether or not the Ctrace
    output window is working properly.  If the ANSI.SYS driver is
    loaded, the output window will not work properly unless Ctrace
    is informed that the driver is present.                        */

main()
{
   int i;
   for (i=0; i<25; i++) puts("");
   printf("    This is a test...");
   for (i=0; i<10; i++) {
      printf("\n%5d) ", i+1);
      printf("Now is the time for all good programmers to learn C.");
   }
}

/*  The output should look like this:

    This is a test...
    1) Now is the time for all good programmers to learn C.
    2) Now is the time for all good programmers to learn C.
    3) Now is the time for all good programmers to learn C.
    4) Now is the time for all good programmers to learn C.
    5) Now is the time for all good programmers to learn C.
    6) Now is the time for all good programmers to learn C.
    7) Now is the time for all good programmers to learn C.
    8) Now is the time for all good programmers to learn C.
    9) Now is the time for all good programmers to learn C.
   10) Now is the time for all good programmers to learn C.
                                                                   */
