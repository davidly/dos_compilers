      ******************************************************************
      *  Messages displayed by PANELEX2.
      *
      *  Copyright (c) Micro Focus 1987.
      *
      ******************************************************************

      ******************************************************************
      *  Message-Output = Number of message to be displayed.
      ******************************************************************

       01 Message-Output	       PIC 9(2) COMP.

      ******************************************************************
      *  Message Texts.
      *
      *  This table contains the messages, etc that will be output on
      *  the last line of the screen.
      *
      *-----------------------------------------------------------------
      *  To add a message to this table :
      *
      *  a) Increment Max-Error. This must be set to the number of last
      *     error message in the table.
      *
      *  b) Add the new entry just before the level 78 item A-Err-End
      *     Each entry consists of :
      *
      *     78 M-xxxx	       VALUE Number to be associated with the
      * 			     message.
      *     78 A-xxxx	       VALUE NEXT - A-Messages-Start.
      * 			     (This gives the offset from the
      * 			     start of the table).
      *     03 FILLER	       PIC X(n) VALUE "Message text".
      *
      *  c) Add entry to Message-Control-Table just before the dummy
      *     entry at the end.
      *
      ******************************************************************

       78 Max-Error		   VALUE 10.

       01 CF-Message-Texts.

       78 A-Messages-Start	   VALUE NEXT - 1.

	78 M-Not-Created	   VALUE 1.
	78 A-Not-Created	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(44) VALUE
	   "Error - That panel has not been created yet.".

	78 M-Invalid-ID 	   VALUE 2.
	78 A-Invalid-ID 	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(33) VALUE
	   "Error - That panel ID is invalid.".

	78 M-Invalid-Update	   VALUE 3.
	78 A-Invalid-Update	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(62) VALUE
	   "Error - The parameters do not define an area inside the pane
      -    "l.".

	78 M-Invalid-Function	   VALUE 4.
	78 A-Invalid-Function	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(59) VALUE
	  "Error - Panel function numbers must be in the range 0 to 13".

	78 M-Too-Many-Panels	   VALUE 5.
	78 A-Too-Many-Panels	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(48) VALUE
	  "Error - You are trying to create too many panels".

	78 M-Too-Large		   VALUE 6.
	78 A-Too-Large		   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(58) VALUE
	   "Error - You are trying to create a panel that is too large".

	78 M-Invalid-Direction	   VALUE 7.
	78 A-Invalid-Direction	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(56) VALUE
	   "Error - The scroll direction must be in the range 0 to 3".

	78 M-Scroll-Too-Big	   VALUE 8.
	78 A-Scroll-Too-Big	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(57) VALUE
	   "Error - You are trying to scroll too many rows or columns".

	78 M-Invalid-Hex	   VALUE 9.
	78 A-Invalid-Hex	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(41) VALUE
	   "Invalid hexadecimal number. Please retry.".

	78 M-Successful 	   VALUE 10.
	78 A-Successful 	   VALUE NEXT - A-Messages-Start.
	03 FILLER		   PIC X(31) VALUE
	   "Function executed successfully.".

       78 A-Err-End		   VALUE NEXT - A-Messages-Start.

      /*****************************************************************
      *  Message control table.
      *
      *  This table is used to control access to the message texts
      *  above. There is an entry in the table for each possible output
      *  message.
      *
      *  Each entry consists of the offset into the table of the start
      *  of the message. The size of the message is calculated by
      *  subtracting this offset from the offset to the next message.
      *
      ******************************************************************

       78 Message-Table-Size	   VALUE Max-Error + 1.

       01 Message-Control-Table.
	03 FILLER	       PIC 9(4) COMP VALUE A-Not-Created.
	03 FILLER	       PIC 9(4) COMP VALUE A-Invalid-ID.
	03 FILLER	       PIC 9(4) COMP VALUE A-Invalid-Update.
	03 FILLER	       PIC 9(4) COMP VALUE A-Invalid-Function.
	03 FILLER	       PIC 9(4) COMP VALUE A-Too-Many-Panels.
	03 FILLER	       PIC 9(4) COMP VALUE A-Too-Large.
	03 FILLER	       PIC 9(4) COMP VALUE A-Invalid-Direction.
	03 FILLER	       PIC 9(4) COMP VALUE A-Scroll-Too-Big.
	03 FILLER	       PIC 9(4) COMP VALUE A-Invalid-Hex.
	03 FILLER	       PIC 9(4) COMP VALUE A-Successful.
      * Dummy entry at end of table
	03 FILLER	       PIC 9(4) COMP VALUE A-Err-End.
       01 FILLER REDEFINES Message-Control-Table.
	03 Message-Start-Offset    PIC 9(4) COMP
				   OCCURS Message-Table-Size.

