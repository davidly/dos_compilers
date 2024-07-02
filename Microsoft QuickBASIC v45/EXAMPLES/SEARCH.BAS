DEFLNG A-Z              ' Default variable type is long integer.
LINE INPUT "File to search: ", FileName$
LINE INPUT "Pattern to search for: ", Pattern$
OPEN FileName$ FOR BINARY AS #1

CONST PACKETSIZE = 10000, TRUE = -1
PatternLength% = LEN(Pattern$)
FileLength = LOF(1)
BytesLeft = FileLength
FileOffset = 0

' Keep searching as long as there are enough bytes left in
' the file to contain the pattern you're searching for:
DO WHILE BytesLeft > PatternLength%

   ' Read either 10,000 bytes or the number of bytes left in the file,
   ' whichever is smaller, then store them in Buffer$. (If the number
   ' of bytes left is less than PACKETSIZE, the following statement
   ' still reads just the remaining bytes, since binary I/O doesn't
   ' give "read past end" errors):
   Buffer$ = INPUT$(PACKETSIZE, #1)

   ' Find every occurrence of the pattern in Buffer$:
   Start% = 1
   DO
      StringPos% = INSTR(Start%, Buffer$, Pattern$)
      IF StringPos% > 0 THEN

         ' Found the pattern, so print the byte position in the file
         ' where the pattern starts:
         PRINT "Found pattern at byte number";
         PRINT FileOffset + StringPos%
         Start% = StringPos% + 1
         FoundIt% = TRUE
      END IF
   LOOP WHILE StringPos% > 0

   ' Find the byte position where the next I/O operation would take place,
   ' then back up the file pointer a distance equal to the length of the
   ' pattern (in case the pattern straddles a 10,000-byte boundary):
   FileOffset = SEEK(1) - PatternLength%
   SEEK #1, FileOffset + 1

   BytesLeft = FileLength - FileOffset
LOOP

CLOSE #1

IF NOT FoundIt% THEN PRINT "Pattern not found."

