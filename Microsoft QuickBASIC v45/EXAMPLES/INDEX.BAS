DEFINT A-Z

' Define the symbolic constants used globally in the program:
CONST FALSE = 0, TRUE = NOT FALSE

' Define a record structure for random-file records:
TYPE StockItem
   PartNumber  AS STRING * 6
   Description AS STRING * 20
   UnitPrice   AS SINGLE
   Quantity    AS INTEGER
END TYPE

' Define a record structure for each element of the index:
TYPE IndexType
   RecordNumber AS INTEGER
   PartNumber   AS STRING * 6
END TYPE

' Declare procedures that will be called:
DECLARE FUNCTION Filter$ (Prompt$)
DECLARE FUNCTION FindRecord% (PartNumber$, RecordVar AS StockItem)

DECLARE SUB AddRecord (RecordVar AS StockItem)
DECLARE SUB InputRecord (RecordVar AS StockItem)
DECLARE SUB PrintRecord (RecordVar AS StockItem)
DECLARE SUB SortIndex ()
DECLARE SUB ShowPartNumbers ()

' Define a buffer (using the StockItem type) and
' define & dimension the index array:
DIM StockRecord AS StockItem, Index(1 TO 100) AS IndexType

' Open the random-access file:
OPEN "STOCK.DAT" FOR RANDOM AS #1 LEN = LEN(StockRecord)

' Calculate number of records in the file:
NumberOfRecords = LOF(1) \ LEN(StockRecord)

' If there are records, read them and build the index:
IF NumberOfRecords <> 0 THEN
   FOR RecordNumber = 1 TO NumberOfRecords

      ' Read the data from a new record in the file:
      GET #1, RecordNumber, StockRecord

      ' Place part number and record number in index:
      Index(RecordNumber).RecordNumber = RecordNumber
      Index(RecordNumber).PartNumber = StockRecord.PartNumber
   NEXT

   SortIndex            ' Sort index in part-number order.
END IF

DO                      ' Main-menu loop.
   CLS
   PRINT "(A)dd records."
   PRINT "(L)ook up records."
   PRINT "(Q)uit program."
   PRINT
   LOCATE , , 1
   PRINT "Type your choice (A, L, or Q) here: ";

   ' Loop until user presses, A, L, or Q:
   DO
      Choice$ = UCASE$(INPUT$(1))
   LOOP WHILE INSTR("ALQ", Choice$) = 0

   ' Branch according to choice:
   SELECT CASE Choice$
      CASE "A"
         AddRecord StockRecord
      CASE "L"
         IF NumberOfRecords = 0 THEN
            PRINT : PRINT "No records in file yet. ";
            PRINT "Press any key to continue.";
            Pause$ = INPUT$(1)
         ELSE
            InputRecord StockRecord
         END IF
      CASE "Q"          ' End program
   END SELECT
LOOP UNTIL Choice$ = "Q"

CLOSE #1                ' All done, close file and end.
END
'
' ======================== ADDRECORD =========================
'  Adds records to the file from input typed at the keyboard.
' ============================================================
'
SUB AddRecord (RecordVar AS StockItem) STATIC
   SHARED Index() AS IndexType, NumberOfRecords
   DO
      CLS
      INPUT "Part Number: ", RecordVar.PartNumber
      INPUT "Description: ", RecordVar.Description
      RecordVar.UnitPrice = VAL(Filter$("Unit Price : "))
      RecordVar.Quantity = VAL(Filter$("Quantity   : "))

      NumberOfRecords = NumberOfRecords + 1

      PUT #1, NumberOfRecords, RecordVar

      Index(NumberOfRecords).RecordNumber = NumberOfRecords
      Index(NumberOfRecords).PartNumber = RecordVar.PartNumber
      PRINT : PRINT "Add another? ";
      OK$ = UCASE$(INPUT$(1))
   LOOP WHILE OK$ = "Y"

   SortIndex            ' Re-sort index file.
END SUB
'
' ========================= FILTER ===========================
'       Filters all non-numeric characters from a string
'       and returns the filtered string.
' ============================================================
'
FUNCTION Filter$ (Prompt$) STATIC
   ValTemp2$ = ""
   PRINT Prompt$;                    ' Print the prompt passed.
   INPUT "", ValTemp1$               ' Input a number as
                                     ' a string.
   StringLength = LEN(ValTemp1$)     ' Get the string's length.
   FOR I% = 1 TO StringLength        ' Go through the string,
      Char$ = MID$(ValTemp1$, I%, 1) ' one character at a time.

      ' Is the character a valid part of a number (i.e.,
      ' a digit or a decimal point)?  If yes, add it to
      ' the end of a new string:
      IF INSTR(".0123456789", Char$) > 0 THEN
         ValTemp2$ = ValTemp2$ + Char$

      ' Otherwise, check to see if it's a lowercase "l",
      ' since users used to typewriters may enter a one
      ' value that way:
      ELSEIF Char$ = "l" THEN
         ValTemp2$ = ValTemp2$ + "1" ' Change the "l" to a "1".
      END IF
   NEXT I%

   Filter$ = ValTemp2$           ' Return filtered string.

