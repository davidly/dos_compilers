procedure get_time( var tt : timetype );
var
  regs: registers;

begin
  regs.AH := $2c;
  regs.AL := 0;
  Intr( $21, regs );
  with regs do
  begin
    tt.h := CX shr 8;
    tt.m := CX mod 256;
    tt.s := DX shr 8;
    tt.l := DX mod 256;
  end;
end;


