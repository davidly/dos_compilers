'
' FLPT.BAS
'
' Displays how a given real value is stored in memory.
'
'
DEFINT A-Z
DECLARE FUNCTION MHex$ (X AS INTEGER)
DIM Bytes(3)

CLS
PRINT "Internal format of IEEE number (all values in hexadecimal)"
PRINT
DO

   ' Get the value and calculate the address of the variable.
   INPUT "Enter a real number (or END to quit): ", A$
   IF UCASE$(A$) = "END" THEN EXIT DO
   RealValue! = VAL(A$)
   ' Convert the real value to a long without changing any of
   ' the bits.
   AsLong& = CVL(MKS$(RealValue!))
   ' Make a string of hex digits, and add leading zeroes.
   Strout$ = HEX$(AsLong&)
   Strout$ = STRING$(8 - LEN(Strout$), "0") + Strout$

   ' Save the sign bit, and then eliminate it so it doesn't
   ' affect breaking out the bytes
   SignBit& = AsLong& AND &H80000000
   AsLong& = AsLong& AND &H7FFFFFFF
   ' Split the real value into four separate bytes
   ' --the AND removes unwanted bits; dividing by 256 shifts
   ' the value right 8 bit positions.
   FOR I = 0 TO 3
      Bytes(I) = AsLong& AND &HFF&
      AsLong& = AsLong& \ 256&
   NEXT I
   ' Display how the value appears in memory.
   PRINT
   PRINT "Bytes in Memory"
   PRINT " High    Low"
   FOR I = 1 TO 7 STEP 2
      PRINT " "; MID$(Strout$, I, 2);
   NEXT I
   PRINT : PRINT

   ' Set the value displayed for the sign bit.
   Sign = ABS(SignBit& <> 0)

   ' The exponent is the right seven bits of byte 3 and the
   ' leftmost bit of byte 2. Multiplying by 2 shifts left and
   ' makes room for the additional bit from byte 2.
   Exponent = Bytes(3) * 2 + Bytes(2) \ 128

   ' The first part of the mantissa is the right seven bits
   ' of byte 2.  The OR operation makes sure the implied bit
   ' is displayed by setting the leftmost bit.
   Mant1 = (Bytes(2) OR &H80)
   PRINT " Bit 31    Bits 30-23  Implied Bit & Bits 22-0"
   PRINT "Sign Bit  Exponent Bits     Mantissa Bits"
   PRINT TAB(4); Sign; TAB(17); MHex$(Exponent);
   PRINT TAB(33); MHex$(Mant1); MHex$(Bytes(1)); MHex$(Bytes(0))
   PRINT

LOOP

' MHex$ makes sure we always get two hex digits.
FUNCTION MHex$ (X AS INTEGER) STATIC
   D$ = HEX$(X)
   IF LEN(D$) < 2 THEN D$ = "0" + D$
   MHex$ = D$
END FUNCTION

