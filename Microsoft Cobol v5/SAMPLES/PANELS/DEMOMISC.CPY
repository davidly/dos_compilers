      ******************************************************************
      *  Misc. routines used by the PANELS demonstration program.
      *
      *  Copyright (c) Micro Focus 1987.
      *
      ******************************************************************

      ******************************************************************
      *  Convert ASCII to Hex
      *
      *  Checks an entered ASCII Hex value for validity and if valid
      *  converts it to one byte.
      *
      *  On entry : Hex-Work-Area = Entered value to be converted.
      *
      *  On exit  : Hex-Value	  = Converted value.
      * 	    Status-Byte   = 0 if entered value is OK
      * 			    1 if invalid value entered
      *
      *  Work	  : TempA
      *
      ******************************************************************

       Convert-ASCII-to-Hex SECTION.
	   MOVE 0 TO Status-Byte
	   MOVE Hex-Char-1 TO TempA-X
	   PERFORM Convert-Hex-Digit
	   IF Status-Byte = 0
	     MOVE TempA TO Hex-Value-Numeric
	     MULTIPLY 16 BY Hex-Value-Numeric
	     MOVE Hex-Char-2 TO TempA-X
	     PERFORM Convert-Hex-Digit
	     IF Status-Byte = 0
	       ADD TempA TO Hex-Value-Numeric.
	   IF Status-Byte = 1
	     MOVE M-Invalid-Hex TO Message-Output
	     PERFORM Display-Message.

       Convert-Hex-Digit SECTION.
	   IF TempA-X NOT < "a" AND TempA-X NOT > "f"
	     SUBTRACT 87 FROM TempA
	   ELSE
	     IF TempA-X NOT < "A" AND TempA-X NOT > "F"
	       SUBTRACT 55 FROM TempA
	     ELSE
	       IF TempA-X NOT < "0" AND TempA-X NOT > "9"
		 SUBTRACT 48 FROM TempA
	       ELSE
		 MOVE 1 TO Status-Byte.

      ******************************************************************
      *  Convert Hex to ASCII
      *
      *  Converts a hex byte into a two byte displayable item.
      *
      *  On entry : Hex-Value	  = Byte to be converted.
      *
      *  On exit  : Hex-Work-Area = Converted value.
      *
      *  Work	  : TempA, Hex-Value is destroyed.
      *
      ******************************************************************

       Convert-Hex-to-ASCII SECTION.
	   MOVE Hex-Value-Numeric TO TempA
	   DIVIDE 16 INTO TempA
	   MOVE TempA TO Hex-Char-1-Numeric
	   IF TempA < 10
	     ADD 48 TO Hex-Char-1-Numeric
	   ELSE
	     ADD 55 TO Hex-Char-1-Numeric.
	   MULTIPLY 16 BY TempA
	   SUBTRACT TempA FROM Hex-Value-Numeric
	   MOVE Hex-Value TO Hex-Char-2
	   IF Hex-Char-2-Numeric < 10
	     ADD 48 TO Hex-Char-2-Numeric
	   ELSE
	     ADD 55 TO Hex-Char-2-Numeric.

      /*****************************************************************
      *  Display a message.
      *
      *  On entry : Message-Output = Number of message to be output.
      *
      *  Work	  : TempA.
      *
      ******************************************************************

       Display-Message SECTION.
	   MOVE PPB-Panel-ID TO Saved-Panel-ID
	   MOVE Message-Output TO TempA
	   MOVE Message-Start-Offset(TempA) TO PPB-Buffer-Offset
	   ADD 1 TO TempA
	   MOVE Message-Start-Offset(TempA) TO PPB-Panel-Width
	   SUBTRACT PPB-Buffer-Offset FROM PPB-Panel-Width
	   MOVE SPACES TO Message-Text-Area
	   MOVE CF-Message-Texts(PPB-Buffer-Offset : PPB-Panel-Width)
	     TO Message-Text-Area(1 : PPB-Panel-Width).
	   IF PPB-Panel-Width < 25 MOVE 25 TO PPB-Panel-Width.
	   ADD 1 TO PPB-Panel-Width
	   MOVE ALL "Í" TO Message-Text-Top-Bar
	   MOVE ALL "Í" TO Message-Text-Bottom-Bar
	   MOVE ALL SPACES TO Message-Text-Second-Line
	   MOVE ALL SPACES TO Message-Text-Prompt-End
	   MOVE "»" TO Message-Text-Top-Bar(PPB-Panel-Width : 1)
	   MOVE "º" TO Message-Text-Area(PPB-Panel-Width : 1)
	   MOVE "º" TO Message-Text-Second-Line(PPB-Panel-Width : 1)
	   MOVE "º" TO Message-Text-Prompt(PPB-Panel-Width : 1)
	   MOVE "¼" TO Message-Text-Bottom-Bar(PPB-Panel-Width : 1)
	   ADD 1 TO PPB-Panel-Width
	   MOVE 5 TO PPB-Panel-Height
	   MOVE 80 TO PPB-Panel-Start-Column
	   SUBTRACT PPB-Panel-Width FROM PPB-Panel-Start-Column
	   DIVIDE 2 INTO PPB-Panel-Start-Column
	   MOVE 15 TO PPB-Panel-Start-Row
	   MOVE PPB-Panel-Width TO PPB-Visible-Width
	   MOVE PPB-Panel-Height TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
	   MOVE 1 TO PPB-Buffer-Offset
	   MOVE 80 TO PPB-Vertical-Stride
	   MOVE PPB-Panel-Width TO PPB-Update-Count
	   MULTIPLY PPB-Panel-Height BY PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE PPB-Panel-Width TO PPB-Update-Width
	   MOVE 5 TO PPB-Update-Height
	   MOVE X"09" TO PPB-Update-Mask
	   MOVE X"0C" TO PPB-Fill-Attribute
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Message-Panel-Text.
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   CALL Move-Cursor USING Dummy Dummy
	   CALL Adis USING AF-Get-Character Key-Status
	   MOVE PF-Delete-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE Saved-Panel-ID TO PPB-Panel-ID.

      /*****************************************************************
      *  Display Help screen.
      *
      *  On entry : Help-Output = Number of help screen to be output.
      *
      ******************************************************************

       Display-Help-Screen SECTION.
	   MOVE PPB-Panel-ID TO Saved-Panel-ID
	   MOVE Help-Width(Help-Output) TO PPB-Panel-Width
	   MOVE Help-Height(Help-Output) TO PPB-Panel-Height
	   MOVE PPB-Panel-Width TO PPB-Visible-Width
	   MOVE PPB-Panel-Height TO PPB-Visible-Height
	   MOVE 1 TO PPB-Panel-Start-Row
	   MOVE 0 TO PPB-Panel-Start-Column
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE PPB-Panel-Width TO PPB-Update-Width
	   MOVE PPB-Panel-Height TO PPB-Update-Height
	   MOVE 0 TO PPB-Update-Start-Col
	   MOVE 0 TO PPB-Update-Start-Row
	   MOVE PPB-Update-Width TO PPB-Update-Count
	   MULTIPLY PPB-Update-Height BY PPB-Update-Count
	   MOVE 0 TO PPB-Rectangle-Offset
	   MOVE 80 TO PPB-Vertical-Stride
	   MOVE X"39" TO PPB-Update-Mask
	   MOVE X"06" TO PPB-Fill-Attribute.

       Help-Write-Text.
	   MOVE Help-Start(Help-Output) TO PPB-Buffer-Offset
	   MOVE PF-Write-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block
			       Help-Text.
	   MOVE PF-Enable-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   CALL Move-Cursor USING Dummy Dummy.

       Help-Wait-For-Key.
	   CALL Adis USING AF-Get-Character Key-Status
	   IF Key-Type NOT = User-Function-Key OR
	      Key-Code NOT = Escape-Key
	     IF Help-Next(Help-Output) = 0
	       CALL Sound-Bell
	       GO TO Help-Wait-For-Key
	     ELSE
	       MOVE Help-Next(Help-Output) TO Help-Output
	       GO TO Help-Write-Text.
	   MOVE PF-Delete-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
	   MOVE Saved-Panel-ID TO PPB-Panel-ID.

      /*****************************************************************
      *  Edit the text buffer
      ******************************************************************

       Edit-Text-Buffer SECTION.
      *    Create panel for text buffer
	   MOVE 122 TO PPB-Panel-Width
	   MOVE 37 TO PPB-Panel-Height
	   MOVE 80 TO PPB-Visible-Width
	   MOVE 24 TO PPB-Visible-Height
	   MOVE 0 TO PPB-First-Visible-Col
	   MOVE 0 TO PPB-First-Visible-Row
	   MOVE 0 TO PPB-Panel-Start-Column
	   MOVE 1 TO PPB-Panel-Start-Row
	   MOVE PF-Create-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.
      *    Set up this panel to be Accepted from.
	   CALL Adis USING AF-Set-Panel PPB-Panel-ID
	   MOVE Text-Buffer TO Work-Text-Buffer
      *    Display the buffer in the panel. Note that the panel is not
      *    yet enabled. The action of doing the Accept will cause the
      *    panel to be enabled.
	   DISPLAY Edit-Screen
      *    Set up cursor up and own to do their normal action during an
      *    Accept
	   CALL Adis USING AF-Set-Bit-Pairs Disable-Cursor-Keys.
      *    Turn off pre-display of fields during the Accept to improve
      *    performance. They have already been displayed, so need to
      *    pre-display them.
	   CALL Adis USING AF-Set-Bit-Pairs Turn-Off-Predisplay
	   MOVE 1 TO Current-Cursor-Row
	   MOVE 1 TO Current-Cursor-Column
      *    Accept new contents of text buffer
	   PERFORM WITH TEST AFTER
		   UNTIL Key-Type NOT = User-Function-Key
	     ACCEPT Edit-Screen
	     IF Key-Type NOT = User-Function-Key
	       MOVE Work-Text-Buffer TO Text-Buffer
	     ELSE
	       EVALUATE Key-Code
		 WHEN Escape-Key
		   MOVE Normal-Accept-Terminate TO Key-Type

		 WHEN F1-Key
		   MOVE 27 TO Help-Output
		   PERFORM Display-Help-Screen
		   MOVE User-Function-Key TO Key-Type

		 WHEN F2-Key
		 WHEN F3-Key
		 WHEN F4-Key
		   CALL Sound-Bell

	       END-EVALUATE
	     END-IF
	   END-PERFORM

	   MOVE 0 TO Current-Cursor-Row
	   MOVE 0 TO Current-Cursor-Column
      *    Set cursor up and down keys to act as function keys again.
	   CALL Adis USING AF-Set-Bit-Pairs Enable-Cursor-Keys.
	   CALL Adis USING AF-Set-Bit-Pairs Turn-On-Predisplay
      *    Now delete the panel
	   MOVE PF-Delete-Panel TO PPB-Function
	   CALL "PANELS" USING Panels-Parameter-Block.

