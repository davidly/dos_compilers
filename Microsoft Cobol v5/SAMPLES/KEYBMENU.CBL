      $set remove "ch"
      $set addsyn "highlight" = "hl"
      $set addsyn "background-color" = "bg"
       program-id. kdemo.
       special-names.
	  crt status is KeyStatus.

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

      * Function 01H for cursor control.
	01 AX.
	   05 AH		  pic x.
	   05 AL		  pic x.

	01 BX.
	   05 BH		  pic x.
	   05 BL		  pic x.

      * Initialize CH to turn cursor off.
	01 CX.
	   05 CH		  pic x.
	   05 CL		  pic x.

	01 DX.
	   05 DH		  pic x.
	   05 DL		  pic x.

      * Interrupt 10H for cursor control.
	77 Interrupt		  pic x value x"10".

      * Load registers with CALL X"84" parameters.
	77 Flag			  pic x value x"FF".

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                     ADIS call Parameters                      *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

      * For queries on KeyType.
	01 KeyStatus.
	   02 KeyType		  pic x.
	   02 KeyCode1		  pic 9(2) comp-x.
	   02 KeyCode2		  pic 9(2) comp-x.

      * For calls to x"AF".
	77 SetBitPairs		 pic 9(2) comp-x value 1.

      * For enabling and disabling User Keys.
	01 UserKeyControl.
	   02 UserKeySetting	  pic 9(2) comp-x.
	   02 filler		  pic x value "1".
	   02 FirstUserKey	  pic 9(2) comp-x.
	   02 NumberOfUserKeys	  pic 9(2) comp-x.

      * For enabling and disabling ADIS Keys.
	01 AdisKeyControl.
	   02 AdisKeySetting	  pic 9(2) comp-x.
	   02 filler		  pic x value "2".
	   02 FirstAdisKey	  pic 9(2) comp-x.
	   02 NumberOfAdisKeys	pic 9(2) comp-x.

      * For enabling and disabling Data Keys.
	01 DataKeyControl.
	   02 DataKeySetting	  pic 9(2) comp-x.
	   02 filler		  pic x value "3".
	   02 FirstDataKey	  pic x.
	   02 NumberOfDataKeys	pic 9(2) comp-x.

      * For enabling and disabling ADIS Functions.
	01 ParameterBlock.
	   02 BitPairSetting	  pic 9(2) comp-x.
	   02 filler		  pic x value "2".
	   02 BitPairNumber	  pic 9(2) comp-x.
	   02 filler		  pic 9(2) comp-x value 1.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                   cbl_ Call Parameters                        *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	77 Char 		 pic x.

	01 ScreenPosition.
	   02 Y			 pic x comp-x.
	   02 X			 pic x comp-x.

      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      *                   Scroll Variables and Flags                  *
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	77 CurrentY		 pic 99.
	77 NewY 		 pic 99.
	77 UpDown		 pic x.
	77 Dummy		 pic x.
	01 SelectFlag		 pic x.
	   88 ItemSelected	 value 'y'.

       screen section.
       01 MenuBox.
	  02 blank screen 
	     background-color 1.
	  02 line 03 col 31 value "[HIGHLIGHT DEMO]" hl.
	  02 line 07 col 34 value "  SCROLL  " hl.
	  02 line 08 col 34 value "   BOX    " hl.
	  02 line 09 col 34 value "ษออออออออป" hl.
	  02 line 10 col 34 value "บ  FILE  บ" hl.
	  02 line 11 col 34 value "บ  EDIT  บ" hl.
	  02 line 12 col 34 value "บ SEARCH บ" hl.
	  02 line 13 col 34 value "บ LOOKUP บ" hl.
	  02 line 14 col 34 value "บ OPTION บ" hl.
	  02 line 15 col 34 value "บ  HELP  บ" hl.
	  02 line 16 col 34 value "ศออออออออผ" hl.

       01 HelpBox.
	  02 background-color 1.
	  02 line 22 col 1 value "ษออออออออออออออออออออออออออออออออออ" &
	     "ออออออออออออออออออออออออออออออออออออออออออออป" hl.
	  02 line 23 col 1 value "บValid keys are:                   " &
	     "                                            บ" hl.
	  02 line 24 col 1 value "บ                [Enter]     [End] " &   
	     "  [Home]              [Esc]               บ" hl.
	  02 line 25 col 1 value "ศออออออออออออออออออออออออออออออออออ" &
	     "ออออออออออออออออออออออออออออออออออออออออออออผ" hl.

       01 Blanker.
	  02 blank screen background-color 0.

       procedure division.

           call "CBL_GET_OS_INFO" using OS-INFO-BLOCK.

      * Display the screen.
	  display MenuBox
	  display HelpBox

      * Turn the cursor off.
	  if PCDOS or MSDOS
	     move x"01" to AH	*> Interrupt 10H Function 01H.
	     move x"20" to CH	*> Setting CH to this value causes the cursor
				*> to disappear.
	     call X"84" USING INTERRUPT, FLAG, AX, BX, CX, DX
	     end-call
	  end-if

      * Enable the Escape key.
	  move 1 to UserKeySetting
	  move 0 to FirstUserKey
	  move 1 to NumberOfDataKeys
	  call x"af" using SetBitPairs, UserKeyControl
	  end-call

      * Disable Remaining User Function keys.
	  move 0 to UserKeySetting
	  move 1 to FirstUserKey
	  move 127 to NumberOfDataKeys
	  call x"af" using SetBitPairs, UserKeyControl
	  end-call

      * Disable All Lower ASCII Data keys.
	  move 0 to DataKeySetting
	  move " " to FirstDataKey
	  move 94 to NumberOfDataKeys
	  call x"af" using SetBitPairs, DataKeyControl
	  end-call

      * Disable Unused ADIS keys.
	  move 0 to AdisKeySetting
	  move 0 to FirstAdisKey
	  move 2 to NumberOfAdisKeys
	  call x"af" using SetBitPairs, AdisKeyControl
	  end-call

	  move 8 to FirstAdisKey
	  move 20 to NumberOfAdisKeys
	  call x"af" using SetBitPairs, AdisKeyControl
	  end-call

      * Enable Appropriate ADIS Cursor keys.
	  move 1 to AdisKeySetting
	  move 2 to FirstAdisKey
	  move 6 to NumberOfAdisKeys
	  call x"af" using SetBitPairs, AdisKeyControl
	  end-call

	  move 10 to FirstAdisKey
	  move 1 to NumberOfAdisKeys
	  call x"af" using SetBitPairs, AdisKeyControl
	  end-call

      * Disable ADIS Indicators.
	  move 3 to BitPairSetting
	  move 56 to BitPairNumber
	  call x"af" using SetBitPairs, ParameterBlock
	  end-call
	  move 57 to BitPairNumber
	  call x"af" using SetBitPairs, ParameterBlock
	  end-call
	  move 58 to BitPairNumber
	  call x"af" using SetBitPairs, ParameterBlock
	  end-call

      * Disable ADIS Error Messages.
	  move 0 to BitPairSetting
	  move 44 to BitPairNumber
	  call x"af" using SetBitPairs, ParameterBlock
	  end-call

      * Highlight the first Scroll field and initialize the counter.
	  move 34 to X
	  move 9 to Y

	  call "cbl_write_scr_n_attr" using ScreenPosition,
					    x"2E",	*> Attributes
					    x"0008"	*> FillLength
	  end-call
	  move Y to CurrentY   *> The variable "Y" is defined as an elementary
			       *> item for ScreenPosition.

	  display "Call the File program   " at 2030 with bg 1 hl

      * Initialize the Loop.
	  move 'n' to SelectFlag

      * Loop until an item is selected.
	  perform until ItemSelected

      * Accept a dummy variable at Row 20 Col 80 to determine
      * which key has been pressed.
	  accept Dummy at 2080
	  end-accept

	  if KeyType = "2"	       *> Was the Key an ADIS Key?
	     evaluate KeyCode1	       *> Answer: Yes.
	      when 2		       *> Was Enter pressed?
	       move 'y' to SelectFlag  *> Answer: Yes.
	       display "You've chosen to execute the selected choice"
		       at 1820 with bg 1 hl
	       display "Press any key to Exit  " at 2030 with bg 1 hl
	       call "cbl_read_kbd_char" using Char
	       end-call
	      when 5		*> Was the Up Arrow pressed?
	       perform MoveUp
	      when 6		*> Was the Down Arrow pressed?
	       perform MoveDown
	      when 7		*> Was the Home Key pressed?
	       move 9	to Newy
	       display "Call the File program   " at 2030
		with bg 1 hl
	      when 10		*> Was the End Key pressed?
	       move 14 to Newy
	       display "Call the Help program   " at 2030
		       with bg 1 hl
	     end-evaluate
	     perform VScroller	*> Scroll to the Chosen field.
	  else
	    if KeyType = "1" and *> Was a User Key pressed and, if
	      KeyCode1 = 0	*> so, was it the Escape Key?
	       move 'y' to SelectFlag.

	  perform ExitProgram.	*> Clean up and Exit the program.

	MoveUp.	*> This paragraph determines the new highlight location.
	  evaluate CurrentY
	   when 9
	    move 14 to NewY
	    display "Call the Help program   " at 2030 with bg 1 hl
	   when 10
	    move 9 to NewY
	    display "Call the File program   " at 2030 with bg 1 hl
	   when 11
	    move 10 to NewY
	    display "Call the Edit program   " at 2030 with bg 1 hl
	   when 12
	    move 11 to NewY
	    display "Call the Search program " at 2030 with bg 1 hl
	   when 13
	    move 12 to NewY
	    display "Call the Lookup program " at 2030 with bg 1 hl
	   when 14
	    move 13 to NewY
	    display "Call the Option program " at 2030 with bg 1 hl
	  end-evaluate.

       MoveDown. *> This paragraph does the same as the above.
	  evaluate CurrentY
	   when 9
	    move 10 to NewY
	    display "Call the Edit program   " at 2030 with bg 1 hl
	   when 10
	    move 11 to NewY
	    display "Call the Search program " at 2030 with bg 1 hl
	   when 11
	    move 12 to NewY
	    display "Call the Lookup program " at 2030 with bg 1 hl
	   when 12
	    move 13 to NewY
	    display "Call the Option program " at 2030 with bg 1 hl
	   when 13
	    move 14 to NewY
	    display "Call the Help program   " at 2030 with bg 1 hl
	   when 14
	    move 9 to NewY
	    display "Call the File program   " at 2030 with bg 1 hl
	  end-evaluate.

       VScroller. *> Refresh the old field and highlight the new.
	  move CurrentY to Y
	  call "cbl_write_scr_n_attr" using ScreenPosition,
					    x"1F",	*> Attributes
					    x"0008"	*> FillLength
	  end-call
	  move NewY to Y
	  call "cbl_write_scr_n_attr" using ScreenPosition,
					    x"2E",	*> Attributes
					    x"0008"	*> FillLength
	  end-call
	  move NewY to CurrentY. *> Make the New field current.

       ExitProgram.

      * Clear the screen.
	  display Blanker.

      * Turn cursor on again.
          if PCDOS or MSDOS
               move x"01" to AH
               move x"06" to CH
               move x"07" to CL
               call X"84" using INTERRUPT, FLAG, AX, BX, CX, DX
               end-call
	  end-if

      * Exit.
	  stop run.
