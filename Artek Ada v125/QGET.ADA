
with DOS_INTERFACE;
use DOS_INTERFACE;

procedure QGET (C : in out CHARACTER) is
   R : REG_8086;
   LO, HI : BYTE;
begin
   R . AX := 16#0700#; -- DOS direct console input without echo
   CALL_DOS (R);
   SPLIT_REGISTER (R . AX, LO, HI);
   C := CHARACTER (LO);
end QGET;

