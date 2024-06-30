      ******************************************************************
      *  Panels Interface Details.
      *
      *  Copyright (c) Micro Focus 1987.
      *
      *  Panels should be called in one of the following forms :
      *
      *       CALL "PANELS" USING Parameter-Block.
      *
      *    or CALL "PANELS" USING Parameter-Block
      * 			  Text-Buffer.
      *
      *    or CALL "PANELS" USING Parameter-Block
      * 			  Text-Buffer
      * 			  Attribute-Buffer.
      *
      *  Note. If only attributes are being supplied a dummy second
      *  parameter in place of Text-Buffer must be supplied.
      *
      *  The attributes expected are standard IBM-PC attributes. See
      *  relevant IBM documentation for a description of these
      *  attributes.
      *
      *-----------------------------------------------------------------
      *  The required panels function is specified in PPB-Function. The
      *  functions supported by PANELS are as follows :
      *
      *  Function  Description.
      *  --------  ------------
      *     0	   Get Screen Backdrop. Returns the following :
      *
      * 	     PPB-Panel-Height	    = Height of screen.
      * 	     PPB-Visible-Height     = Height of screen.
      * 	     PPB-Panel-Width	    = Width of screen.
      * 	     PPB-Visible-Width	    = Width of screen.
      * 	     PPB-Panel-Start-Row    = 0
      * 	     PPB-Panel-Start-Column = 0
      * 	     PPB-First-Visible-Row  = 0
      * 	     PPB-First-Visible-Col  = 0
      * 	     PPB-Fill-Character     = Default backdrop character
      * 	     PPB-Fill-Attribute     = Default backdrop attribute
      *
      *-----------------------------------------------------------------
      *
      *     1	   Set screen backdrop character and attribute from
      * 	   PPB-Fill-Character and PPB-Fill-Attribute. The
      * 	   screen is NOT updated.
      *
      *-----------------------------------------------------------------
      *
      *     2	   Redraw Screen. The screen is redrawn. Areas with no
      * 	   panels enabled are set to the backdrop characters
      * 	   and attributes.
      *
      *-----------------------------------------------------------------
      *
      *     3	   Create Panel. The dimensions of the panel are set
      * 	   from the following parameters supplied by the
      * 	   calling program :
      *
      * 	     PPB-Panel-Height	    = Height of Panel.
      * 	     PPB-Panel-Width	    = Width of Panel.
      * 	     PPB-Visible-Height     = The height of the visible
      * 				      portion of the panel
      * 	     PPB-Visible-Width	    = The width of the visible
      * 				      portion of the panel.
      * 	     PPB-Panel-Start-Row    = The first row on the
      * 				      screen occupied by the
      * 				      panel (starting from 0).
      * 	     PPB-Panel-Start-Column = The first column on the
      * 				      screen occupied by the
      * 				      panel (starting from 0).
      * 	     PPB-First-Visible-Row  = The row in the panel that
      * 				      is displayed at row
      * 				      PPB-Panel-Start-Row on
      * 				      the screen (starting
      * 				      from 0)
      * 	     PPB-First-Visible-Col  = The column in the panel
      * 				      that is displayed at
      * 				      column PPB-Panel-Start-
      * 				      Column on the screen.
      * 				      (Starting from 0).
      *
      * 	   Once the panel has been created, the height and
      * 	   width of the panel CANNOT be changed. All other
      * 	   properties can be changed by using the shift panel
      * 	   function (4).
      *
      * 	   The visible portion of the panel is clipped to the
      * 	   screen size and filled with the current backdrop
      * 	   character and attribute. The panel is created
      * 	   disabled so it will not immediately appear on the
      * 	   screen.
      *
      * 	   The identifier for the panel is returned in
      * 	   PPB-Panel-ID.
      *
      *-----------------------------------------------------------------
      *
      *     4	   Shift Panel. This function allows the panel
      * 	   specified in PPB-Panel-ID to be shifted to a new
      * 	   position on the screen or the size and/or position
      * 	   in the panel of the visible portion to be changed.
      *
      * 	   The following parameters should be set to the
      * 	   required values by the calling program :
      *
      * 	     PPB-Visible-Height      PPB-Visible-Width
      * 	     PPB-Panel-Start-Row     PPB-Panel-Start-Column
      * 	     PPB-First-Visible-Row   PPB-First-Visible-Col
      *
      * 	   If the panel was disabled, it will remain disabled;
      * 	   if it was enabled then it will become enabled in the
      * 	   new position. It's order in the stack of panels will
      * 	   not be changed.
      *
      *-----------------------------------------------------------------
      *
      *     5	   Get Panel Information. The following parameters are
      * 	   returned set to the relevant values for the panel
      * 	   specified in PPB-Panel-ID.
      *
      * 	     PPB-Panel-Height	     PPB-Panel-Width
      * 	     PPB-Visible-Height      PPB-Visible-Width
      * 	     PPB-Panel-Start-Row     PPB-Panel-Start-Column
      * 	     PPB-First-Visible-Row   PPB-First-Visible-Col
      *
      *-----------------------------------------------------------------
      *
      *     6	   Delete Panel. The panel specified in PPB-Panel-ID is
      * 	   removed from the screen and all storage associated
      * 	   with it deleted.
      *
      *-----------------------------------------------------------------
      *
      *     7	   Enable Panel. The panel specified in PPB-Panel-ID is
      * 	   enabled. It will become the highest panel, i.e the
      * 	   visible portion of the panel will overlay any other
      * 	   panels at the same point on the screen.
      *
      *-----------------------------------------------------------------
      *
      *     8	   Disable Panel. The panel specified in PPB-Panel-ID is
      * 	   disabled, i.e the visible portion of the panel is
      * 	   removed from the screen and any panels previously
      * 	   overlaid by that panel become visible.
      *
      *-----------------------------------------------------------------
      *
      *  The remaining panel functions read, alter or display an area in
      *  the panel. These functions use the parameters in the
      *  PPB-Update-Group which have the following uses.
      *
      *    PPB-Update-Height	= The height of the rectangle to be
      * 			  updated
      *    PPB-Update-Width	= The width of the rectangle to be
      * 			  updated.
      *    PPB-Update-Start-Row = The first row in the panel to be
      * 			  updated (starting from 0).
      *    PPB-Update-Start-Col = The first column in the panel to be
      * 			  updated (starting from 0).
      *    PPB-Update-Count	= The number of characters in the
      * 			  rectangle to be actually updated.
      *    PPB-Rectangle-Offset = The offset in the rectangle specified
      * 			  of the first character to be updated.
      * 			  (Starting from 0).
      *
      *  The update parameters are clipped to the size of the panel.
      *
      *  Whether the screen is updated or not, the buffers that are
      *  affected and the source of the update information is specified
      *  in PPB-Update-Mask. This is a single byte where a value of 1 in
      *  the relevant bits indicates the following :
      *
      *  (Bit 7 = Most Significant, Bit 0 = Least Significant)
      *
      *    Bit	 Name			 Function
      *    ---	 ----			 --------
      *     7				 Unused
      *
      *     6				 Unused
      *
      *     5	 Transmit-Attributes	 Update attributes on screen.
      *
      *     4	 Transmit-Characters	 Update characters on screen.
      *
      *     3	 Fill-Attributes	 Fill internal attribute buffer
      * 				 from PPB-Fill-Attribute.
      *
      *     2	 Fill-Characters	 Fill internal character buffer
      * 				 from PPB-Fill-Character.
      *
      *     1	 Copy-Attributes	 Copy attributes from the buffer
      * 				 supplied by calling program
      * 				 (Attribute-Buffer) into the
      * 				 internal attribute buffer.
      *
      *     0	 Copy-Characters	 Copy characters from the buffer
      * 				 supplied by calling program
      * 				 (Text-Buffer) into the
      * 				 internal character buffer.
      *
      *  Fill-Attributes and Copy-Attributes are mutally exclusive.
      *  Fill-Characters and Copy-Characters are mutally exclusive.
      *  Any other combination of bits is allowed.
      *
      *  For functions that pass buffers to panels the following
      *  parameters should also be set by the calling program :
      *
      *    PPB-Buffer-Offset	= The offset from the start of the
      * 			  buffer to the first character or
      * 			  attribute to be read/written.
      * 			  (Starting from 1).
      *    PPB-Vertical-Stride	= The amount to be added to the start
      * 			  of one row in the buffer to the
      * 			  obtain the start of the next.
      *
      *-----------------------------------------------------------------
      *
      *     9	   Flush Panel. The area of the panel PPB-Panel-ID
      * 	   specified in the update group is flushed out to the
      * 	   screen. Characters and/or attributes will be
      * 	   displayed depending on the settings of the
      * 	   Transmit-Characters and Transmit-Attributes bits in
      * 	   the update mask.
      *
      *-----------------------------------------------------------------
      *
      *    10	   Scroll Panel. A rectangle is scrolled in panel
      * 	   PPB-Panel-ID as specified in the update group
      * 	   parameters. Characters and/or attributes are
      * 	   scrolled as specified in the update mask :
      *
      * 	     IF Fill-Characters is set, the text is scrolled
      * 	     and the vacated area filled with the characters in
      * 	     PPB-Fill-Character.
      *
      * 	     IF Fill-Attributes is set, the attributes are
      * 	     scrolled and the vacated area filled with the
      * 	     attribute in PPB-Fill-Attribute.
      *
      * 	     IF Copy-Characters is set, the text is scrolled
      * 	     and the vacated area filled with text from
      * 	     Text-Buffer.
      *
      * 	     IF Copy-Attributes is set, the attributes are
      * 	     scrolled and the vacated area filled with
      * 	     attributes from Attribute-Buffer.
      *
      * 	     If Transmit-Characters is set, the scroll of the
      * 	     text is shown on the screen.
      *
      * 	     If Transmit-Attributes is set, the scroll of the
      * 	     attributes is shown on the screen.
      *
      * 	   NOTE. The text and attributes CANNOT be scrolled
      * 	   independently of each other.
      *
      * 	   The direction and number of lines to scroll are
      * 	   specified by the following parameters :
      *
      * 	     PPB-Scroll-Count	  = Number of lines or columns
      * 				    to be scrolled.
      * 	     PPB-Scroll-Direction = The direction of the
      * 				    scroll. The values are :
      *
      * 				       0 = Scroll Up.
      * 				       1 = Scroll Down.
      * 				       2 = Scroll Left.
      * 				       3 = Scroll Right
      *
      * 	   NOTE. Only a complete rectangle can be scrolled so
      * 	   the values specified in PPB-Rectangle-Offset and
      * 	   PPB-Update-Count are ignored and the relevant values
      * 	   calculated by PANELS.
      *
      *-----------------------------------------------------------------
      *
      *    11	   Write to Panel. A rectangle within panel
      * 	   PPB-Panel-ID is written to, using the parameters in
      * 	   the update group. The bits in the update mask are
      * 	   used as follows :
      *
      * 	     If Fill-Characters is set, the rectangle is filled
      * 	     with the character specified in PPB-Fill-Character.
      *
      * 	     If Fill-Attributes is set, the rectangle is filled
      * 	     with the attribute specified in PPB-Fill-Attribute.
      *
      * 	     If Copy-Characters is set, the rectangle is filled
      * 	     with text from Text-Buffer.
      *
      * 	     If Copy-Attributes is set, the rectangle is filled
      * 	     with attributes from Attribute-Buffer.
      *
      * 	     If Transmit-Characters is set, the updated text is
      * 	     displayed on the screen.
      *
      * 	     If Transmit-Attributes is set, the updated
      * 	     attributes are displayed on the screen.
      *
      *-----------------------------------------------------------------
      *
      *    12	   Read panel. A rectangle within panel PPB-Panel-ID is
      * 	   read, using the parameters in the update group.
      *
      * 	     If Copy-Characters is set, the text in the
      * 	     rectangle is returned in Text-Buffer.
      *
      * 	     If Copy-Attributes is set, the attributes in the
      * 	     rectangle are returned in Attribute buffer.
      *
      * 	   All other bits in the update mask are ignored.
      *
      *-----------------------------------------------------------------
      *
      *    13	   Find the ID of a panel at a particular position on
      * 	   the screen.
      *
      * 	   The position should be passed to panels in
      * 	   PPB-Panel-Start-Column and PPB-Panel-Start-Row.
      * 	   (Starting from 0).
      *
      * 	   The function returns the ID of the panel (or the ID
      * 	   of the top panel if there is more than one) at the
      * 	   location on the screen specified. In addition, the
      * 	   details returned by function 5 (Get Panel Details)
      * 	   are returned.
      *
      * 	   If there is no panel enabled at the location
      * 	   specified, a value of 0 is returned in PPB-Panel-ID
      * 	   and no other parameters are altered.
      *
      *-----------------------------------------------------------------
      *
      *  Panel Error Codes (Returned in PPB-Status).
      *
      *  Error Code    Meaning
      *  ----------    -------
      *      0	       No Error Occurred. Function requested was
      * 	       successful.
      *
      *      1	       The panel required has not been created
      *
      *      2	       The panel id is outside the range of valid panel
      * 	       identifiers
      *
      *      3	       The update parameters supplied do not define an
      * 	       area that is inside the panel.
      *
      *      4	       The function number given in PPB-Function is not
      * 	       in the range 0 to 12.
      *
      *      5	       The user is trying to create too many panels. The
      * 	       maximum number of panels have already been
      * 	       created.
      *
      *      6	       The panel is too large. Either :
      *
      * 		 a) The user is attempting to create a panel
      * 		    that is too large, i.e :
      *
      * 		    PPB-Panel-Width * PPB-Panel-Height > 64K
      *
      * 		 b) The width of the panel is greater than the
      * 		    size of PANELS internal buffers.
      *
      *      7	       The value supplied in PPB-Scroll-Direction is not
      * 	       in the range 0 to 3.
      *
      *      8	       The user is trying to scroll too many rows or
      * 	       columns.
      *
      *      9	       PANELS cannot initialise.
      *
      ******************************************************************

      ******************************************************************
      *  Panels Parameter Block.
      ******************************************************************

       01 Panels-Parameter-Block.
	03 PPB-Function 	       PIC 9(2) COMP.
	03 PPB-Status		       PIC 9(2) COMP.
	03 PPB-Panel-ID 	       PIC 9(4) COMP.
	03 PPB-Panel-Width	       PIC 9(4) COMP.
	03 PPB-Panel-Height	       PIC 9(4) COMP.
	03 PPB-Visible-Width	       PIC 9(4) COMP.
	03 PPB-Visible-Height	       PIC 9(4) COMP.
	03 PPB-First-Visible-Col       PIC 9(4) COMP.
	03 PPB-First-Visible-Row       PIC 9(4) COMP.
	03 PPB-Panel-Start-Column      PIC 9(4) COMP.
	03 PPB-Panel-Start-Row	       PIC 9(4) COMP.
	03 PPB-Buffer-Offset	       PIC 9(4) COMP.
	03 PPB-Vertical-Stride	       PIC 9(4) COMP.
	03 PPB-Update-Group.
	 05 PPB-Update-Count	       PIC 9(4) COMP.
	 05 PPB-Rectangle-Offset       PIC 9(4) COMP.
	 05 PPB-Update-Start-Col       PIC 9(4) COMP.
	 05 PPB-Update-Start-Row       PIC 9(4) COMP.
	 05 PPB-Update-Width	       PIC 9(4) COMP.
	 05 PPB-Update-Height	       PIC 9(4) COMP.
	03 PPB-Fill.
	 05 PPB-Fill-Character	       PIC X.
	 05 PPB-Fill-Attribute	       PIC X.
	03 PPB-Update-Mask	       PIC X.
	03 PPB-Scroll-Direction        PIC 9(2) COMP.
	03 PPB-Scroll-Count	       PIC 9(4) COMP.

      *****************************************************************
      *  Values of PPB-Function.
      *****************************************************************

       78 PF-Get-Screen-Info	       VALUE 0.
       78 PF-Set-Screen-Backdrop       VALUE 1.
       78 PF-Redraw-Screen	       VALUE 2.
       78 PF-Create-Panel	       VALUE 3.
       78 PF-Shift-Panel	       VALUE 4.
       78 PF-Get-Panel-Info	       VALUE 5.
       78 PF-Delete-Panel	       VALUE 6.
       78 PF-Enable-Panel	       VALUE 7.
       78 PF-Disable-Panel	       VALUE 8.
       78 PF-Flush-Panel	       VALUE 9.
       78 PF-Scroll-Panel	       VALUE 10.
       78 PF-Write-Panel	       VALUE 11.
       78 PF-Read-Panel 	       VALUE 12.
       78 PF-Get-Panel-At-Position     VALUE 13.

      *****************************************************************
      *  Values of PPB-Scroll-Direction.
      *****************************************************************

       78 PS-Scroll-Up		       VALUE 0.
       78 PS-Scroll-Down	       VALUE 1.
       78 PS-Scroll-Left	       VALUE 2.
       78 PS-Scroll-Right	       VALUE 3.

      ******************************************************************
      *  Error Codes.
      ******************************************************************

       78 PE-No-Error		       VALUE 0.
       78 PE-Not-Created	       VALUE 1.
       78 PE-Invalid-ID 	       VALUE 2.
       78 PE-Invalid-Parameters        VALUE 3.
       78 PE-Invalid-Function	       VALUE 4.
       78 PE-No-Room-For-Panel	       VALUE 5.
       78 PE-Panel-Too-Large	       VALUE 6.
       78 PE-Invalid-Direction	       VALUE 7.
       78 PE-Invalid-Scroll-Count      VALUE 8.
       78 PE-Cannot-Initialise	       VALUE 9.

      ******************************************************************
      *  End of source file PANLINK.CPY.
      ******************************************************************
