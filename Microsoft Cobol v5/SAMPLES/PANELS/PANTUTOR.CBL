      $set ans85
      *
      *
      * Program: PANELs Tutorial.
      * Written by: Micro Focus Technical Support Department.
      * Date written: 06/88.
      *
      *
      * Purpose: To demonstrate the use of some common PANELs routines.
      *
      * 	 The following functions will be demonstrated:
      *
      * 		  Function 2  - Redraw the screen
      * 		  Function 3  - Create a panel
      * 		  Function 4  - Move panel
      * 		  Function 6  - Delete panel
      * 		  Function 7  - Enable panel
      * 		  Function 10 - Scroll panel
      * 		  Function 11 - Write to a panel
      *
      * 	 In addition, use of ADIS displays and accepts with
      * 	  PANELs is demonstrated.
      *
      * Assumptions:
      * ------------
      *
      *  It is assumed (and required) that you have read the PANELs
      *   reference documentation.
      *
      * Overview:
      * ---------
      *
      *   1) Paragraph "110-enable-adis-for-panels".
      *      The very first thing the program will do is inform ADIS
      *      that we will be using PANELS. This is done via an X"AF"
      *      function call. In addition, this paragraph disables the
      *      ADIS error message panel and all of its indicators.
      *
      *   2) Paragraph "120-create-a-panel".
      *      The program creates 2 panels. One is used as a work panel
      *      and the other is used for displaying messages to the user.
      *
      *   3) Paragraph "130-write-1st-panel".
      *      The program will display a panel that is 11 characters
      *      wide by 7 rows. This panel is called the work panel or
      *      panel #1. In this panel, text is displayed in reverse
      *      video. The panel is displayed on screen line 2, column 5
      *      and would appear:
      *
      * 		 +-----------+
      * 		 |	     |
      * 		 |  THIS IS  |
      * 		 |	     |
      * 		 |     A     |
      * 		 |	     |
      * 		 |  T E S T  |
      * 		 |	     |
      * 		 +-----------+
      *
      *   4) Paragraph "140-enable-panel".
      *      Up to this point, all the text written to panel #1 is not
      *      visible on the screen because the panel is created
      *      disabled, ie, invisible. When it is enabled, it is made
      *      visible.
      *
      *   5) Paragraph "170-pause".
      *      The second panel is then displayed (panel #2). This panel
      *      occupies 1 screen line and is 80 characters wide. This
      *      panel is displayed on screen line 25. In this
      *      panel, we display messages like "Press return to
      *      continue".
      *
      *   6) Paragraph "170-pause".
      *      The program then issues an ACCEPT. This is just to make
      *      the program wait until the user is ready to continue. The
      *      user should hit RETURN to continue. The ACCEPT is done in
      *      the message panel (panel #2). This is one demonstration of
      *      using ACCEPT and PANELs togather.
      *
      *   7) Paragraph "150-move-panel".
      *      At this point, we issue a move panel function call to move
      *      panel #1 to screen line 10, column 8.
      *
      *   8) Paragraph "170-pause".
      *      We then make the program wait until the user is ready to
      *      continue. We repeat step #5 above.
      *
      *   9) Paragraph "160-update-the-panel".
      *      Then, we will write over one line of the panel. This new
      *      line will be printed in green text on a black background.
      *      The updated panel will look like:
      *
      * 		 +-----------+
      * 		 |	     |
      * 		 |  THIS IS  |
      * 		 |	     |
      * 		 |     A     |
      * 		 |	     |
      * 		 | * panel * | <--- in a different color
      * 		 |	     |
      * 		 +-----------+
      *
      *  10) Paragraph "170-pause".
      *      Program then pauses waiting for the user to hit return
      *      (see step #5).
      *
      *  11) Paragraph "180-clear-panel-1".
      *      The text in panel #1 (see above) is cleared via an ADIS
      *      'DISPLAY SPACES' statement.
      *
      *  12) Paragraph "190-accept-input-from-panel".
      *      We then issue an ADIS ACCEPT statement. We are accepting
      *      information within a panel. The user should fill the
      *      panel. Notice that when you reach the end of one line of
      *      the panel that the text wraps automatically to the next
      *      line of the panel.
      *
      *  13) Paragraph "170-pause".
      *      The program pauses until the user hits return (see step
      *      #5).
      *
      *  14) Paragraph "200-disable-panel".
      *      Panel #1 is disabled. It is made invisible. At this point,
      *      all the user sees is a blank screen.
      *
      *  15) Paragraph "220-display-accepted-info".
      *      We then display the information we just ACCEPTed. This is
      *      to show you that we did indeed retrieve the information.
      *
      *  16) Paragraph "170-pause".
      *      We pause the program again, as in step #5.
      *
      *  17) Paragraph "230-create-panel-2".
      *      We then create another panel. This panel is 3 characters
      *      wide and uses 2 screen lines. This panel is displayed at
      *      screen line 5, column 2.
      *
      *  18) Paragraph "240-write-panel-2".
      *      Then, text is written to this panel. The text written
      *      consists of "ABC" on the first line of the panel and
      *      "DEF" on the second line of the panel. At this time the
      *      text we write is not visible as the panel, when created,
      *      is automatically disabled.
      *
      *  19) Paragraph "250-enable-panel-2".
      *      We enable the panel, ie, make it visible on the screen.
      *
      *  20) Paragraph "170-pause".
      *      The program then pauses (see step #5).
      *
      *  21) Paragraph "260-scroll-panel-2".
      *      After the user hits return, the text in the panel is then
      *      scrolled up 3 characters. When we wrote to the panel in
      *      step #16, we provided a text buffer. The buffer contains
      *      the following:
      *
      *      ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
      *
      *      Our panel is 3 characters wide by 2 lines. We can display
      *      only 6 characters (3 X 2 = 6) at a time. When the user
      *      hits return, we will display the next 3 characters of the
      *      text buffer. Therefore, the first time the user hits
      *      return, they will see:
      *
      * 		    +---+
      * 		    |DEF|
      * 		    |GHI|
      * 		    +---+
      *
      *  22) Paragraph "260-scroll-panel-2" and "170-pause".
      *      Steps 20 and 21 are repeated until we reach the end of the
      *      text buffer. Therefore, everytime the user hits return,
      *      they will see 3 more characters of the buffer.
      *
      *  23) Paragraph "200-disable-panel" and "210-disable-msg-panel".
      *      At this point, we disable (make invisible) all the panels
      *      we have created and quit.
      *
      *
      /
       SPECIAL-NAMES.
	   console is crt.
      /
       WORKING-STORAGE section.
      *
      *  PANELS Parameter Block.
      *
       01 panels-parameter-block.
	03 ppb-function 	       pic 9(2) comp.
	03 ppb-status		       pic 9(2) comp.
	03 ppb-panel-id 	       pic 9(4) comp.
	03 ppb-panel-width	       pic 9(4) comp.
	03 ppb-panel-height	       pic 9(4) comp.
	03 ppb-visible-width	       pic 9(4) comp.
	03 ppb-visible-height	       pic 9(4) comp.
	03 ppb-first-visible-col       pic 9(4) comp.
	03 ppb-first-visible-row       pic 9(4) comp.
	03 ppb-panel-start-column      pic 9(4) comp.
	03 ppb-panel-start-row	       pic 9(4) comp.
	03 ppb-buffer-offset	       pic 9(4) comp.
	03 ppb-vertical-stride	       pic 9(4) comp.
	03 ppb-update-group.
	 05 ppb-update-count	       pic 9(4) comp.
	 05 ppb-rectangle-offset       pic 9(4) comp.
	 05 ppb-update-start-col       pic 9(4) comp.
	 05 ppb-update-start-row       pic 9(4) comp.
	 05 ppb-update-width	       pic 9(4) comp.
	 05 ppb-update-height	       pic 9(4) comp.
	03 ppb-fill.
	 05 ppb-fill-character	       pic x.
	 05 ppb-fill-attribute	       pic x.
	03 ppb-update-mask	       pic x.
	03 ppb-scroll-direction        pic 9(2) comp.
	03 ppb-scroll-count	       pic 9(4) comp.
      *
      *****************************************************************
      *
       01  ws-text-buffer.
	   05  filler		       pic x(11) value spaces.
	   05  filler		       pic x(11) value "  THIS IS  ".
	   05  filler		       pic x(11) value spaces.
	   05  filler		       pic x(11) value "     A	   ".
	   05  filler		       pic x(11) value spaces.
	   05  filler		       pic x(11) value "  T E S T  ".
	   05  filler		       pic x(11) value spaces.

       01  ws-attrib-buffer.
	   05  filler		       pic x(11) value all x"7c".
	   05  filler		       pic x(11) value all x"7c".
	   05  filler		       pic x(11) value all x"7c".
	   05  filler		       pic x(11) value all x"7c".
	   05  filler		       pic x(11) value all x"7c".
	   05  filler		       pic x(11) value all x"7c".
	   05  filler		       pic x(11) value all x"7c".

       01  ws-update-text.
	   05  filler		       pic x(11) value " * panel * ".

       01  ws-update-attrib	       pic x(11) value all x"0a".

       01  ws-text-buffer-2.
	   05  filler		       pic x(36) value
			   "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890".

       01  ws-attrib-buffer-2.
	   05  filler			   pic x(36) value all x"7c".

       01  ws-adis-panel-stuff.
	   05  ws-adis-panel-function	   pic 99 comp-x.
	   05  ws-adis-panel-dummy-param   pic x.
	   05  ws-adis-panel-turn-off-msgs pic x(4) value x"01322c01".
	   05  ws-adis-panel-turn-off-inds pic x(4) value x"03323803".
	   05  ws-adis-panel-set-panel	   pic 9(2) comp-x value 56.
	   05  ws-adis-panel-param	   pic 99   comp-x.

       01  ws-reply			   pic x.
       01  ws-input			   pic x(77).

       01  ws-save-panel-id		   pic 9(4) comp-x.
       01  ws-save-msg-panel-id 	   pic 9(4) comp-x.

       01  ws-panel-zero		   pic 9(4) comp-x value zeros.

       01  ws-last-line-buffer-offset	   pic 99 comp-x value zeros.

      /
      *****************************************************************
       PROCEDURE division.
      *****************************************************************
      *
       100-START.
	   perform 110-enable-adis-for-panels
	   perform 120-create-a-panel
	   perform 130-write-1st-panel
	   perform 140-enable-panel
	   perform 170-pause
	   perform 150-move-panel
	   perform 170-pause
	   perform 160-update-the-panel
	   perform 170-pause

	   perform 180-clear-panel-1
	   perform 190-accept-input-from-panel
	   perform 170-pause
	   perform 200-disable-panel
	   perform 220-display-accepted-info

	   perform 230-create-panel-2
	   perform 240-write-panel-2
	   perform 250-enable-panel-2
	   perform 170-pause

	   move 4 to ws-last-line-buffer-offset
      *
      * Scroll through the panel.
      *
	   perform 10 times
	       perform 260-scroll-panel-2
	       perform 170-pause
	   end-perform.

	   perform 200-disable-panel
	   perform 210-disable-msg-panel
	   stop run.
       100-exit.
	   exit.

      *****************************************************************
       110-ENABLE-ADIS-FOR-PANELS.
      *****************************************************************
	   continue
      *
      * Since we are going to be using ADIS ACCEPTS and DISPLAYS with
      *  PANELs, we must inform ADIS of this fact by using the
      *  following function call. As a result of this call, a full
      *  screen panel will be created (known as panel #0) and its panel
      *  identifier will always be 0. This panel will be refered to as
      *  the "ADIS panel". The screen will clear. The panel will be
      *  space filled and set to white text on a black background and
      *  the panel will be enabled. By default, all ACCEPT and DISPLAY
      *  statements will be directed to this panel, unless you specify
      *  otherwise (see paragraph 170-pause). This function call should
      *  only be done once at the beginning of your application.
      *
	   move 49 to ws-adis-panel-function
	   call x"af" using ws-adis-panel-function
			    ws-adis-panel-dummy-param
	   if ws-adis-panel-function = 255
	       display spaces
	       display "Initializing ADIS for panels failed" at 0101
	       display "Program is aborting"
	       stop run
	   end-if
      *
      * This call will turn off the ADIS indicators that normally print
      *  at the bottom of your screen.
      *
	   move 1 to ws-adis-panel-function
	   call x"af" using ws-adis-panel-function
			    ws-adis-panel-turn-off-inds
      *
      * This call will prevent ADIS error messages from printing on the
      *  bottom of your screen.
      *
	   call x"af" using ws-adis-panel-function
			    ws-adis-panel-turn-off-msgs.
       110-exit.
	   exit.

      *****************************************************************
       120-CREATE-A-PANEL.
      *****************************************************************
	   continue
      *
      * This call will 'redraw the screen'. The very first time the call
      *  is made it will clear the screen. The screen will be set to
      *  the default backdrop character (spaces) and attribute (white
      *  text on black background).
      *
	   move 2 to ppb-function
	   call "PANELS" using panels-parameter-block
	   if ppb-status not = zeros
	       display spaces
	       display "Error redrawing the screen" at 0101
	       go to 9999-panels-abort
	   end-if
      *
      * Create a panel that is 11 chars wide by 7 rows.
      *
	   move 11 to ppb-panel-width
	   move 7 to ppb-panel-height
      *
      * Window size is the same as the panel.
      *
	   move 11 to ppb-visible-width
           move 7 to ppb-visible-height
      *
      * Since window size = panel size, the window has no offset within
      *     the panel (0,0 is the top left of the panel).
      *
	   move 0 to ppb-first-visible-col
	   move 0 to ppb-first-visible-row
      *
      * We want the panel to start on line 2, col 5 of the screen
      *     (0,0 is the top of the screen).
      *
	   move 1 to ppb-panel-start-row
	   move 4 to ppb-panel-start-column
      *
      * Create the panel
      *
	   move 3 to ppb-function
	   call "PANELS" using panels-parameter-block
	   move ppb-panel-id to ws-save-panel-id
	   if ppb-status not = zeros
	       display spaces
	       display "Error creating the first panel" at 0101
	       go to 9999-panels-abort
	   end-if
      *
      *****************************************************************
      * Create the message panel
      *****************************************************************
      *
      * Create a panel that is 80 characters wide by 1 row
      *
	   move 80 to ppb-panel-width
	   move 1 to ppb-panel-height
      *
      * Window size is the same as the panel size
      *
	   move 80 to ppb-visible-width
	   move 1 to ppb-panel-height
      *
      * Since window size = panel size, the window has no offset within
      *     the panel (0,0 is the top left of the panel).
      *
	   move 0 to ppb-first-visible-col
	   move 0 to ppb-first-visible-row
      *
      * We want the window to start on line 25, col 1 of the screen
      *     (0,0 is the top left of the screen)
      *
	   move 24 to ppb-panel-start-row
	   move 0 to ppb-panel-start-column
      *
      * Create the panel. It will be disabled (ie not visible).
      *
	   move 3 to ppb-function
	   call "PANELS" using panels-parameter-block
	   move ppb-panel-id to ws-save-msg-panel-id.
	   if ppb-status not = zeros
	       display spaces
	       display "Error creating the message panel"
	       go to 9999-panels-abort
	   end-if.
       120-exit.
	   exit.

      ******************************************************************
       130-WRITE-1ST-PANEL.
      ******************************************************************
	   continue
      *
      * When we write to the panel, the text and attributes that we
      *  will write will come from a text and an attribute buffer.
      *  We want to start the write using the first character and the
      *  first attribute of the buffers.
      *
	   move 1 to ppb-buffer-offset
      *
      * In our window, one row is 11 characters wide.
      *  PPB-VERTICAL-STRIDE specifies the distance, in characters,
      *  between the start of one row in the text and attribute buffers
      *  and the start of the next row.
      *
	   move 11 to ppb-vertical-stride
      *
      * We want to write all the characters in the buffers (7 rows * 11
      *  characters per row) to the screen.
      *
	   move 77 to ppb-update-count
      *
      * We will define a "update window", ie, where in the panel to
      *  start writing. We want our "update window" to be as large as
      *  the panel.
      *
	   move 11 to ppb-update-width
	   move 7 to ppb-update-height
      *
      * When we write, we want to start the write in the first
      *  character position (relative to 0) within the "update window"
      *
	   move 0 to ppb-rectangle-offset
      *
      * Since our "update window" is the same size as our panel, there
      *     will be no offset of the "update window" within the panel.
      *
	   move 0 to ppb-update-start-row
	   move 0 to ppb-update-start-col
      *
      * When we move a hex 3 to PPB-UPDATE-MASK, we are telling panels:
      *
      * When we write, we want the to write from a text and an attribute
      *  buffer. The text we write will not be seen on screen (at least
      *  not at this time).
      *
      * Hex 3 is binary 0000 0011. If you examine the reference
      *  section, under "PPB-UPDATE-MASK", you will see that bits 0 and
      *  1 are set by moving a hex 3 to PPB-UPDATE-MASK.
      *
	   move x"03" to ppb-update-mask
      *
      * Write to the panel.
      *
	   move 11 to ppb-function
	   move ws-save-panel-id to ppb-panel-id
	   call "PANELS" using panels-parameter-block
			       ws-text-buffer
			       ws-attrib-buffer
	   if ppb-status not = zeros
	       display spaces
	       display "Error on first write to a panel" at 0101
	       go to 9999-panels-abort
	   end-if.
       130-exit.
	   exit.

      *****************************************************************
       140-ENABLE-PANEL.
      *****************************************************************
	   continue
      *
      * This PANELs call will make the text we just wrote be visible.
      *
	   move 7 to ppb-function
	   move ws-save-panel-id to ppb-panel-id
	   call "PANELS" using panels-parameter-block
	   if ppb-status not = zeros
	       display spaces
	       display "error in enabling the first panel" at 0101
	       go to 9999-panels-abort
	   end-if.
       140-exit.
	   exit.

      *****************************************************************
       150-MOVE-PANEL.
      *****************************************************************
	   continue
      *
      * We want to move our panel from screen line 2, column 5 to
      *  screen line 10, column 8.
      *
      * Since our window size is the same size as the panel, there is
      *     no offset of the window within the panel.
      *
	   move 0 to ppb-first-visible-col
	   move 0 to ppb-first-visible-row
      *
      * Our window size is the same size as the panel (11 cols X
      *     7 rows).
      *
	   move 7 to ppb-visible-height
	   move 11 to ppb-visible-width
      *
      * We want to move the panel to screen line 10, column 8 (remember,
      *      0,0 is the top left corner of the screen
      *
	   move 9 to ppb-panel-start-row
	   move 7 to ppb-panel-start-column
      *
      * Move the panel
      *
	   move 4 to ppb-function
	   move ws-save-panel-id to ppb-panel-id
	   call "PANELS" using panels-parameter-block
	   if ppb-status not = zeros
	       display spaces
	       display "Error moving the first panel" at 0101
	       go to 9999-panels-abort
	   end-if.
       150-exit.
	   exit.

      *****************************************************************
       160-UPDATE-THE-PANEL.
      *****************************************************************
	   continue
      *
      * We want to update the 6th line of the panel to read:
      *     " * panel * " in green text on a black background.
      *
      * We have defined an entirely new buffer for this update. When we
      *  write, we start with the first character in the text and
      *  attribute buffers.
      *
	   move 1 to ppb-buffer-offset
      *
      * One row in the buffer is 11 characters wide.
      *
	   move 11 to ppb-vertical-stride
      *
      * We want to use all the characters in the buffer when we write.
      *
	   move 11 to ppb-update-count
      *
      * When we update the screen, we need to update only one screen
      *     line with 11 characters.
      *
	   move 1 to ppb-update-height
	   move 11 to ppb-update-width
      *
      * When we start writing, we want to write to the first character
      *  of our window, relative to 0.
      *
	   move 0 to ppb-rectangle-offset
      *
      * We only need to update one line of the panel (screen line 6),
      *  starting with the first character of the panel. 0,0 is the
      *  first character position of the first line of the panel.
      *  Therefore, to update panel line 6, column 1 we need to move 5
      *  to PPB-UPDATE-START-ROW and 0 to PPB-UPDATE-START-COL.
      *
	   move 5 to ppb-update-start-row
	   move 0 to ppb-update-start-col
      *
      * When we write, we want the changes to be visible immediately,
      *  and we want our changes to originate from text and attribute
      *  buffers.
      *
      * Hex 33 is 0011 0011 in binary, therefore bits 5, 4, 1 and 0 are
      *  set. If you examine the documentation, you will see that when
      *  you set bits 1 and 0, this instructs panels to use text and
      *  attribute buffers as the source of the the update and setting
      *  bits 5 and 4 tell panels to make the changes visible on the
      *  screen immediately.
      *
	   move x"33" to ppb-update-mask
      *
      * WRITE TO THE PANEL
      *
	   move 11 to ppb-function
	   move ws-save-panel-id to ppb-panel-id
	   call "PANELS" using panels-parameter-block
			       ws-update-text
			       ws-update-attrib
	   if ppb-status not = zeros
	       display spaces
	       display "Error updating panel #1" at 0101
	       go to 9999-panels-abort
	   end-if.
       160-exit.
	   exit.

      *****************************************************************
       170-PAUSE.
      *****************************************************************
	   continue
      *
      * Pause program execution until the user hits return.
      *
      * This call tells PANELs that all following ACCEPTS and DISPLAYS
      *  should go to the panel identifier specified, the message
      *  panel.
      *

	   call x"af" using ws-adis-panel-set-panel
			    ws-save-msg-panel-id
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS set panel failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
	   move spaces to ws-reply
	   display "PRESS RETURN TO CONTINUE" with
	       foreground-color 3
	       background-color 1
	       at 0101
	   accept ws-reply at 0178
	   display spaces with
	       foreground-color 7
	       background-color 0
	       at 0101.
       170-exit.
	   exit.

      *****************************************************************
       180-CLEAR-PANEL-1.
      *****************************************************************
	   continue
      *
      * This paragraph will clear all the text from panel #1
      *
      * Tell ADIS which panel to use (panel #1) when we clear the panel
      *
	   call x"af" using ws-adis-panel-set-panel
			    ws-save-panel-id
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS set panel failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
      *
      * Tell ADIS that screen writes are to be seen immediately
      *
	   move 57 to ws-adis-panel-function
	   move 0 to ws-adis-panel-param
	   call x"af" using ws-adis-panel-function
			    ws-adis-panel-param
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS disable delayed updates failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
      *
      * Clear the panel
      *
	   display spaces at 0101.
       180-exit.
	   exit.

      *****************************************************************
       190-ACCEPT-INPUT-FROM-PANEL.
      *****************************************************************
	   continue
      *
      * Here, we demonstrate how to use an ADIS ACCEPT statement to
      *  accept input from a panel
      *
      * Write a prompt at the bottom of the screen asking the user to
      *    provide input
      *
      * Tell ADIS that when we write, write to the message panel
      *
	   call x"af" using ws-adis-panel-set-panel
			    ws-save-msg-panel-id
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS set panel failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
	   move spaces to ws-reply
	   display "Enter text into the panel" at 0101
      *
      * Accept data into our panel
      *
      * Tell ADIS which panel (panel #1) to use
      *
	   call x"af" using ws-adis-panel-set-panel
			    ws-save-panel-id
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS set panel failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
      *
      * Accept the input. Note that '0101' refers to the first line and
      *  column of the panel, not the first line and column of the
      *  screen.
      *
	   move spaces to ws-input
	   accept ws-input at 0101
      *
      * Clear message panel
      *
      * Tell ADIS that when we write, write into the message panel
      *
	   call x"af" using ws-adis-panel-set-panel
			    ws-save-msg-panel-id
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS set panel failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
	   display spaces with
	       foreground-color 7
	       background-color 0
	       at 0101.
       190-exit.
	   exit.

      *****************************************************************
       200-DISABLE-PANEL.
      *****************************************************************
	   continue
      *
      * Disable panel #1 (i.e., make the panel invisible)
      *
	   move ws-save-panel-id to ppb-panel-id
	   move 8 to ppb-function
	   call "PANELS" using panels-parameter-block.
       200-exit.
	   exit.

      *****************************************************************
       210-DISABLE-MSG-PANEL.
      *****************************************************************
	   continue
      *
      * Disable (make invisible) the message panel (on line 25)
      *
	   move ws-save-msg-panel-id to ppb-panel-id
	   move 8 to ppb-function
	   call "PANELS" using panels-parameter-block.
       210-exit.
	   exit.

      *****************************************************************
       220-DISPLAY-ACCEPTED-INFO.
      *****************************************************************
	   continue
      *
      * This section of code displays the information the user input to
      *  panel #1.
      *
      * Use the ADIS default panel (panel #0) to display on
      *
	   call x"af" using ws-adis-panel-set-panel
			    ws-panel-zero
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS set panel failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
      *
      * Tell ADIS that when we display, make the text visible
      *  immediately
      *
	   move 57 to ws-adis-panel-function
	   move 0 to ws-adis-panel-param
	   call x"af" using ws-adis-panel-function
			    ws-adis-panel-param
	   if ws-adis-panel-function = 255
	       display spaces
	       display "ADIS disable delayed update failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
      *
      * Display the information that we accepted
      *
	   display "This is what you input to the panel" at 0101
	   display ws-input at 0301
	   perform 170-pause
      *
      * Clear the screen
      *
      * Use the ADIS default panel (panel zero) to display on.
      *
	   call x"af" using ws-adis-panel-set-panel
			    ws-panel-zero
	   if ws-adis-panel-set-panel = 255
	       display spaces
	       display "ADIS set panel failure" at 0101
	       display "ABORTING" at 0201
	       stop run
	   end-if
      *
      * Clear the screen
      *
	   display spaces at 0101.
       220-exit.
	   exit.

      *****************************************************************
       230-CREATE-PANEL-2.
      *****************************************************************
	   continue
      *
      * Create a panel that is 3 chars wide by 2 rows. Window into the
      *  panel will be the same. This panel will start on screen line 2
      *  , column 5.
      *
      * Panel size is 3 characters by 2 rows
      *
	   move 3 to ppb-panel-width
	   move 2 to ppb-panel-height
      *
      * Window size is the same as the panel size
      *
	   move 3 to ppb-visible-width
	   move 2 to ppb-panel-height
      *
      * Since window size = panel size, the window has no offset within
      *  the panel (0,0 is the top left of the panel).
      *
	   move 0 to ppb-first-visible-col
	   move 0 to ppb-first-visible-row
      *
      * We want the window to start on line 2, col 5 of the screen
      *  where (0,0 is the top left corner of the screen).
      *
	   move 1 to ppb-panel-start-row
	   move 4 to ppb-panel-start-column
      *
      * Create the panel.
      *
	   move 3 to ppb-function
	   call "PANELS" using panels-parameter-block
	   move ppb-panel-id to ws-save-panel-id.
	   if ppb-status not = zeros
	       display spaces
	       display "Error creating panel #2" at 0101
	       go to 9999-panels-abort
	   end-if.
       230-exit.
	   exit.

      ******************************************************************
       240-WRITE-PANEL-2.
      ******************************************************************
	   continue
      *
      * This paragraph will write text to the newly created panel.
      *
      * Start writing using the first character of the text/attribute
      *  buffers.
      *
	   move 1 to ppb-buffer-offset
      *
      * One row in the panel is 3 characters.
      *
	   move 3 to ppb-vertical-stride
      *
      * We want to write all characters in the buffer to the
      *  screen (3 characters per line times 2 lines).
      *
	   move 6 to ppb-update-count
      *
      * We want the text that we are writing to start in the first
      *  character position (relative to 0) of the visible window.
      *
	   move 0 to ppb-rectangle-offset
      *
      * Define the visible window in the panel. It will be the same
      *  size as the panel.
      *
	   move 3 to ppb-update-width
	   move 2 to ppb-update-height
      *
      * Since our window is the same size as our panel, there will be
      *  no offset of the window within the panel (0,0 is the top left
      *  of the panel).
      *
	   move 0 to ppb-update-start-row
	   move 0 to ppb-update-start-col
      *
      * When we write, we want to use text and attribute
      *  buffers. Further, we don't want the text that we write to be
      *  immediately visible (we must ENABLE the panel before the text
      *  will be visible).
      *
      * Hex 3 is binary 0000 0011. If you examine the reference
      *  section, under "PPB-UPDATE-MASK", you will see that bits 0 and
      *  1 are set by moving a hex 3 to PPB-UPDATE-MASK.
      *
	   move x"03" to ppb-update-mask
      *
      * Write to the panel. The text we wrote will not be visible until
      *  we enable the panel.
      *
	   move 11 to ppb-function
	   move ws-save-panel-id to ppb-panel-id
	   call "PANELS" using panels-parameter-block
			       ws-text-buffer-2
			       ws-attrib-buffer-2.
	   if ppb-status not = zeros
	       display spaces
	       display "Error on second write to a panel" at 0101
	       go to 9999-panels-abort
	   end-if.
       240-exit.
	   exit.

      *****************************************************************
       250-ENABLE-PANEL-2.
      *****************************************************************
	   continue
      *
      * Make the text we just wrote to the panel visible.
      *
	   move 7 to ppb-function
	   move ws-save-panel-id to ppb-panel-id
	   call "PANELS" using panels-parameter-block
	   if ppb-status not = zeros
	       display spaces
	       display "Error enabling the second panel" at 0101
	       go to 9999-panels-abort
	   end-if.
       250-exit.
	   exit.

      *****************************************************************
       260-SCROLL-PANEL-2.
      *****************************************************************
	   continue
      *
      * Scroll the text up one line
      *
      * Currently, we have the following buffer characters on screen:
      *
      * 	    A B C  (Buffer characters 1 2 3)
      * 	    D E F  (Buffer characters 4 5 6)
      *
      *     When the scroll is done, we want to see:
      *
      * 	    D E F  (Buffer characters 4 5 6)
      * 	    G H I  (Buffer characters 7 8 9)
      *
      * Visible window size is 3 characters by 2 lines
      *
	   move 2 to ppb-visible-height
	   move 3 to ppb-visible-width
      *
      * We want to update the entire visible window
      *
	   move 3 to ppb-update-width
	   move 2 to ppb-update-height
      *
      * Since the visible window size is the same size as our panel,
      *  the window has no offset within the panel.
      *
	   move 0 to ppb-update-start-row
	   move 0 to ppb-update-start-col
      *
      * One line in the window is 3 characters wide.
      *
	   move 3 to ppb-vertical-stride
      *
      * For the first scroll:
      *
      * Prior the the first scroll, lines 1 and 2 of the buffer are
      *  onscreen. Buffer characters 1-3 comprise the first line on the
      *  screen and buffer characters 4-6 comprise the second screen
      *  line. When the first scroll is done, we want to see buffer
      *  characters 4-6 on the first screen line and buffer characters
      *  7-9 on the second screen line.
      *
      * The field PPB-BUFFER-OFFSET points to the first character in
      *  the buffers that will update the area of the screen vacated by
      *  the scroll. When we scroll up one line, the second line of the
      *  will be vacated. We want this vacated line to be filled from
      *  the buffer, starting with the 7th character.
      *
      * The first time through, ws-last-line-buffer-offset = 4.
      *
	   add 3 to ws-last-line-buffer-offset
	   move ws-last-line-buffer-offset to ppb-buffer-offset
      *
      * Scroll the text up
      *
	   move 0 to ppb-scroll-direction
      *
      * We want to scroll up one line
      *
	   move 1 to ppb-scroll-count
      *
      * When we scroll, we want the text to originate from text and
      *  attribute buffers. Further, we want the changes to be
      *  immediately visible on the screen.
      *
      * Hex 33 is 0011 0011 in binary, therefore bits 5, 4, 1 and 0 are
      *  set. If you examine the documentation, you will see that when
      *  you set bits 1 and 0, this instructs PANELS to use text and
      *  attribute buffers as the source of the the update and setting
      *  bits 5 and 4 tell PANELS to make the changes visible on the
      *  screen immediately.
      *
	   move x"33" to ppb-update-mask
      *
      * Scroll the panel
      *
	   move 10 to ppb-function
	   move ws-save-panel-id to ppb-panel-id
	   call "PANELS" using panels-parameter-block
			       ws-text-buffer-2
			       ws-attrib-buffer-2
	   if ppb-status not = zeros
	       display spaces
	       display "Scroll panel error" at 0101
	       go to 9999-panels-abort
	   end-if.
       260-exit.
	   exit.

      *****************************************************************
       9999-PANELS-ABORT.
      *****************************************************************
	   continue
      *
      * We have a panels error. Abort the program.
      *
	   display "Status returned = " ppb-status at 0201
	   display "Program is aborting" at 0301
	   stop run.
       9999-exit.
	   exit.
