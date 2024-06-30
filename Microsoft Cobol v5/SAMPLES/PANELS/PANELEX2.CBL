      $SET COMP NOALTER NOQUAL ANS85
      ******************************************************************
      *  This program is intended as both an example of the
      *  functionality provided by PANELS and how to use PANELS via the
      *  Panels Parameter Block.
      *
      *  Copyright (c) Micro Focus 1987.
      *
      ******************************************************************

       SPECIAL-NAMES.
	   CRT STATUS IS Key-Status
	   CURSOR IS Current-Cursor-Position.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      /*****************************************************************
      *  Run Time System routines used.
      *
      *  Adis (X"AF")	     : Call to the Accept/Display module.
      *
      * 		       Sub-functions used :
      * 			 1 : Set bit pairs.
      * 			26 : Get single character.
      * 			49 : Initialise for use with PANELS.
      * 			56 : Set Panel for Accept/Display.
      *
      *  Sound-Bell (X"E5")  : Ring the bell.
      *  Move-Cursor (X"E6") : Position Cursor.
      *  Unpack-Byte (X"F5") : Unpack a byte into an 8-byte data item.
      *
      ******************************************************************

       78 Adis				   VALUE X"AF".
       78 Unpack-Byte			   VALUE X"F5".
       78 Sound-Bell			   VALUE X"E5".
       78 Move-Cursor			   VALUE X"E6".

       01 Adis-Functions.
	03 AF-Set-Bit-Pairs		   PIC 9(2) COMP VALUE 1.
	03 AF-Set-Byte			   PIC 9(2) COMP VALUE 3.
	03 AF-Position-Cursor		   PIC 9(2) COMP VALUE 23.
	03 AF-Get-Character		   PIC 9(2) COMP VALUE 26.
	03 AF-Initialise-For-Panels	   PIC 9(2) COMP VALUE 49.
	03 AF-Set-Panel 		   PIC 9(2) COMP VALUE 56.

       01 Adis-Parameters.
	03 Turn-Off-Predisplay		   PIC X(4) VALUE X"00324C01".
	03 Turn-On-Predisplay		   PIC X(4) VALUE X"03324C01".
	03 Enable-Cursor-Keys		   PIC X(4) VALUE X"01320502".
	03 Disable-Cursor-Keys		   PIC X(4) VALUE X"02320502".
	03 Enable-Function-Keys 	   PIC X(4) VALUE X"01310005".
	03 Map-CR-To-Terminate		   PIC X(2) VALUE X"0200".
	03 Turn-Off-Adis-Messages	   PIC X(4) VALUE X"01322C01".
	03 Turn-Off-Indicators		   PIC X(4) VALUE X"03323803".
	03 Key-Status.
	 05 Key-Type			   PIC 9(2) COMP.
	 05 Key-Code			   PIC 9(2) COMP.
	 05 FILLER			   PIC 9(2) COMP.

      * Values returned in Key-Type
       78 Normal-Accept-Terminate	   VALUE 48.
       78 User-Function-Key		   VALUE 49.
       78 Adis-Key			   VALUE 50.

      * Values of Key-Code if Key-Type = User-Function-Key
       78 Escape-Key			   VALUE 0.
       78 F1-Key			   VALUE 1.
       78 F2-Key			   VALUE 2.
       78 F3-Key			   VALUE 3.
       78 F4-Key			   VALUE 4.

      * Values of Key-Code if Key-Type = Adis-Key
       78 Carriage-Return		   VALUE 0.
       78 Cursor-Left			   VALUE 3.
       78 Cursor-Right			   VALUE 4.
       78 Cursor-Up			   VALUE 5.
       78 Cursor-Down			   VALUE 6.

       01 Dummy 			   PIC X(2) VALUE X"FFFF".

      /*****************************************************************
      *  Work-Variables.
      *
      *  Temp...		 : General work variables
      *  Display-Position	 : Position at which to Accept/Display a
      * 			   field.
      *  Current-Cursor-	 : Used to return the cursor position
      *    Position		   from the Accept used to edit the
      * 			   text buffer.
      *  Menu-Bar-Panel-ID	 : Panel ID of the Menu Bar.
      *  Main-Pull-Down-Panel-ID : Panel ID of the main pull down
      * 			   panel.
      *  Menu-Item		 : Current selection on the menu bar.
      *  Hex-Work-Area		 : Work area for input and display of
      * 			   hex numbers.
      *  Pop-Up-Text-Start	 : The first element in the
      * 			   Prompt-Control-Table to be used for
      * 			   this panel.
      *  Pop-Up-Text-End	 : The last element in the
      * 			   Prompt-Control-Table to be used for
      * 			   this panel.
      *  Current-Parameter	 : Indicates which item in the pop-up
      * 			   panel we are currently dealing with.
      *  Saved-Current-Parameter : Used to backup Current-Parameter
      * 			   when the overlay panel is created.
      *  Escape-Flag		 : Flag set if the user wishes to
      * 			   escape from the program.
      *  Invalid-Char-Flag	 : Flag set if invalid character set
      * 			   during key entry.
      *  Execute-Flag		 : Flag set if F3 is pressed during
      * 			   alteration of the parameter block
      * 			   to force immediate execution of the
      * 			   user's function.
      *
      ******************************************************************

       01 Work-Variables.
	03 TempAB			   PIC 9(4) COMP.
	03 FILLER REDEFINES TempAB.
	 05 TempA			   PIC 9(2) COMP.
	 05 TempA-X REDEFINES TempA	   PIC X.
	 05 TempB			   PIC 9(2) COMP.
	03 TempAB-X REDEFINES TempAB	   PIC XX.
	03 TempCD			   PIC 9(4) COMP.
	03 FILLER REDEFINES TempCD.
	 05 TempC			   PIC 9(2) COMP.
	 05 TempD			   PIC 9(2) COMP.
       03 Display-Position.
	05 Display-Row			   PIC 9(2) COMP.
	05 Display-Column		   PIC 9(2) COMP.
       03 Current-Cursor-Position.
	05 Current-Cursor-Row		   PIC 99 VALUE 0.
	05 Current-Cursor-Column	   PIC 99 VALUE 0.
       03 Menu-Bar-Panel-ID		   PIC 9(4) COMP.
       03 Main-Pull-Down-Panel-ID	   PIC 9(4) COMP.
       03 Saved-Panel-ID		   PIC 9(4) COMP.
       03 Menu-Item			   PIC 9(2) COMP.
       03 Hex-Work-Area.
	05 Hex-Char-1			   PIC X.
	05 Hex-Char-1-Numeric REDEFINES Hex-Char-1 PIC 9(2) COMP.
	05 Hex-Char-2			   PIC X.
	05 Hex-Char-2-Numeric REDEFINES Hex-Char-2 PIC 9(2) COMP.
       03 Hex-Value			   PIC X.
       03 Hex-Value-Numeric REDEFINES Hex-Value PIC 9(2) COMP.
       03 Status-Byte			   PIC 9(2) COMP.
       03 Pop-Up-Text-Start		   PIC 9(2) COMP.
       03 Pop-Up-Text-End		   PIC 9(2) COMP.
       03 Current-Parameter		   PIC 9(2) COMP.
       03 Saved-Current-Parameter	   PIC 9(2) COMP.
       03 Escape-Flag			   PIC 9(2) COMP VALUE 0.
       03 Invalid-Char-Flag		   PIC 9(2) COMP.
       03 Execute-Flag			   PIC 9(2) COMP.
      /
       COPY "PANLINK.CPY".

      /*****************************************************************
      *  User's Panels Parameter Block.
      ******************************************************************

       01 User-Parameter-Block VALUE ALL X"00".
	03 UPB-Function 	       PIC 9(2) COMP.
	03 UPB-Status		       PIC 9(2) COMP.
	03 UPB-Panel-ID 	       PIC 9(4) COMP.
	03 UPB-Panel-Width	       PIC 9(4) COMP.
	03 UPB-Panel-Height	       PIC 9(4) COMP.
	03 UPB-Visible-Width	       PIC 9(4) COMP.
	03 UPB-Visible-Height	       PIC 9(4) COMP.
	03 UPB-First-Visible-Col       PIC 9(4) COMP.
	03 UPB-First-Visible-Row       PIC 9(4) COMP.
	03 UPB-Panel-Start-Column      PIC 9(4) COMP.
	03 UPB-Panel-Start-Row	       PIC 9(4) COMP.
	03 UPB-Buffer-Offset	       PIC 9(4) COMP.
	03 UPB-Vertical-Stride	       PIC 9(4) COMP.
	03 UPB-Update-Group.
	 05 UPB-Update-Count	       PIC 9(4) COMP.
	 05 UPB-Rectangle-Offset       PIC 9(4) COMP.
	 05 UPB-Update-Start-Col       PIC 9(4) COMP.
	 05 UPB-Update-Start-Row       PIC 9(4) COMP.
	 05 UPB-Update-Width	       PIC 9(4) COMP.
	 05 UPB-Update-Height	       PIC 9(4) COMP.
	03 UPB-Fill.
	 05 UPB-Fill-Character	       PIC X.
	 05 UPB-Fill-Attribute	       PIC X.
	03 UPB-Update-Mask	       PIC X.
	03 UPB-Scroll-Direction        PIC 9(2) COMP.
	03 UPB-Scroll-Count	       PIC 9(4) COMP.

      /
       COPY "DEMOMENU.CPY".
      /
       COPY "DEMOCONT.CPY".
      /
       COPY "DEMOMSG.CPY".
      /
       COPY "DEMOBUFF.CPY".
      /
       COPY "DEMOHELP.CPY".

      /*****************************************************************
      *  Screen Section.
      ******************************************************************

       SCREEN SECTION.

       01 Two-Digit-Prompt.
	03 LINE Display-Row COLUMN Display-Column.
	03 PIC Z9 USING TempA HIGHLIGHT FOREGROUND-COLOUR 3.

       01 Four-Digit-Prompt.
	03 LINE Display-Row COLUMN Display-Column.
	03 PIC ZZZ9 USING TempAB HIGHLIGHT FOREGROUND-COLOUR 3.

       01 Two-Digit-Hex.
	03 LINE Display-Row COLUMN Display-Column.
	03 PIC XX USING Hex-Work-Area HIGHLIGHT FOREGROUND-COLOUR 3.

       01 Single-Character.
	03 LINE Display-Row COLUMN Display-Column.
	03 PIC X USING TempA-X HIGHLIGHT FOREGROUND-COLOUR 3.

       01 Edit-Screen FOREGROUND-COLOUR 6.
	03 LINE 1 COLUMN 1.
	03 VALUE "É" HIGHLIGHT.
	03 PIC X(120) FROM Work-FIll-Line HIGHLIGHT.
	03 VALUE "»" HIGHLIGHT.
	03 OCCURS 35.
	 05 LINE + 1 COLUMN 1.
	 05 VALUE "º" HIGHLIGHT.
	 05 PIC X(120) USING Work-Line AUTO PROMPT " ".
	 05 VALUE "º" HIGHLIGHT.
	03 LINE + 1 COLUMN 1.
	03 VALUE "È" HIGHLIGHT.
	03 PIC X(120) FROM Work-FIll-Line HIGHLIGHT.
	03 VALUE "¼" HIGHLIGHT.

      /*****************************************************************
      *  Procedure Division.
      ******************************************************************

       PROCEDURE DIVISION.
       Main SECTION.
      *    First set up the Accept/Display (ADIS) module to work as we
      *    want.
      *
      *    Initialise ADIS for use with PANELS
	   CALL Adis Using AF-Initialise-For-Panels Dummy
      *    Turn off display of error messages by ADIS.
	   CALL Adis USING AF-Set-Bit-Pairs Turn-Off-Adis-Messages
      *    Turn off display of status indicators by ADIS.
	   CALL Adis USING AF-Set-Bit-Pairs Turn-Off-Indicators
      *    Set up the cursor keys to terminate an Accept.
	   CALL Adis USING AF-Set-Bit-Pairs Enable-Cursor-Keys
      *    Enable the function keys Esc, F1, F2, F3 and F4.
	   CALL Adis USING AF-Set-Bit-Pairs Enable-Function-Keys
      *    Ensure that the Return key will terminate an Accept. This is
      *    used in case the Return key has been mapped to another
      *    function in the configuration in use in the ADISCTRL file.
	   CALL Adis USING AF-Set-Byte Map-CR-To-Terminate.
	   PERFORM Create-Panels.
      *    Position at first item on menu bar (Help).
	   MOVE 1 TO Menu-Item.

	   PERFORM WITH TEST AFTER UNTIL Escape-Flag = 1
	     PERFORM Highlight-Menu
      *      Make cursor disappear
	     CALL Move-Cursor USING Dummy Dummy
	     PERFORM WITH TEST AFTER UNTIL Invalid-Char-Flag = 0
	       MOVE 0 TO Invalid-Char-Flag
	       CALL Adis USING AF-Get-Character Key-Status
	       EVALUATE Key-Type
		 WHEN Adis-Key
		   EVALUATE Key-Code
		     WHEN Cursor-Left
		       IF Menu-Item > 1
			 PERFORM Normal-Menu
			 SUBTRACT 1 FROM Menu-Item
		       ELSE
			 CALL Sound-Bell
		       END-IF

		     WHEN Cursor-Right
		       IF Menu-Item < 5
			 PERFORM Normal-Menu
			 ADD 1 TO Menu-Item
		       ELSE
			 CALL Sound-Bell
		       END-IF

		     WHEN Carriage-Return
		     WHEN Cursor-Down
		       PERFORM Execute-Function

		     WHEN OTHER
		       MOVE 1 TO Invalid-Char-Flag

		   END-EVALUATE

		 WHEN User-Function-Key
		   PERFORM Normal-Menu
		   EVALUATE Key-Code
		     WHEN Escape-Key MOVE 5 TO Menu-Item
		     WHEN F1-Key     MOVE 1 TO Menu-Item
		     WHEN F2-Key     MOVE 2 TO Menu-Item
		     WHEN F3-Key     MOVE 3 TO Menu-Item
		     WHEN F4-Key     MOVE 4 TO Menu-Item
		     WHEN OTHER      MOVE 1 TO Invalid-Char-Flag
		   END-EVALUATE
		   IF Invalid-Char-Flag = 0
		     PERFORM Highlight-Menu
		     PERFORM Execute-Function
		   END-IF

		 WHEN OTHER
		   MOVE 1 TO Invalid-Char-Flag

	       END-EVALUATE
	       IF Invalid-Char-Flag = 1
		 CALL Sound-Bell
	       END-IF
	     END-PERFORM
	   END-PERFORM.

      *    Delete the menu bar and main pull-down panels
	   MOVE Menu-Bar-Panel-ID TO PPB-Panel-ID
	   MOVE PF-Delete-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE Main-Pull-Down-Panel-ID TO PPB-Panel-ID
	   CALL "PANELS" USING Panels-Parameter-Block.
	   STOP RUN.

      /*****************************************************************
      *  Execute the required function specified by the position on
      *  Menu bar.
      *
      *  On entry :
      *
      *    Menu-Item : The number of the option on the menu bar.
      *
      ******************************************************************

       Execute-Function SECTION.
	   EVALUATE Menu-Item
	     WHEN 1
	       MOVE 1 TO Help-Output
	       PERFORM Display-Help-Screen

	     WHEN 2
	       PERFORM Alter-Parameter-Block
	       IF Execute-Flag = 1
		 PERFORM Execute-User-Function
	       END-IF

	     WHEN 3
	       PERFORM Execute-User-Function

	     WHEN 4
	       PERFORM Edit-Text-Buffer

	     WHEN 5
	       MOVE 1 TO Escape-Flag

	   END-EVALUATE.

      ******************************************************************
      *  Execute the user's required function.
      ******************************************************************

       Execute-User-Function SECTION.
	   CALL "PANELS" USING User-Parameter-Block
			       Text-Buffer
			       Attribute-Buffer
      *    Ensure that the menu bar is fully visible
	   MOVE Menu-Bar-Panel-ID TO PPB-Panel-ID
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
	   IF UPB-Status > 0
	     MOVE UPB-Status TO Message-Output
	   ELSE
	     MOVE M-Successful TO Message-Output
	   END-IF
	   PERFORM Display-Message.

      /*****************************************************************
      *  Create the menu bar panel and the main pull down panel.
      *
      *  Other panels used by this program are created as they are
      *  needed.
      ******************************************************************

       Create-Panels SECTION.
      *    Create menu bar
	   MOVE 80 TO PPB-Panel-Width
	   MOVE 1 TO PPB-Panel-Height
	   MOVE 80 TO PPB-Visible-Width
	   MOVE 1 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 0 TO PPB-Panel-Start-Column
	   MOVE 0 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
	   MOVE PPB-Panel-ID TO Menu-Bar-Panel-ID
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 80 TO PPB-Vertical-Stride
	   MOVE 80 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 80 TO PPB-Update-Width
	   MOVE 1 TO PPB-Update-Height
	   MOVE X"09" TO PPB-Update-Mask
	   MOVE X"70" TO PPB-Fill-Attribute
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block Menu-Bar-Text.
      *    Display menu bar
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Create main pull down panel
	   MOVE 49 TO PPB-Panel-Width
	   MOVE 12 TO PPB-Panel-Height
	   MOVE 49 TO PPB-Visible-Width
	   MOVE 12 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE Menu-Option-Start(2) TO PPB-Panel-Start-Column
	   MOVE 1 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
	   MOVE PPB-Panel-ID TO Main-Pull-Down-Panel-ID.

      *    Create demo panel A
	   MOVE 21 TO PPB-Panel-Width
	   MOVE 12 TO PPB-Panel-Height
	   MOVE 21 TO PPB-Visible-Width
	   MOVE 12 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 10 TO PPB-Panel-Start-Column
	   MOVE 5 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
	   MOVE PPB-Panel-ID TO Panel-A-ID

	   MOVE 21 TO PPB-Update-Width
	   MOVE 12 TO PPB-Update-Height
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 252 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 21 TO PPB-Vertical-Stride
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Panel-A-Text
			       Panel-A-Attributes

	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Create demo panel B
	   MOVE 15 TO PPB-Panel-Width
	   MOVE 10 TO PPB-Panel-Height
	   MOVE 15 TO PPB-Visible-Width
	   MOVE 10 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 50 TO PPB-Panel-Start-Column
	   MOVE 10 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
	   MOVE PPB-Panel-ID TO Panel-B-ID

	   MOVE 15 TO PPB-Update-Width
	   MOVE 10 TO PPB-Update-Height
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 150 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 15 TO PPB-Vertical-Stride
	   MOVE X"03" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Panel-B-Text
			       Panel-B-Attributes

	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      /*****************************************************************
      *  Reverse Menu Bar
      *
      *  Reverse the item on the menu bar specified by Menu-Item.
      *
      ******************************************************************

       Highlight-Menu SECTION.
	   MOVE X"0F" TO PPB-Fill-Attribute
	   PERFORM Alter-Menu-Attributes.

      ******************************************************************
      *  Normal Menu Bar
      *
      *  Return the item on the menu bar specified by Menu-Item to
      *  the base attribute.
      *
      ******************************************************************

       Normal-Menu SECTION.
	   MOVE X"78" TO PPB-Fill-Attribute
	   PERFORM Alter-Menu-Attributes.

      ******************************************************************
      *  Alter attributes for an item on the menu bar.
      *
      *  On entry :
      *
      *    Menu-Item	      = Number in Mneu-Bar-Control-Table of item
      * 			to be changed
      *    PPB-Fill-Attribute = Attribute required.
      *
      ******************************************************************

       Alter-Menu-Attributes SECTION.
	   MOVE Menu-Bar-Panel-ID TO PPB-Panel-ID
	   MOVE Menu-Option-Start(Menu-Item) TO PPB-Update-Start-Col
	   MOVE Menu-Option-Length(Menu-Item) TO PPB-Update-Width
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 1 TO PPB-Update-Height
	   MOVE PPB-Update-Width TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE X"28" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      /*****************************************************************
      *  Allow the user to alter their Panels parameter block.
      ******************************************************************

       Alter-Parameter-Block SECTION.
	   MOVE 0 TO Execute-Flag
      *    Initialise text for main pull down panel
	   MOVE UPB-Function TO MPD-Function
	   MOVE UPB-Status TO MPD-Status
	   MOVE UPB-Panel-ID TO MPD-Panel-ID
	   MOVE UPB-Fill-Character TO MPD-Fill-Character
	   MOVE UPB-Fill-Attribute TO Hex-Value
	   PERFORM Convert-Hex-To-ASCII
	   MOVE Hex-Work-Area TO MPD-Fill-Attribute
	   MOVE UPB-Update-Mask TO Hex-Value
	   PERFORM Convert-Hex-To-ASCII
	   MOVE Hex-Work-Area TO MPD-Update-Mask
	   MOVE UPB-Scroll-Direction TO MPD-Scroll-Direction
	   MOVE UPB-Scroll-Count TO MPD-Scroll-Count
      *    Write the text to the panel
	   MOVE Main-Pull-Down-Panel-ID TO PPB-Panel-ID
	   MOVE 49 TO PPB-Update-Width
	   MOVE 12 TO PPB-Update-Height
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 588 TO PPB-Update-Count
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 49 TO PPB-Vertical-Stride
	   MOVE X"03" TO PPB-Fill-Attribute
	   MOVE X"09" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Main-Pull-Down-Text
      *    Now display it.
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Inform ADIS to use this panel for Accepts and Displays
	   CALL Adis USING AF-Set-Panel Main-Pull-Down-Panel-ID.

	   MOVE 1 TO Pop-Up-Text-Start
	   MOVE 10 TO Pop-Up-Text-End
	   MOVE 0 TO Saved-Current-Parameter.
	   MOVE Pop-Up-Text-Start TO Current-Parameter.

       Pop-Up-Loop.
	   PERFORM WITH TEST AFTER UNTIL Escape-Flag = 1
      *      Highlight current item
	     MOVE X"0B" TO PPB-Fill-Attribute
	     PERFORM Alter-Pop-Up-Attributes
	     MOVE PPB-Update-Start-Row TO Display-Row
	     ADD 1 TO Display-Row
      *      Determine the action to be performed for the parameter we
      *      are currently positioned on
	     MOVE Control-Byte(Current-Parameter) TO TempC
	     MOVE Param-Block-Start(Current-Parameter) TO TempD
	     IF TempC = 4
	       PERFORM Create-Overlay-Panel
	     ELSE
	       EVALUATE TempC
		 WHEN 0
		   MOVE User-Parameter-Block(TempD : 1) TO TempA-X
		   MOVE 45 TO Display-Column
		   DISPLAY Two-Digit-Prompt
		   ACCEPT Two-Digit-Prompt
		   MOVE TempA-X TO User-Parameter-Block(TempD : 1)

		 WHEN 1
		   MOVE User-Parameter-Block(TempD : 2) TO TempAB-X
		   MOVE 43 TO Display-Column
		   DISPLAY Four-Digit-Prompt
		   ACCEPT Four-Digit-Prompt
		   MOVE TempAB-X TO User-Parameter-Block(TempD : 2)

		 WHEN 2
		   MOVE User-Parameter-Block(TempD : 1) TO Hex-Value
		   PERFORM Convert-Hex-To-ASCII
		   MOVE 45 TO Display-Column
		   MOVE 1 TO Status-Byte
		   PERFORM UNTIL Status-Byte = 0
		     DISPLAY Two-Digit-Hex
		     ACCEPT Two-Digit-Hex
		     PERFORM Convert-ASCII-To-Hex
		   END-PERFORM
		   MOVE Hex-Value TO User-Parameter-Block(TempD : 1)

		 WHEN 3
		   MOVE User-Parameter-Block(TempD : 1) TO TempA-X
		   MOVE 46 TO Display-Column
		   DISPLAY Single-Character
		   ACCEPT Single-Character
		   MOVE TempA-X TO User-Parameter-Block(TempD : 1)

	       END-EVALUATE
      *        Remove highlighting from the current line
	       MOVE X"03" TO PPB-Fill-Attribute
	       PERFORM Alter-Pop-Up-Attributes
	       IF Key-Type = User-Function-Key
		 EVALUATE Key-Code
		   WHEN Escape-Key
		   WHEN F3-Key
		     IF Saved-Current-Parameter > 0
		       PERFORM Remove-Overlay-Panel
		     END-IF
		     MOVE 1 TO Escape-Flag
		     IF Key-Code = F3-Key
		       MOVE 1 TO Execute-Flag
		     END-IF

		   WHEN F1-Key
		     MOVE Help-Screen(Current-Parameter) TO Help-Output
		     PERFORM Display-Help-Screen

		   WHEN F2-Key
		   WHEN F4-Key
		     CALL Sound-Bell

		 END-EVALUATE
	       ELSE
		 IF Key-Type = Adis-Key AND Key-Code = Cursor-Up
		   IF Current-Parameter = Pop-Up-Text-Start
		     IF Saved-Current-Parameter > 0
		       PERFORM Remove-Overlay-Panel
		       SUBTRACT 1 FROM Current-Parameter
		     ELSE
		       MOVE 1 TO Escape-Flag
		   ELSE
		     SUBTRACT 1 FROM Current-Parameter
		 ELSE
		   IF Current-Parameter = Pop-Up-Text-End
		     IF Saved-Current-Parameter > 0
		       PERFORM Remove-Overlay-Panel
		       ADD 1 TO Current-Parameter
		     ELSE
		       MOVE 1 TO Escape-Flag
		   ELSE
		     ADD 1 TO Current-Parameter
		   END-IF
		 END-IF
	       END-IF
	     END-IF
	   END-PERFORM

      *    Remove main pull down panel from display.
	   MOVE PF-Disable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
	   MOVE 0 TO Escape-Flag.

      /*****************************************************************
      *  Alter attributes for an item in the current pop-up panel
      *
      *  On entry :
      *    Current-Parameter  = Index into Prompt-Control-Table.
      *    PPB-Fill-Attribute = Attribute required.
      *
      ******************************************************************

       Alter-Pop-Up-Attributes SECTION.
	   MOVE Current-Parameter TO PPB-Update-Start-Row
	   SUBTRACT Pop-Up-Text-Start FROM PPB-Update-Start-Row
	   ADD 1 TO PPB-Update-Start-Row
	   MOVE 1 TO PPB-Update-Start-Col
	   MOVE 47 TO PPB-Update-Width
	   MOVE 1 TO PPB-Update-Height
	   MOVE 47 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE X"28" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      /*****************************************************************
      *  Create and display overlaying pop-up panel.
      *
      *  On entry : Current-Parameter = Main pop-up panel item this one
      * 				is to hang under.
      ******************************************************************

       Create-Overlay-Panel SECTION.
	   MOVE Current-Parameter TO Saved-Current-Parameter
	   MOVE 10 TO PPB-Panel-Height
	   MOVE 49 TO PPB-Panel-Width
	   MOVE 10 TO PPB-Visible-Height
	   MOVE 49 TO PPB-Visible-Width
	   MOVE Menu-Option-Start(2) TO PPB-Panel-Start-Column
	   ADD 5 TO PPB-Panel-Start-Column
	   MOVE Current-Parameter TO PPB-Panel-Start-Row
	   ADD 2 TO PPB-Panel-Start-Row
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Now write the relevant text to the panel
	   MOVE 49 TO PPB-Update-Width
	   MOVE 10 TO PPB-Update-Height
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE 490 TO PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 49 TO PPB-Vertical-Stride
	   MOVE X"03" TO PPB-Fill-Attribute
	   MOVE X"09" TO PPB-Update-Mask
	   MOVE PF-Write-Panel TO PPB-Function
	   IF Current-Parameter = 4
	     MOVE UPB-Panel-Width TO MPD-Panel-Width
	     MOVE UPB-Panel-Height TO MPD-Panel-Height
	     MOVE UPB-Visible-Width TO MPD-Visible-Width
	     MOVE UPB-Visible-Height TO MPD-Visible-Height
	     MOVE UPB-First-Visible-Col TO MPD-First-Visible-Col
	     MOVE UPB-First-Visible-Row TO MPD-First-Visible-Row
	     MOVE UPB-Panel-Start-Column TO MPD-Panel-Start-Column
	     MOVE UPB-Panel-Start-Row TO MPD-Panel-Start-Row
	     CALL "PANELS" USING Panels-Parameter-Block
				 Panel-Control-Group-Text
	     MOVE 11 TO Pop-Up-Text-Start
	     MOVE 18 TO Pop-Up-Text-End
	   ELSE
	     MOVE UPB-Buffer-Offset TO MPD-Buffer-Offset
	     MOVE UPB-Vertical-Stride TO MPD-Vertical-Stride
	     MOVE UPB-Update-Count TO MPD-Update-Count
	     MOVE UPB-Rectangle-Offset TO MPD-Rectangle-Offset
	     MOVE UPB-Update-Start-Col TO MPD-Update-Start-Col
	     MOVE UPB-Update-Start-Row TO MPD-Update-Start-Row
	     MOVE UPB-Update-Width TO MPD-Update-Width
	     MOVE UPB-Update-Height TO MPD-Update-Height
	     CALL "PANELS" USING Panels-Parameter-Block
				 Panel-Update-Group-Text
	     MOVE 19 TO Pop-Up-Text-Start
	     MOVE 26 TO Pop-Up-Text-End
	   END-IF

      *    Now display the overlay panel
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

      *    Inform Adis to use this Panel for Accepts/Displays
	   CALL Adis USING AF-Set-Panel PPB-Panel-ID.
	   MOVE Pop-Up-Text-Start TO Current-Parameter.

      /*****************************************************************
      *  Remove overlaying pop-up panel.
      ******************************************************************

       Remove-Overlay-Panel SECTION.
	   MOVE PF-Delete-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE Saved-Current-Parameter TO Current-Parameter
	   MOVE 0 TO Saved-Current-Parameter.
	   MOVE 1 TO Pop-Up-Text-Start
	   MOVE 10 TO Pop-Up-Text-End
	   MOVE Main-Pull-Down-Panel-ID TO PPB-Panel-ID
	   CALL Adis USING AF-Set-Panel Main-Pull-Down-Panel-ID
	   MOVE X"03" TO PPB-Fill-Attribute
	   PERFORM Alter-Pop-Up-Attributes.

      /
       COPY "DEMOMISC.CPY".

