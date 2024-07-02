DEFINT A-Z               ' Default variable type is integer

' Define a data type for the names of the months and the
' number of days in each:
TYPE MonthType
   Number AS INTEGER     ' Number of days in the month
   MName AS STRING * 9   ' Name of the month
END TYPE

' Declare procedures used:
DECLARE FUNCTION IsLeapYear% (N%)
DECLARE FUNCTION GetInput% (Prompt$, Row%, LowVal%, HighVal%)

DECLARE SUB PrintCalendar (Year%, Month%)
DECLARE SUB ComputeMonth (Year%, Month%, StartDay%, TotalDays%)

DIM MonthData(1 TO 12) AS MonthType

' Initialize month definitions from DATA statements below:
FOR I = 1 TO 12
   READ MonthData(I).MName, MonthData(I).Number
NEXT

' Main loop, repeat for as many months as desired:
DO

   CLS

   ' Get year and month as input:
   Year = GetInput("Year (1899 to 2099): ", 1, 1899, 2099)
   Month = GetInput("Month (1 to 12): ", 2, 1, 12)

   ' Print the calendar:
   PrintCalendar Year, Month

   ' Another Date?
   LOCATE 13, 1         ' Locate in 13th row, 1st column
   PRINT "New Date? ";  ' Keep cursor on same line
   LOCATE , , 1, 0, 13  ' Turn cursor on and make it one
                        ' character high
   Resp$ = INPUT$(1)    ' Wait for a key press
   PRINT Resp$          ' Print the key pressed

LOOP WHILE UCASE$(Resp$) = "Y"
END

' Data for the months of a year:
DATA January, 31, February, 28, March, 31
DATA April, 30, May, 31, June, 30, July, 31, August, 31
DATA September, 30, October, 31, November, 30, December, 31
'
' ====================== COMPUTEMONTH ========================
'     Computes the first day and the total days in a month.
' ============================================================
'
SUB ComputeMonth (Year, Month, StartDay, TotalDays) STATIC
   SHARED MonthData() AS MonthType
   CONST LEAP = 366 MOD 7
   CONST NORMAL = 365 MOD 7

   ' Calculate total number of days (NumDays) since 1/1/1899.

   ' Start with whole years:
   NumDays = 0
   FOR I = 1899 TO Year - 1
      IF IsLeapYear(I) THEN         ' If year is leap, add
         NumDays = NumDays + LEAP   ' 366 MOD 7.
      ELSE                          ' If normal year, add
         NumDays = NumDays + NORMAL ' 365 MOD 7.
      END IF
   NEXT

   ' Next, add in days from whole months:
   FOR I = 1 TO Month - 1
      NumDays = NumDays + MonthData(I).Number
   NEXT

   ' Set the number of days in the requested month:
   TotalDays = MonthData(Month).Number

   ' Compensate if requested year is a leap year:
   IF IsLeapYear(Year) THEN

      ' If after February, add one to total days:
      IF Month > 2 THEN
         NumDays = NumDays + 1

      ' If February, add one to the month's days:
      ELSEIF Month = 2 THEN
         TotalDays = TotalDays + 1

      END IF
   END IF

   ' 1/1/1899 was a Sunday, so calculating "NumDays MOD 7"
   ' gives the day of week (Sunday = 0, Monday = 1, Tuesday = 2,
   ' and so on) for the first day of the input month:
   StartDay = NumDays MOD 7
END SUB
'
' ======================== GETINPUT ==========================
'       Prompts for input, then tests for a valid range.
' ============================================================
'
FUNCTION GetInput (Prompt$, Row, LowVal, HighVal) STATIC

   ' Locate prompt at specified row, turn cursor on and
   ' make it one character high:
   LOCATE Row, 1, 1, 0, 13
   PRINT Prompt$;

   ' Save column position:
   Column = POS(0)

   ' Input value until it's within range:
   DO
      LOCATE Row, Column   ' Locate cursor at end of prompt
      PRINT SPACE$(10)     ' Erase anything already there
      LOCATE Row, Column   ' Relocate cursor at end of prompt
      INPUT "", Value      ' Input value with no prompt
   LOOP WHILE (Value < LowVal OR Value > HighVal)

   ' Return valid input as value of function:
   GetInput = Value

END FUNCTION
'
' ====================== ISLEAPYEAR ==========================
'         Determines if a year is a leap year or not.
' ============================================================
'
FUNCTION IsLeapYear (N) STATIC

   ' If the year is evenly divisible by 4 and not divisible
   ' by 100, or if the year is evenly divisible by 400, then
   ' it's a leap year:
   IsLeapYear = (N MOD 4 = 0 AND N MOD 100 <> 0) OR (N MOD 400 = 0)
END FUNCTION
'
' ===================== PRINTCALENDAR ========================
'     Prints a formatted calendar given the year and month.
' ============================================================
'
SUB PrintCalendar (Year, Month) STATIC
SHARED MonthData() AS MonthType

   ' Compute starting day (Su M Tu ...) and total days
   ' for the month:
   ComputeMonth Year, Month, StartDay, TotalDays
   CLS
   Header$ = RTRIM$(MonthData(Month).MName) + "," + STR$(Year)

   ' Calculates location for centering month and year:
   LeftMargin = (35 - LEN(Header$)) \ 2

   ' Print header:
   PRINT TAB(LeftMargin); Header$
   PRINT
   PRINT "Su    M   Tu    W   Th    F   Sa"
   PRINT

   ' Recalculate and print tab to the first day
   ' of the month (Su M Tu ...):
   LeftMargin = 5 * StartDay + 1
   PRINT TAB(LeftMargin);

   ' Print out the days of the month:
   FOR I = 1 TO TotalDays
      PRINT USING "##   "; I;

      ' Advance to the next line when the cursor
      ' is past column 32:
      IF POS(0) > 32 THEN PRINT
   NEXT

END SUB
