unit KeyNamer;

interface

uses drivers;

function KeyName( key: word): String;

implementation

function KeyName( key: word): String;
const
  QWERTY: String[10] = 'QWERTYUIOP';
  ASDF: String[9] = 'ASDFGHJKL';
  ZXCV: String[7] = 'ZXCVBNM';
var
  st: String;
begin
  KeyName:='';
  case key of
    0..31: KeyName:= 'Control-'+char(key+64);
       32: KeyName:= 'Spacebar';
  33..125: KeyName:= Char(key);
    $011B: KeyName:= 'kbEsc';
    $0200: KeyName:= 'kbAltSpace';
    $0400: KeyName:= 'kbCtrlIns';
    $0500: KeyName:= 'kbShiftIns';
    $0600: KeyName:= 'kbCtrlDel';
    $0700: KeyName:= 'kbShiftDel';
    $0E08: KeyName:= 'kbBack';
    $0E7F: KeyName:= 'kbCtrlBack';
    $0F00: KeyName:= 'kbShiftTab';
    $0F09: KeyName:= 'kbTab';
    $1C0A: KeyName:= 'kbCtrlEnter';
    $1C0D: KeyName:= 'kbEnter';
    $4700: KeyName:= 'kbHome';
    $4800: KeyName:= 'kbUp';
    $4900: KeyName:= 'kbPgUp';
    $4A2D: KeyName:= 'kbGrayMinus';
    $4B00: KeyName:= 'kbLeft';
    $4D00: KeyName:= 'kbRight';
    $4E2B: KeyName:= 'kbGrayPlus';
    $4F00: KeyName:= 'kbEnd';
    $5000: KeyName:= 'kbDown';
    $5100: KeyName:= 'kbPgDn';
    $5200: KeyName:= 'kbIns';
    $5300: KeyName:= 'kbDel';
    $7200: KeyName:= 'kbCtrlPrtSc';
    $7300: KeyName:= 'kbCtrlLeft';
    $7400: KeyName:= 'kbCtrlRight';
    $7500: KeyName:= 'kbCtrlEnd';
    $7600: KeyName:= 'kbCtrlPgDn';
    $7700: KeyName:= 'kbCtrlHome';
    $8200: KeyName:= 'kbAltMinus';
    $8300: KeyName:= 'kbAltEqual';
    $8400: KeyName:= 'kbCtrlPgUp';
    $0000: KeyName:= 'kbNoKey';
  else
    if Lo(key) = 0 then
    begin
      key := hi(key);
      case key of
        $10..$19:  KeyName:= 'kbAlt'+ QWERTY[key-$0F];
        $1E..$26:  KeyName:= 'kbAlt'+ ASDF[key-$1D];
        $2C..$32:  KeyName:= 'kbAlt'+ ZXCV[key-$2B];
        $3B..$44:
          begin
            Str((key-$3A):0,st);
            KeyName:= 'kbF'+st;
          end;
        $54..$5D:
          begin
            Str((key-$53):0,st);
            KeyName:= 'kbShiftF'+st;
          end;
        $5E..$67:
          begin
            Str((key-$5D):0,st);
            KeyName:= 'kbCtrlF'+st;
          end;
        $68..$71:
          begin
            Str((key-$67):0,st);
            KeyName:= 'kbAltF'+st;
          end;
        $78..$81:
          begin
            Str((key-$77):0,st);
            KeyName:= 'kbAlt'+st;
          end;
      end;  {case}
    end;
  end; {case}
end;

end.