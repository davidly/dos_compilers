' This program prints the names of QuickLibrary procedures

DECLARE SUB DumpSym (SymStart AS INTEGER, QHdrPos AS LONG)

TYPE ExeHdr                  ' Part of DOS .EXE header
    other1    AS STRING * 8  ' Other header information
    CParHdr   AS INTEGER     ' Size of header in paragraphs
    other2    AS STRING * 10 ' Other header information
    IP        AS INTEGER     ' Initial IP value
    CS        AS INTEGER     ' Initial (relative) CS value
END TYPE

TYPE QBHdr                   ' QLB header
    QBHead    AS STRING * 6  ' QB specific heading
    Magic     AS INTEGER     ' Magic word: identifies file as
                             ' a Quick library
    SymStart  AS INTEGER     ' Offset from header to first code symbol
    DatStart  AS INTEGER     ' Offset from header to first data symbol
END TYPE

TYPE QbSym                   ' QuickLib symbol entry
    Flags     AS INTEGER     ' Symbol flags
    NameStart AS INTEGER     ' Offset into name table
    other     AS STRING * 4  ' Other header info
END TYPE

DIM EHdr AS ExeHdr, Qhdr AS QBHdr, QHdrPos AS LONG

INPUT "Enter QuickLibrary file name: ", FileName$
FileName$ = UCASE$(FileName$)
IF INSTR(FileName$, ".QLB") = 0 THEN FileName$ = FileName$ + ".QLB"

INPUT "Enter output file name or press ENTER for screen: ", OutFile$
OutFile$ = UCASE$(OutFile$)
IF OutFile$ = "" THEN OutFile$ = "CON"

OPEN FileName$ FOR BINARY AS #1
OPEN OutFile$ FOR OUTPUT AS #2

GET #1, , EHdr               ' Read the EXE format header.

QHdrPos = (EHdr.CParHdr + EHdr.CS) * 16 + EHdr.IP + 1

GET #1, QHdrPos, Qhdr        ' Read the QuickLib format header.

IF Qhdr.Magic <> &H6C75 THEN PRINT "Not a QB UserLibrary": END

PRINT #2, "Code Symbols:": PRINT #2,
DumpSym Qhdr.SymStart, QHdrPos ' dump code symbols
PRINT #2,

PRINT #2, "Data Symbols:": PRINT #2, ""
DumpSym Qhdr.DatStart, QHdrPos ' dump data symbols
PRINT #2,

END

SUB DumpSym (SymStart AS INTEGER, QHdrPos AS LONG)
   DIM QlbSym AS QbSym
   DIM NextSym AS LONG, CurrentSym AS LONG

   ' Calculate the location of the first symbol entry, then read that entry:
   NextSym = QHdrPos + SymStart
   GET #1, NextSym, QlbSym

   DO
      NextSym = SEEK(1)          ' Save the location of the next
                                 ' symbol.
      CurrentSym = QHdrPos + QlbSym.NameStart
      SEEK #1, CurrentSym        ' Use SEEK to move to the name
                                 ' for the current symbol entry.
      Prospect$ = INPUT$(40, 1)  ' Read the longest legal string,
                                 ' plus one additonal byte for the
                                 ' final null character (CHR$(0)).

      ' Extract the null-terminated name:
      SName$ = LEFT$(Prospect$, INSTR(Prospect$, CHR$(0)))

      ' Print only those names that do not begin with "__", "$", or "b$"
      ' as these names are usually considered reserved:
      IF LEFT$(SName$, 2) <> "__" AND LEFT$(SName$, 1) <> "$" AND UCASE$(LEFT$(SName$, 2)) <> "B$" THEN
         PRINT #2, "  " + SName$
      END IF

      GET #1, NextSym, QlbSym    ' Read a symbol entry.
   LOOP WHILE QlbSym.Flags       ' Flags=0 (false) means end of table.
END SUB

