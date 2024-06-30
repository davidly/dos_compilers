      $SET COMP NOALTER NOQUAL ANS85
      ******************************************************************
      *  Example program to demonstrate the use of the PANELS module.
      *
      *  Copyright (c) Micro Focus 1987.
      *
      ******************************************************************

       WORKING-STORAGE SECTION.

      ******************************************************************
      *  Work Variables.
      *
      *  Screen-Height	   = Used to store the height of the screen
      * 		     after it has been retrieved from PANELS.
      *  Menu-Panel-ID	   = The ID of the menu panel returned when the
      * 		     menu panel is created.
      *  Panel-A-ID	   = The ID of the panel A returned when the
      * 		     panel is created.
      *  Panel-B-ID	   = The ID of the panel B returned when the
      * 		     panel is created.
      *  Help-Panel-ID	   = The ID of the help panel.
      *  Current-Panel-ID  = The ID of the currently selected panel.
      *  Current-Selection = The number of the current selection in the
      * 		     pop-up selection menu.
      *  Help-Text-Row	   = The current row of help text that is at
      * 		     the top of the help panel (Starting from
      * 		     0).
      *  Help-Text-Column  = The current column of help text that is at
      * 		     the left-hand side of the help panel
      * 		     (Starting from 1)
      *
      ******************************************************************

       01 Work-Variables.
	03 Screen-Height	       PIC 9(4) COMP.
	03 Menu-Panel-ID	       PIC 9(4) COMP.
	03 Panel-A-ID		       PIC 9(4) COMP.
	03 Panel-B-ID		       PIC 9(4) COMP.
	03 Help-Panel-ID	       PIC 9(4) COMP.
	03 Current-Panel-ID	       PIC 9(4) COMP.
	03 Current-Selection	       PIC 9(4) COMP.
	03 Help-Text-Row	       PIC 9(4) COMP.
	03 Help-Text-Column	       PIC 9(4) COMP.

      /*****************************************************************
      *  Run Time System Calls Used.
      *
      *  Get-Character (X"83")	   - Waits for a key to be pressed on
      * 			     the keyboard. The character is
      * 			     read into Char. If Char is set to
      * 			     X"0D" it indicates that one of the
      * 			     keys defined in the function key
      * 			     table has been pressed and
      * 			     Key-Table-Return-Byte returns the
      * 			     number of that key.
      *
      *  Keyboard-Function (X"B0") - Performs a number of sub-functions.
      * 			     The only one used in this program
      * 			     is to set up a function key table
      * 			     (Sub-function 0).
      *
      *  Move-Cursor (X"E6")	   - Used to move the cursor. In this
      * 			     case, it is used to hide the
      * 			     cursor by positioning at an
      * 			     invalid position.
      *
      ******************************************************************

       78 Get-Character 	       VALUE X"83".
       78 Keyboard-Function	       VALUE X"B0".
       78 Move-Cursor		       VALUE X"E6".

       01 Set-Key-Table-Func	       PIC 9(2) COMP VALUE 0.
       01 Char			       PIC X.
       01 Hide-Cursor		       PIC XX VALUE X"FFFF".

      /*****************************************************************
      *  Keyboard Handling Data Area
      ******************************************************************

      ******************************************************************
      *  Function key table set up to detect the Function and cursor
      *  keys.
      ******************************************************************

       01 Function-Key-Table.
	03 Key-Table-Return-Byte       PIC 9(2) COMP.
	03 F1-Key-Sequence	       PIC X(3) VALUE X"02003B".
	03 F2-Key-Sequence	       PIC X(3) VALUE X"02003C".
	03 F3-Key-Sequence	       PIC X(3) VALUE X"02003D".
	03 F4-Key-Sequence	       PIC X(3) VALUE X"02003E".
	03 F5-Key-Sequence	       PIC X(3) VALUE X"02003F".
	03 F6-Key-Sequence	       PIC X(3) VALUE X"020040".
	03 Cursor-Left-Sequence        PIC X(3) VALUE X"02004B".
	03 Cursor-Right-Sequence       PIC X(3) VALUE X"02004D".
	03 Cursor-Up-Sequence	       PIC X(3) VALUE X"020048".
	03 Cursor-Down-Sequence        PIC X(3) VALUE X"020050".
	03 Shift-Left-Sequence	       PIC X(2) VALUE X"0134".
	03 Shift-Right-Sequence        PIC X(2) VALUE X"0136".
	03 Shift-Up-Sequence	       PIC X(2) VALUE X"0138".
	03 Shift-Down-Sequence	       PIC X(2) VALUE X"0132".
	03 Esc-Key-Sequence	       PIC X(2) VALUE X"011B".
	03 Key-Table-Terminator        PIC X VALUE X"00".

      ******************************************************************
      *  Constants defining the value returned by each key defined in
      *  the function key table
      ******************************************************************

       78 Return-Key		       VALUE 0.
       78 F1-Key		       VALUE 1.
       78 F2-Key		       VALUE 2.
       78 F3-Key		       VALUE 3.
       78 F4-Key		       VALUE 4.
       78 F5-Key		       VALUE 5.
       78 F6-Key		       VALUE 6.
       78 Cursor-Left		       VALUE 7.
       78 Cursor-Right		       VALUE 8.
       78 Cursor-Up		       VALUE 9.
       78 Cursor-Down		       VALUE 10.
       78 Shift-Cursor-Left	       VALUE 11.
       78 Shift-Cursor-Right	       VALUE 12.
       78 Shift-Cursor-Up	       VALUE 13.
       78 Shift-Cursor-Down	       VALUE 14.
       78 Esc-Key		       VALUE 15.

      /*****************************************************************
      *  Copy file containing panel interface information
      ******************************************************************

       COPY "PANLINK.CPY".

      /*****************************************************************
      *  Copy file containing text and attributes to be written to the
      *  panels
      ******************************************************************

       COPY "PANCONT.CPY".

      /*****************************************************************
      *  Procedure Division
      ******************************************************************

       PROCEDURE DIVISION.
       Panels-Example SECTION.
      *    First, force PANELS to redraw it's image of the screen. As
      *    no panels exist yet, the screen will be cleared.
	   MOVE PF-Redraw-Screen TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Now find out the dimensions of the screen and save the
      *    height of the screen for future use.

	   MOVE PF-Get-Screen-Info TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE PPB-Visible-Height TO Screen-Height.

      *    Turn cursor off by positioning it at an invalid position.
	   CALL Move-Cursor USING Hide-Cursor Hide-Cursor.

      *-----------------------------------------------------------------
      *    Create, initialise and enable the panels.

	   PERFORM Create-Panels.

      *-----------------------------------------------------------------

      *    Select the first panel to be acted on
	   MOVE Help-Panel-ID TO Current-Panel-ID
	   PERFORM Alter-Status-Line.

      *    Set up the function key table
	   CALL Keyboard-Function USING Set-Key-Table-Func
					Function-Key-Table.

      *-----------------------------------------------------------------
      *    Main Program Loop

       Main-Loop.
      *    Read a character from the keyboard
	   CALL Get-Character USING Char
      *    If not a function key, try again.
	   IF Char NOT = X"0D" GO TO Main-Loop.
	   MOVE Current-Panel-ID TO PPB-Panel-ID
	   EVALUATE Key-Table-Return-Byte
	     WHEN F1-Key
      *        Select Help panel and re-enable it
	       MOVE Help-Panel-ID TO Current-Panel-ID
	       PERFORM Alter-Status-Line
	       MOVE PF-Enable-Panel TO PPB-Function
	       CALL "PANELS" USING Panels-Parameter-Block

	     WHEN F2-Key
      *        Enable Panel
	       MOVE PF-Enable-Panel TO PPB-Function
	       CALL "PANELS" USING Panels-Parameter-Block

	     WHEN F3-Key
      *        Disable Panel
	       MOVE PF-Disable-Panel TO PPB-Function
	       CALL "PANELS" USING Panels-Parameter-Block

	     WHEN F4-Key
      *        Select next panel for all following operations. The
      *        panels are selected in the following order :
      *        Help - Panel A - Panel B - Menu - Help ...
	       EVALUATE Current-Panel-ID
		 WHEN Menu-Panel-ID
		   MOVE Help-Panel-ID TO Current-Panel-ID
		 WHEN Help-Panel-ID
		   MOVE Panel-A-ID TO Current-Panel-ID
		 WHEN Panel-A-ID
		   MOVE Panel-B-ID TO Current-Panel-ID
		 WHEN Panel-B-ID
		   MOVE Menu-Panel-ID TO Current-Panel-ID
	       END-EVALUATE
	       PERFORM Alter-Status-Line

	     WHEN F5-Key
      *        Select panel via pop-up menu
	       PERFORM Select-New-Panel
	       PERFORM Alter-Status-Line

	     WHEN F6-Key
      *        Position panel back at it's initial position
	       PERFORM Back-To-Start-Position

	     WHEN Cursor-Left
      *        Shift panel to the left.
	       MOVE PPB-Panel-Width TO PPB-Visible-Width
	       IF PPB-Panel-Start-Column > 0
		 SUBTRACT 1 FROM PPB-Panel-Start-Column
	       ELSE
      * 	 If we are at the left-hand edge of the screen, reduce
      * 	 the visible portion of the panel to give the
      * 	 impression of the panel disappearing off the edge of
      * 	 the screen.
		 IF PPB-First-Visible-Col < PPB-Panel-Width
		   ADD 1 TO PPB-First-Visible-Col
		 END-IF
	       END-IF
	       PERFORM Shift-Panel

	     WHEN Cursor-Right
      *        Shift panel to the Right.
	       MOVE PPB-Panel-Width TO PPB-Visible-Width
	       IF PPB-First-Visible-Col > 0
      * 	 If we are off the left-hand side of the screen,
      * 	 increase the visible portion of the panel to give the
      * 	 impression of reappearing on the screen
		 SUBTRACT 1 FROM PPB-First-Visible-Col
	       ELSE
		 ADD 1 TO PPB-Panel-Start-Column
	       END-IF
	       PERFORM Shift-Panel

	     WHEN Cursor-Up
      *        Shift panel upwards.
	       MOVE PPB-Panel-Height TO PPB-Visible-Height
	       IF PPB-Panel-Start-Row > 0
		 SUBTRACT 1 FROM PPB-Panel-Start-Row
	       ELSE
      * 	 If we are at the top of the screen, reduce the visible
      * 	 portion of the panel to give the impression of the
      * 	 panel disappearing off the top of the screen.
		 IF PPB-First-Visible-Row < PPB-Panel-Height
		   ADD 1 TO PPB-First-Visible-Row
		 END-IF
	       END-IF
	       PERFORM Shift-Panel

	     WHEN Cursor-Down
      *        Shift panel downwards.
	       MOVE PPB-Panel-Height TO PPB-Visible-Height
	       IF PPB-First-Visible-Row > 0
      * 	 If we are off the top of the screen, increase the
      * 	 visible portion of the panel to give the impression of
      * 	 reappearing on the screen
		 SUBTRACT 1 FROM PPB-First-Visible-Row
	       ELSE
		 ADD 1 TO PPB-Panel-Start-Row
	       END-IF
	       PERFORM Shift-Panel

	     WHEN Shift-Cursor-Left
      *        Move left through the help text
	       IF Help-Text-Column > 1
		 MOVE PS-Scroll-Right TO PPB-Scroll-Direction
		 SUBTRACT 1 FROM Help-Text-Column
		 MOVE Help-Text-Row TO PPB-Buffer-Offset
		 MULTIPLY 80 BY PPB-Buffer-Offset
		 ADD Help-Text-Column TO PPB-Buffer-Offset
		 PERFORM Scroll-Help-Text
	       END-IF

	     WHEN Shift-Cursor-Right
      *        Move right through the help text
	       IF Help-Text-Column < 32
		 MOVE PS-Scroll-Left TO PPB-Scroll-Direction
		 ADD 1 TO Help-Text-Column
		 MOVE Help-Text-Row TO PPB-Buffer-Offset
		 MULTIPLY 80 BY PPB-Buffer-Offset
		 ADD Help-Text-Column TO PPB-Buffer-Offset
		 ADD 47 TO PPB-Buffer-Offset
		 PERFORM Scroll-Help-Text
	       END-IF

	     WHEN Shift-Cursor-Up
      *        Move up through the help text
	       IF Help-Text-Row > 0
		 MOVE PS-Scroll-Down TO PPB-Scroll-Direction
		 SUBTRACT 1 FROM Help-Text-Row
		 MOVE Help-Text-Row TO PPB-Buffer-Offset
		 MULTIPLY 80 BY PPB-Buffer-Offset
		 ADD Help-Text-Column TO PPB-Buffer-Offset
		 PERFORM Scroll-Help-Text
	       END-IF

	     WHEN Shift-Cursor-Down
      *        Move down through the help text
	       IF Help-Text-Row < 32
		 MOVE PS-Scroll-Up TO PPB-Scroll-Direction
		 ADD 1 TO Help-Text-Row
		 MOVE Help-Text-Row TO PPB-Buffer-Offset
		 ADD 10 TO PPB-Buffer-Offset
		 MULTIPLY 80 BY PPB-Buffer-Offset
		 ADD Help-Text-Column TO PPB-Buffer-Offset
		 PERFORM Scroll-Help-Text
	       END-IF

	     WHEN Esc-Key
      *        Exit.
	       GO TO Panels-Example-Exit

	   END-EVALUATE
	   GO TO Main-Loop.

      *-----------------------------------------------------------------
      *    Delete all panels before exiting.

       Panels-Example-Exit.
	   MOVE PF-Delete-Panel TO PPB-Function
	   MOVE Help-Panel-ID TO PPB-Panel-ID
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE Panel-A-ID TO PPB-Panel-ID
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE Panel-B-ID TO PPB-Panel-ID
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE Menu-Panel-ID TO PPB-Panel-ID
	   CALL "PANELS" USING Panels-Parameter-Block.
	   STOP RUN.

      /*****************************************************************
      *  Create, initialise and enable the panels used in this example.
      ******************************************************************

       Create-Panels SECTION.
      *    Create menu panel.
	   MOVE 80 TO PPB-Panel-Width
	   MOVE 3 TO PPB-Panel-Height
	   MOVE 80 TO PPB-Visible-Width
	   MOVE 3 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 0 TO PPB-Panel-Start-Column
	   MOVE Screen-Height TO PPB-Panel-Start-Row
	   SUBTRACT 4 FROM PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
      *    Save the ID of the panel
	   MOVE PPB-Panel-ID TO Menu-Panel-ID.

      *    Write the required text and attributes to the panel. It
      *    will not become visible on the screen until the panel is
      *    enabled.
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 80 TO PPB-Vertical-Stride
	   MOVE 240 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 80 TO PPB-Update-Width
	   MOVE 3 TO PPB-Update-Height
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Menu-Panel-Text
			       Menu-Panel-Attributes.

      *    Enable the panel so that the menu becomes visible
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Create panel A
	   MOVE 21 TO PPB-Panel-Width
	   MOVE 11 TO PPB-Panel-Height
	   MOVE 21 TO PPB-Visible-Width
	   MOVE 11 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 40 TO PPB-Panel-Start-Column
	   MOVE 6 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
      *    Save the ID of the panel
	   MOVE PPB-Panel-ID TO Panel-A-ID.

      *    Write the required text and attributes to the panel. It
      *    will not become visible on the screen until the panel is
      *    enabled.
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 21 TO PPB-Vertical-Stride
	   MOVE 231 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 21 TO PPB-Update-Width
	   MOVE 11 TO PPB-Update-Height
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Panel-A-Text
			       Panel-A-Attributes.

      *    Enable the panel so that the panel becomes visible
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Create panel B
	   MOVE 9 TO PPB-Panel-Width
	   MOVE 9 TO PPB-Panel-Height
	   MOVE 9 TO PPB-Visible-Width
	   MOVE 9 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 60 TO PPB-Panel-Start-Column
	   MOVE 8 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
      *    Save the ID of the panel
	   MOVE PPB-Panel-ID TO Panel-B-ID.

      *    Write the required text and attributes to the panel. It
      *    will not become visible on the screen until the panel is
      *    enabled.
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 9 TO PPB-Vertical-Stride
	   MOVE 81 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 9 TO PPB-Update-Width
	   MOVE 9 TO PPB-Update-Height
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Panel-B-Text
			       Panel-B-Attributes.

      *    Enable the panel so that the panel becomes visible
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Create the help panel
	   MOVE 50 TO PPB-Panel-Width
	   MOVE 15 TO PPB-Panel-Height
	   MOVE 50 TO PPB-Visible-Width
	   MOVE 15 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 0 TO PPB-Panel-Start-Column
	   MOVE 0 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE PPB-Panel-ID TO Help-Panel-ID

      *    Write out border and instructions.
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 50 TO PPB-Vertical-Stride
	   MOVE 750 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 50 TO PPB-Update-Width
	   MOVE 15 TO PPB-Update-Height
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Help-Background-Text
			       Help-Background-Attributes.

      *    Now write the first screen of help text to the panel.
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 80 TO PPB-Vertical-Stride
	   MOVE 528 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 1 TO PPB-Update-Start-Col
	   MOVE 1 TO PPB-Update-Start-Row
	   MOVE 48 TO PPB-Update-Width
	   MOVE 11 TO PPB-Update-Height
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Help-Screen-Text
			       Help-Screen-Attributes.

	   MOVE 0 TO Help-Text-Row.
	   MOVE 1 TO Help-Text-Column

      *    Enable the help panel
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      /*****************************************************************
      *  Position current panel back to it's initial position on the
      *  screen.
      ******************************************************************

       Back-To-Start-Position SECTION.
	   MOVE PPB-Panel-Width TO PPB-Visible-Width
	   MOVE PPB-Panel-Height TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   EVALUATE Current-Panel-ID
	     WHEN Menu-Panel-ID
	       MOVE 0 TO PPB-Panel-Start-Column
	       MOVE Screen-Height TO PPB-Panel-Start-Row
	       SUBTRACT 4 FROM PPB-Panel-Start-Row

	     WHEN Panel-A-ID
	       MOVE 40 TO PPB-Panel-Start-Column
	       MOVE 6 TO PPB-Panel-Start-Row

	     WHEN Panel-B-ID
	       MOVE 60 TO PPB-Panel-Start-Column
	       MOVE 8 TO PPB-Panel-Start-Row

	     WHEN Help-Panel-ID
	       MOVE 0 TO PPB-Panel-Start-Column
	       MOVE 0 TO PPB-Panel-Start-Row

	   END-EVALUATE
	   PERFORM Shift-Panel.

      ******************************************************************
      *  Shift the position on the screen of the panel. The parameters
      *  are expected to be correctly set up before this routine is
      *  called.
      ******************************************************************

       Shift-Panel SECTION.
	   MOVE PF-Shift-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      ******************************************************************
      *  Retrieve information about the panel specified in
      *  Current-Panel-ID
      ******************************************************************

       Get-Current-Panel-Info SECTION.
	   MOVE Current-Panel-ID TO PPB-Panel-ID
	   MOVE PF-Get-Panel-Info TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      /*****************************************************************
      *  Alter the 'Current Panel' Indicator on the status line and
      *  retrieve information about the current panel.
      ******************************************************************

       Alter-Status-Line SECTION.
      *    Set up status line indicator
	   EVALUATE Current-Panel-ID
	     WHEN Menu-Panel-ID MOVE "Menu" TO Status-ID
	     WHEN Panel-A-ID	MOVE "AÄÄÄ" TO Status-ID
	     WHEN Panel-B-ID	MOVE "BÄÄÄ" TO Status-ID
	     WHEN Help-Panel-ID MOVE "Help" TO Status-ID
	   END-EVALUATE
      *    Write indicator text to the status line in the menu panel
	   MOVE Menu-Panel-ID TO PPB-Panel-ID
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 18 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 50 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 18 TO PPB-Update-Width
	   MOVE 1 TO PPB-Update-Height
      *    Set up the update mask to write ONLY text to a region of the
      *    panel. The attributes in that area are unaffected.
	   MOVE X"11" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Current-Panel-Indicator.

      *    Retrieve information about the current panel.
	   PERFORM Get-Current-Panel-Info.

      /*****************************************************************
      *  Select a new panel for all following operations via a pop-up
      *  menu. The pop-up menu is of course handled by a panel.
      *
      *  The pop-up selection panel is only created when it is required
      *  and deleted once a selection has been made.
      *
      *  The principle ideas shown here can be used in the
      *  implementation of any pop-up menu.
      *
      ******************************************************************

       Select-New-Panel SECTION.
      *    Create the selection panel
	   MOVE 12 TO PPB-Panel-Width
	   MOVE 6 TO PPB-Panel-Height
	   MOVE 12 TO PPB-Visible-Width
	   MOVE 6 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 35 TO PPB-Panel-Start-Column
	   MOVE 6 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Write the required text and attributes to the panel.
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 80 TO PPB-Vertical-Stride
	   MOVE 72 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 12 TO PPB-Update-Width
	   MOVE 6 TO PPB-Update-Height
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Selection-Panel-Text
			       Selection-Panel-Attributes.

      *    Enable the selection panel so that the panel becomes visible
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *-----------------------------------------------------------------

      *    Determine the number of the current selection
	   EVALUATE Current-Panel-ID
	     WHEN Panel-A-ID	MOVE 1 TO Current-Selection
	     WHEN Panel-B-ID	MOVE 2 TO Current-Selection
	     WHEN Menu-Panel-ID MOVE 3 TO Current-Selection
	     WHEN Help-Panel-ID MOVE 4 TO Current-Selection
	   END-EVALUATE
      *    Now highlight the current selection
	   MOVE Current-Selection TO PPB-Update-Start-Row
	   MOVE X"0F" TO PPB-Fill-Attribute
	   PERFORM Alter-Attributes.

      *    Now use the up and down cursor keys to move up and down the
      *    selections and Return to select.

       Selection-Loop.
	   CALL Get-Character USING Char
	   IF Char NOT = X"0D" GO TO Selection-Loop.
	   EVALUATE Key-Table-Return-Byte
	     WHEN Return-Key
	       EVALUATE Current-Selection
		 WHEN 1 MOVE Panel-A-ID    TO Current-Panel-ID
		 WHEN 2 MOVE Panel-B-ID    TO Current-Panel-ID
		 WHEN 3 MOVE Menu-Panel-ID TO Current-Panel-ID
		 WHEN 4 MOVE Help-Panel-ID TO Current-Panel-ID
	       END-EVALUATE
	       GO TO Selection-Exit

	     WHEN Cursor-Up
	       IF Current-Selection > 1
      * 	 Remove highlighting from old selection
		 MOVE Current-Selection TO PPB-Update-Start-Row
		 MOVE X"06" TO PPB-Fill-Attribute
		 PERFORM Alter-Attributes
		 SUBTRACT 1 FROM Current-Selection
      * 	 Highlight new selection
		 MOVE Current-Selection TO PPB-Update-Start-Row
		 MOVE X"0F" TO PPB-Fill-Attribute
		 PERFORM Alter-Attributes
	       END-IF

	     WHEN Cursor-Down
	       IF Current-Selection < 4
      * 	 Remove highlighting from old selection
		 MOVE Current-Selection TO PPB-Update-Start-Row
		 MOVE X"06" TO PPB-Fill-Attribute
		 PERFORM Alter-Attributes
		 ADD 1 TO Current-Selection
      * 	 Highlight new selection
		 MOVE Current-Selection TO PPB-Update-Start-Row
		 MOVE X"0F" TO PPB-Fill-Attribute
		 PERFORM Alter-Attributes
	       END-IF

	     WHEN Esc-Key
      *        Exit without making new selection
	       GO TO Selection-Exit

	   END-EVALUATE
	   GO TO Selection-Loop.

      *-----------------------------------------------------------------

       Selection-Exit.
      *    Delete the selection panel
	   MOVE PF-Delete-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      ******************************************************************
      *  Alter the attributes associated with a particular line in the
      *  selection panel.
      *
      *  On entry to this section :
      *
      *    PPB-Update-Start-Row : Should be set to the line in the
      * 			  panel whose attributes are to be
      * 			  changed.
      *    PPB-Fill-Attribute	: The new attribute for the line.
      *
      *  This section shows an example of using the write function to
      *  fill an area of a panel with a particular attribute, but the
      *  text in that area is unchanged.
      *
      ******************************************************************

       Alter-Attributes SECTION.
	   MOVE 10 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 1 TO PPB-Update-Start-Col
	   MOVE 10 TO PPB-Update-Width
	   MOVE 1 TO PPB-Update-Height
      *    Set up mask to indicate that we are performing a fill
      *    attributes function and the screen is to be updated.
	   MOVE X"28" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      /*****************************************************************
      *  Scroll the help panel text.
      *
      *  The following parameters should be set by the calling routine :
      *
      *    PPB-Buffer-Offset	: The offset into the text buffer,
      * 			  i.e. where panels is to find the
      * 			  first character to write to the area
      * 			  that is vacated when the area of the
      * 			  panel is scrolled.
      *    PPB-Scroll-Direction : The direction in which the area in
      * 			  the panel is to be scrolled.
      *
      ******************************************************************

       Scroll-Help-Text SECTION.
      *    Note that the scroll function can only scroll a complete
      *    rectangle in a panel, so any value of PPB-Rectangle-Offset
      *    and PPB-Update-Count are ignored by PANELS. Therefore these
      *    values do not need to be set up.
	   MOVE Help-Panel-ID TO PPB-Panel-ID
	   MOVE 80 TO PPB-Vertical-Stride
	   MOVE 1 TO PPB-Update-Start-Col
	   MOVE 1 TO PPB-Update-Start-Row
	   MOVE 48 TO PPB-Update-Width
	   MOVE 11 TO PPB-Update-Height
	   MOVE 1 TO PPB-Scroll-Count
	   MOVE X"33" TO PPB-Update-Mask
	   MOVE PF-Scroll-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Help-Screen-Text
			       Help-Screen-Attributes.

      *    Retrieve information about the current panel.
	   PERFORM Get-Current-Panel-Info.

