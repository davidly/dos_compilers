
{ Copyright (c) 1985, 88 by Borland International, Inc. }

unit BCD;

{ The BCD version of Turbo Pascal 3.0 (TURBOBCD.COM) supports
  10-byte binary coded decimal reals with 18 significant digits
  and a range of 1E-63 to 1E+63. The BCD real data type is not
  supported by Turbo Pascal 5.0, and this unit provides a routine
  for converting 3.0 BCD reals to 6-byte reals (software reals)
  or 10-byte 8087 extended reals.

  Before you convert a Turbo Pascal 3.0 BCD program to run under
  5.0, you need to select a 5.0 real data type for your floating
  point values. If you do not have an 8087, or if your program is
  to run on machines without an 8087, your only option is to use
  the familiar 6-byte Real, which provides 11-12 significant digits
  with a range of 2.9E-39 to 1.7E+38. This type is also supported by
  the standard version of Turbo Pascal 3.0. If you are planning to
  use the 8087, we suggest you select the 10-byte Extended type,
  which provides 19-20 significant digits with a range of 1.9E-4951
  to 1.1E+4932. Once you have selected a data type, you need to write
  a conversion program that translates your old data files using the
  conversion routine provided here.

  The Decimal type defined by this unit corresponds to the 3.0 BCD
  Real, and the DecToFloat routine converts a Decimal variable to a
  6-byte Real or to a 10-byte Extended.

  The BCD unit uses conditional compilation constructs to define a
  type Float which is equivalent to either Real or Extended,
  depending on the kind of numeric processing you select (software
  or hardware). To compile a program that uses the BCD unit, first
  select software or hardware floating point, using the Options/
  Compiler/Numeric processing menu, and then do a Compile/Build,
  which automatically recompiles BCD.PAS.

  The following program shows how to convert a 3.0 data file that
  contains records with BCD fields. The program defines an equivalent
  of the 3.0 record (OldDataRec) using the Decimal type for fields
  that contain BCD reals. In the corresponding 5.0 record (NewDataRec),
  floating point fields are declared using the Float type, which is
  either Real or Extended depending on the floating point model
  selected. During the conversion, all Decimal fields are converted
  to Float using the DecToFloat function, whereas all non-real fields
  are copied directly.

  program ConvertBCD;
  uses BCD;
  type
    OldDataRec = record
                   Name: string[15];
                   InPrice,OutPrice: Decimal;
                   InStock,MinStock: Integer;
                 end;
    NewDataRec = record
                   Name: string[15];
                   InPrice,OutPrice: Float;
                   InStock,MinStock: Integer;
                 end;
  var
    OldFile: file of OldDataRec;
    NewFile: file of NewDataRec;
    Old: OldDataRec;
    New: NewDataRec;
  begin
    Assign(OldFile,'OLDFILE.DTA'); Reset(F);
    Assign(NewFile,'NEWFILE.DTA'); Rewrite(F);
    while not Eof(OldFile) do
    begin
      Read(OldFile,Old);
      New.Name     := Old.Name;
      New.InPrice  := DecToFloat(Old.InPrice);
      New.OutPrice := DecToFloat(Old.OutPrice);
      New.InStock  := Old.InStock;
      New.MinStock := Old.MinStock;
      Write(NewFile,New);
    end;
    Close(OldFile);
    Close(NewFile);
  end.

  The range of a BCD real is larger than that of a 6-byte software
  real. Therefore, when converting to 6-byte reals, BCD values larger
  than 1E+38 are converted to 1E+38, and BCD values less than 2.9E-39
  are converted to zero.
}

interface

type
  Decimal = array[0..9] of Byte;
{$IFOPT N-}
  Float = Real;
{$ELSE}
  Float = Extended;
{$ENDIF}

function DecToFloat(var D: Decimal): Float;

implementation

function DecToFloat(var D: Decimal): Float;
var
  E,L,P: Integer;
  V: Float;

function Power10(E: Integer): Float;
var
  I: Integer;
  P: Float;
begin
  I:=0; P:=1.0;
  repeat
    if Odd(E) then
    case I of
      0: P:=P*1E1;
      1: P:=P*1E2;
      2: P:=P*1E4;
      3: P:=P*1E8;
      4: P:=P*1E16;
      5: P:=P*1E32;
    end;
    E:=E shr 1; Inc(I);
  until E=0;
  Power10:=P;
end;

begin
{$IFOPT N-}
  if D[0] and $7F>38+$3F then V:=10E37 else
{$ENDIF}
  begin
    V:=0.0; L:=1;
    while (L<=9) and (D[L]=0) do Inc(L);
    if L<=9 then
    begin
      for P:=9 downto L do
      begin
        V:=V*100.0+((D[P] shr 4)*10+D[P] and $0F);
      end;
      E:=D[0] and $7F-($3F+(10-L)*2);
      if E>=0 then V:=V*Power10(E) else
      begin
        if E<-32 then
        begin
          V:=V/1E32; E:=E+32;
        end;
        V:=V/Power10(-E);
      end;
    end;
  end;
  if D[0] and $80=0 then DecToFloat:=V else DecToFloat:=-V;
end;

end.
