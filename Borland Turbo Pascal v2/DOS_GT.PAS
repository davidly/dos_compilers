type
  regpack = record
            ax,bx,cx,dx,bp,si,di,ds,es,flags: integer;
            end;

procedure get_time( var tt : timetype );
var
  recpack:        regpack;
  ah,al,ch,cl,dh: byte;

begin
  ah := $2c;
  with recpack do
  begin
    ax := ah shl 8 + al;
  end;
  intr( $21, recpack );
  with recpack do
  begin
    tt.h := cx shr 8;
    tt.m := cx mod 256;
    tt.s := dx shr 8;
    tt.l := dx mod 256;
  end;
end;


