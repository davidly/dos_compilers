
      *  ************* START OF COPIED FILE *************
           DISPLAY SPACE.
           DISPLAY SPACE.
           DISPLAY TEN-SPACES, 
           " This is program DEMO, the first program in the".
           DISPLAY TEN-SPACES, 
           " MS-COBOL demonstration suite. In this suite".
           DISPLAY TEN-SPACES, 
           " of programs, you will see several information and".
           DISPLAY TEN-SPACES, 
           " menu screens which will guide you through the ".
           DISPLAY TEN-SPACES, 
           " demonstration.". 
           DISPLAY SPACE.
           DISPLAY TEN-SPACES, 
           ' If you see the runtime error message "Must run Install"'.
           DISPLAY TEN-SPACES, 
           " after this screen is displayed, that indicates that".
           DISPLAY TEN-SPACES, 
           " you have not run the INSTALL utility, which adapts".
           DISPLAY TEN-SPACES, 
           " COBOL to your terminal screen.".
           DISPLAY SPACE.
           DISPLAY TEN-SPACES, 
           " If this happens, please see the MS-COBOL Users' Guide".
           DISPLAY TEN-SPACES, 
           " for instructions on running the INSTALL utility. ".
           DISPLAY SPACE.
           DISPLAY TEN-SPACES, 
           " After running INSTALL, you can successfully run this".
           DISPLAY TEN-SPACES, 
           " demonstration. You can cancel this program now by typing"
           DISPLAY TEN-SPACES,
           " E (for End) followed by ENTER.".
           DISPLAY " ".
           DISPLAY TEN-SPACES,
           " Please hit ENTER by itself to continue. ".
           ACCEPT WS-OPTION.

           IF NOT (END-OPTION)
               PERFORM P005-PROCESS.
      *  ************* END OF COPIED FILE *************