END FUNCTION
'
' ======================= FINDRECORD =========================
'     Uses a binary search to locate a record in the index.
' ============================================================
'
FUNCTION FindRecord% (Part$, RecordVar AS StockItem) STATIC
   SHARED Index() AS IndexType, NumberOfRecords

   ' Set top and bottom bounds of search:
   TopRecord = NumberOfRecords
   BottomRecord = 1

   ' Search until top of range is less than bottom:
   DO UNTIL (TopRecord < BottomRecord)

      ' Choose midpoint:
      Midpoint = (TopRecord + BottomRecord) \ 2

      ' Test to see if it's the one wanted (RTRIM$() trims
      ' trailing blanks from a fixed string):
      Test$ = RTRIM$(Index(Midpoint).PartNumber)

      ' If it is, exit loop:
      IF Test$ = Part$ THEN
         EXIT DO

      ' Otherwise, if what we're looking for is greater,
      ' move bottom up:
      ELSEIF Part$ > Test$ THEN
         BottomRecord = Midpoint + 1

      ' Otherwise, move the top down:
      ELSE
         TopRecord = Midpoint - 1
      END IF
   LOOP

   ' If part was found, get record from file using
   ' pointer in index and set FindRecord% to TRUE:
   IF Test$ = Part$ THEN
      GET #1, Index(Midpoint).RecordNumber, RecordVar
      FindRecord% = TRUE

   ' Otherwise, if part was not found, set FindRecord%
   ' to FALSE:
   ELSE
      FindRecord% = FALSE
   END IF
END FUNCTION
'
' ======================= INPUTRECORD ========================
'    First, INPUTRECORD calls SHOWPARTNUMBERS, which
'    prints a menu of part numbers on the top of the screen.
'    Next, INPUTRECORD prompts the user to enter a part
'    number. Finally, it calls the FINDRECORD and PRINTRECORD
'    procedures to find and print the given record.
' ============================================================
'
SUB InputRecord (RecordVar AS StockItem) STATIC
   CLS
   ShowPartNumbers      ' Call the ShowPartNumbers SUB.

   ' Print data from specified records on the bottom
   ' part of the screen:
   DO
      PRINT "Type a part number listed above ";
      INPUT "(or Q to quit) and press <ENTER>: ", Part$
      IF UCASE$(Part$) <> "Q" THEN
         IF FindRecord(Part$, RecordVar) THEN
            PrintRecord RecordVar
         ELSE
            PRINT "Part not found."
         END IF
      END IF
      PRINT STRING$(40, "_")
   LOOP WHILE UCASE$(Part$) <> "Q"

   VIEW PRINT   ' Restore the text viewport to entire screen.
END SUB
'
' ======================= PRINTRECORD ========================
'                Prints a record on the screen
' ============================================================
'
SUB PrintRecord (RecordVar AS StockItem) STATIC
   PRINT "Part Number: "; RecordVar.PartNumber
   PRINT "Description: "; RecordVar.Description
   PRINT USING "Unit Price :$$###.##"; RecordVar.UnitPrice
   PRINT "Quantity   :"; RecordVar.Quantity
END SUB
'
' ===================== SHOWPARTNUMBERS ======================
'  Prints an index of all the part numbers in the upper part
'  of the screen.
' ============================================================
'
SUB ShowPartNumbers STATIC
   SHARED Index() AS IndexType, NumberOfRecords

   CONST NUMCOLS = 8, COLWIDTH = 80 \ NUMCOLS

   ' At the top of the screen, print a menu indexing all
   ' the part numbers for records in the file.  This menu is
   ' printed in columns of equal length (except possibly the
   ' last column, which may be shorter than the others):
   ColumnLength = NumberOfRecords
   DO WHILE ColumnLength MOD NUMCOLS
      ColumnLength = ColumnLength + 1
   LOOP
   ColumnLength = ColumnLength \ NUMCOLS
   Column = 1
   RecordNumber = 1
   DO UNTIL RecordNumber > NumberOfRecords
      FOR Row = 1 TO ColumnLength
         LOCATE Row, Column
         PRINT Index(RecordNumber).PartNumber
         RecordNumber = RecordNumber + 1
         IF RecordNumber > NumberOfRecords THEN EXIT FOR
      NEXT Row
      Column = Column + COLWIDTH
   LOOP

   LOCATE ColumnLength + 1, 1
   PRINT STRING$(80, "_")       ' Print separator line.

   ' Scroll information about records below the part-number
   ' menu (this way, the part numbers are not erased):
   VIEW PRINT ColumnLength + 2 TO 24
END SUB
'
' ========================= SORTINDEX ========================
'                Sorts the index by part number
' ============================================================
'
SUB SortIndex STATIC
   SHARED Index() AS IndexType, NumberOfRecords

   ' Set comparison offset to half the number of records
   ' in index:
   Offset = NumberOfRecords \ 2

   ' Loop until offset gets to zero:
   DO WHILE Offset > 0
      Limit = NumberOfRecords - Offset
      DO

         ' Assume no switches at this offset:
         Switch = FALSE

         ' Compare elements and switch ones out of order:
         FOR I = 1 TO Limit
            IF Index(I).PartNumber > Index(I + Offset).PartNumber THEN
               SWAP Index(I), Index(I + Offset)
               Switch = I
            END IF
         NEXT I

         ' Sort on next pass only to where last
         ' switch was made:
         Limit = Switch
      LOOP WHILE Switch

      ' No switches at last offset, try one half as big:
      Offset = Offset \ 2
   LOOP
END SUB
