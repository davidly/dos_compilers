PROGRAM CallC;
(*$//CMAIN*)

USES Cout;

CONST
    fName : ARRAY [0..8] OF CHAR = 'TEXT.TXT' + #0;
    fType : ARRAY [0..1] OF CHAR = 'w' + #0;
    fFormat : ARRAY [0..19] OF CHAR = 'X = %3d, Y = %3d %s' + #0;
    units : ARRAY [0..11] OF CHAR = 'Millimeters' + #0;

VAR
    f : cFile;

BEGIN
    f := fopen(fName, fType);
    fprintf(f, fFormat, INTEGER(13), INTEGER(-25), @units);
    fclose(f);
END.
