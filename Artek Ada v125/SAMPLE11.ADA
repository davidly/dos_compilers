with UNCHECKED_CONVERSION, TEXT_IO;
use TEXT_IO;
procedure SAMPLE11 is -- UNCHECKED_CONVERSION demonstration

   type FLOAT_INTERNAL is array (0..7) of CHARACTER;

   PI : constant FLOAT := 3.1415_92653_58979_32384_62643_38327_95029;

   INTERNAL_PI : FLOAT_INTERNAL;
   HEXSTRING : STRING (1..7); -- Room for [sign]16#FF#

   package INTIO is new INTEGER_IO (INTEGER); use INTIO;

   function FLOAT_TO_INTERNAL is
      new UNCHECKED_CONVERSION (SOURCE => FLOAT, TARGET => FLOAT_INTERNAL);

   function HEX (N : in INTEGER) return STRING is
      HEXDIGIT : constant STRING := "0123456789ABCDEF";
   begin -- N must be smaller than 16
      return (1 => HEXDIGIT (N / 16 + 1), 2 => HEXDIGIT (N mod 16 + 1));
   end HEX;

begin
   PUT_LINE ("This program shows how PI is represented internally in the IEEE 64-bit format.");
   NEW_LINE;
   INTERNAL_PI := FLOAT_TO_INTERNAL (PI);
   PUT ("Byte number    : ");
   for I in INTERNAL_PI'RANGE loop
      PUT (I, WIDTH => 3);
   end loop;
   NEW_LINE;
   PUT ("Contents (hex) : ");
   for I in INTERNAL_PI'RANGE loop
      PUT (' ' & HEX (CHARACTER'POS (INTERNAL_PI (I))));
   end loop;
   NEW_LINE;
   PUT_LINE ("End of program.");
end SAMPLE11;

