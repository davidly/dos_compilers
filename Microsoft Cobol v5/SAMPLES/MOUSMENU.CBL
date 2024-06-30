      $set notrickle nobound nonestcall align(2) noalter
      $set remove "CH"
      $set remove "function"
      $set addsyn "foreground-color" = "fg"
      $set addsyn "background-color" = "bg"
      $set addsyn "highlight" = "hl"
       program-id. MOUSMENU.
       working-storage section.
       01 OS-INFO-BLOCK.
           03 parameter-size       pic xx COMP-X value 13.
           03 P-os-type            pic x  COMP-X.
               88 PCDOS        value 3.
               88 MSDOS        value 4.
               88 MSWINDOWS    value 5.
           03 P-os-version.
               05 ws-misc-info     pic xx comp-x.
               05 ws-minor         pic x comp-x.
               05 ws-major         pic x comp-x.
           03 P-DBCS-support       pic x  COMP-X.
           03 P-char-coding        pic x  COMP-X.
           03 P-country-id         pic xx COMP-X.
           03 P-code-page          pic xx COMP-X.
           03 P-process-type       pic x  COMP-X.


      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                 Interrupt Call parameters                     *
      * These parameters are used for turning the cursor on/off       *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

       01 AX.
      *   Function 01H.
	  05 AH			  pic x.
	  05 AL			  pic x.

       01 BX.
	  05 BH			  pic x.
	  05 BL			  pic x.

       01 CX.
      *   Initialize CH to turn cursor off.
	  05 CH			  pic x.
	  05 CL			  pic x.

       01 DX.
	  05 DH			  pic x.
	  05 DL			  pic x.

      *   Interrupt 10H.
       77 Interrupt			  pic x value x"10".

      *   Load registers with CALL X"84" parameters.
       77 Flag			  pic x value x"FF".

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                       Mouse parameters                        *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
       77 MouseHandle                   pic 9(8) comp-x.

       01 MousePosition.
	  02 MouseRow		  pic 9(4) comp-x.
	  02 Mousecolumn		  pic 9(4) comp-x.

       77 MouseButtons                  pic 9(2) comp-x.

       01 EventData.
	  02 EventType		  pic 9(4) comp-x.
	  02 EventTime		  pic 9(8) comp-x.
	  02 EventRow		  pic 9(4) comp-x.
	  02 Eventcol		  pic 9(4) comp-x.

       77 ReadType                      pic 9(2) comp-x value 1.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                  Mouse Button Coordinates                     *
      *                                                               *
      * The following 88 Level's are logical button coordinates. When *
      * a mouse button is clicked, the cursor coordinates are loaded  *
      * into MousePosition. The elementary items under MousePosition  *
      * are then loaded into the appropriate 88 Level's.              *
      *                                                               *
      * The following is an example of how the 88 level's are defined:*
      *                                                               *
      * 01 ButtonRow                     pic 9(4) comp-x.             *
      *    88 ClickRow             value H"00000007" thru H"00000009".*
      *                                                               *
      * 01 ButtonColumn                  pic 9(4) comp-x.             *
      *    88 ClickColumn          value H"00000018" thru             *
      *                                  H"0000001F".                 *
      *                                                               *
      *               H"00000018"                                     *
      *               |H"00000019"                                    *
      *               ||H"0000001A"                                   *
      *   ROW         |||H"0000001B"                                  *
      *   ----------- |||| ...etc.                                    *
      *   H"00000007" .                                               *
      *   H"00000008"  button                                         *
      *   H"00000009"                                                 *
      *                                                               *
      * A simple IF statement that checks where the mouse was         *
      * clicked can now be included into the procedure division       *
      *                                                               *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

       01 ButtonRow                     pic 9(4) comp-x.
	  88 CancelRow	    value H"00000003".

	  88 BatchRow	    value H"00000007" thru
			    H"00000009".
	  88 MacroRow	    value H"0000000C" thru
			    H"0000000E".
	  88 LangRow		    value H"00000011" thru
			    H"00000013".

       01 ButtonColumn                  pic 9(4) comp-x.
	  88 CancelColumn	    value H"00000016".
	  88 ClickColumn	    value H"00000018" thru
				    H"00000020".

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                     Continuous Loop flag                      *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

       01 DemoFlag                      pic x.
	  88 DemoOver		 value 'y'.
	  88 Demoing			 value 'n'.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                  x"91"  parameters                            *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

       77 Result                        pic 99 comp-x.

       77 Function                      pic 99 comp-x value 35.

       01 Parameters.
	  02 CharNum			  pic 99 comp-x value 0.
	  02 NotUsed			  pic x.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                  ADIS parameters                              *
      * See chapter entitled "ADIS" in your Operating Guide           *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

       01 KeyStatus.
	  03 KeyType			  pic x.
	  03 KeyCode.
	     05 KeyCode1		  pic 9(2) comp-x.
	     05 KeyCode2		  pic 9(2) comp-x.

       77 BitPairs                      pic 9(2) comp-x value 1.

       77 SingleChar                    pic 9(2) comp-x value 26.

       01 DisableAll.
	  03 KeyDisableSetting	  pic 9(2) comp-x value 0.
	  03 Filler			  pic x value "1".
	  03 FirstDisableKey		  pic 9(2) comp-x value 0.
	  03 NumberOfDisabledKeys	  pic 9(2) comp-x value 128.

       77 Char                          pic x.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                       Screen Section                          *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
       screen section.

      * The screen below was created using SCREENS.EXE. See your manuals
      * for more information about this useful utility.

       01 G-DEMOPOP.
	  02 BLANK SCREEN.
	  02 LINE 1 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "
      -"                ".
	  02 LINE 2 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "
      -"                ".
	  02 LINE 3 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "
      -"                ".
	  02 LINE 4 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       " ".
	  02 COL 2 BACKGROUND-COLOR 1 FOREGROUND-COLOR 4 HIGHLIGHT VALUE
       "CLICK TO EXIT  ====> ".
	 02 COL 23 BACKGROUND-COLOR 5 HIGHLIGHT VALUE "þ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "ออออออออ
      -"อออออออออออออออออออออออออป".
	 02 COL 58 BACKGROUND-COLOR 1 FOREGROUND-COLOR 4 HIGHLIGHT VALUE
       " ".
	 02 COL 59 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"              ".
	 02 LINE 5 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 HIGHLIGHT VALUE "         DEMONSTR
      -"ATIONS          ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 6 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "ฬอออออออ
      -"ออออออออออออออออออออออออออน".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 7 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"                         ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 8 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ฺฤฤฤฤฤฤฤ
      -"ฟ".
	 02 COL 34 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"               ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 9 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ณ".
	 02 COL 26 BACKGROUND-COLOR 2 HIGHLIGHT VALUE " BATCH ".
	 02 COL 33 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ณ".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 37 BACKGROUND-COLOR 5 HIGHLIGHT VALUE "RUN SAMPLE BATCH"
       .
	 02 COL 53 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "    ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 10 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ภฤฤฤฤฤฤฤ
      -"ู".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 37 BACKGROUND-COLOR 5 HIGHLIGHT VALUE "PROGRAM".
	 02 COL 44 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"     ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 11 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "   ".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"             ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 12 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"                         ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 13 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ฺฤฤฤฤฤฤฤ
      -"ฟ".
	 02 COL 34 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"               ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 14 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ณ ".
	 02 COL 27 BACKGROUND-COLOR 2 HIGHLIGHT VALUE "MACRO".
	 02 COL 32 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE " ณ".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 37 BACKGROUND-COLOR 5 HIGHLIGHT VALUE "RUN SAMPLE MACRO"
       .
	 02 COL 53 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "    ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 15 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ภฤฤฤฤฤฤฤ
      -"ู".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 37 BACKGROUND-COLOR 5 HIGHLIGHT VALUE "PROGRAM".
	 02 COL 44 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"     ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 16 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "   ".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"             ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 17 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"                         ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 18 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ฺฤฤฤฤฤฤฤ
      -"ฟ".
	 02 COL 34 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"               ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 19 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ณ".
	 02 COL 26 BACKGROUND-COLOR 2 HIGHLIGHT VALUE " LANG  ".
	 02 COL 33 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ณ".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 37 BACKGROUND-COLOR 5 HIGHLIGHT VALUE "RUN LANGUAGE DEMO
      -"".
	 02 COL 54 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "   ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 20 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE " ".
	 02 COL 25 BACKGROUND-COLOR 2 FOREGROUND-COLOR 0 VALUE "ภฤฤฤฤฤฤฤ
      -"ู".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"             ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 21 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "   ".
	 02 COL 36 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"             ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 22 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 24 BACKGROUND-COLOR 5 FOREGROUND-COLOR 5 VALUE "
      -"                         ".
	 02 COL 57 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "บ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 23 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                      ".
	 02 COL 23 BACKGROUND-COLOR 5 FOREGROUND-COLOR 0 VALUE "ศอออออออ
      -"ออออออออออออออออออออออออออผ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 24 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "                        ".
	 02 COL 60 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE "
      -"             ".
	 02 LINE 25 COL 1 BACKGROUND-COLOR 1 FOREGROUND-COLOR 1 VALUE
       "
      -"                ".


       01 Blanker.
	  02 blank screen.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                     Procedure Division.                       *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
       procedure division.

           call "CBL_GET_OS_INFO" using OS-INFO-BLOCK.

      *    Turn cursor off.
           if MSDOS or PCDOS
               move x"01" to AH
               move x"20" to CH
               call x"84" using Interrupt, Flag, AX, BX, CX, DX
               end-call
           end-if.

      *    Disable Function Keys.
	   call x"AF" using BitPairs,
			    DisableAll
	   end-call

      *    Initialize the Mouse
	   perform MouseInit

	   display G-DemoPop

      *    Initialize the loop.
	   move 'n' to DemoFlag

      *    Main body of loop.
	   perform until DemoOver
	     perform MouseStuff
	     perform MouseQuery
	   end-perform

      *    Terminates the Mouse, reactivates the cursor
      *    and exits to Demo.exe.
      *    Note that the following line is explicitly terminated with
      *    a period. The line prior to a new paragraph name (or the last
      *    line in a program) should always be terminated by a paragraph
      *    or you will receive an error during compilation.
	   perform ShutDown.

       MouseInit.
	   call "cbl_init_mouse" using MouseHandle
				       MouseButtons
	   end-call

	   call "cbl_show_mouse" using MouseHandle
	   end-call.

       MouseStuff.
	   move zeroes to EventData
      *> The following loop tests
      *> for a left mouse button click.
      *> Note: In-line comment markers are a new feature
      *> you might not be aware of. When the COBOL compiler
      *> encounters this marker, it ignores all the subsequent
      *> text remaining on the line.
	   perform until EventType = 2

	     call "cbl_read_mouse_event" using MouseHandle
					     EventData
					     ReadType
	     end-call

	     call "cbl_get_mouse_position" using MouseHandle
					       MousePosition
	     end-call

	   end-perform.

      *    A mouse click has occured. Now we test to see where
      *    the click took place on the screen.
	   move MouseRow to ButtonRow
	   move Mousecolumn to ButtonColumn.

       MouseQuery.
	   if CancelRow	and CancelColumn
	      move 'y'	to DemoFlag
	      display blanker
	   else

	      if BatchRow	and ClickColumn
		 *> This call hides the Mouse cursor
		 *> during the batch file processing
		 call "cbl_hide_mouse" using MouseHandle
		 end-call
		 display blanker
		 perform BatchCall
		 *> We've returned from the batch file so redisplay
		 *> the mouse cursor and menu screen.
		 call "cbl_show_mouse" using MouseHandle
		 end-call
		 display G-DemoPop
	      else

		 if MacroRow and ClickColumn
		 *> See comments above for the Batch button procedure
		    call "cbl_hide_mouse" using MouseHandle
		    end-call
		    perform BatchCall
		    call "cbl_show_mouse" using MouseHandle
		    end-call
		    display G-DemoPop
		 else

		    if LangRow and ClickColumn
		    *> See comments above for the Batch button procedure
		       call "cbl_hide_mouse" using MouseHandle
		       end-call
		       perform BatchCall
		       call "cbl_show_mouse" using MouseHandle
		       end-call
		       display G-DemoPop
		    end-if.

       BatchCall.
      *    Reinitialize call parameters everytime you use them
      *    just to be safe.
	   move 35 to Function
	   move 0 to CharNum

	   display "SHELL.BAT" upon command-line.
	   call x"91" using Result
			    Function
			    Parameters
	   end-call.

       ShutDown.
      *    The Cobol runtime system will kill the Mouse Handle at
      *    program termination.

      *    Turn cursor on again.
           if MSDOS or PCDOS
               move x"01" to AH
               move x"06" to CH
               move x"07" to CL
               call X"84" using Interrupt, Flag, AX, BX, CX, DX
               end-call
	   end-if


	   stop run.
