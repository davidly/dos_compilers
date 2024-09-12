UNIT Cout;

(*//NOMODINIT*)

INTERFACE

TYPE cFile = POINTER;
    
FUNCTION fopen (VAR path, ftype) : cFile
    [C]; FAR; EXTERNAL '_fopen';

PROCEDURE fclose (f : cFile)
    [C]; FAR; EXTERNAL '_fclose';

PROCEDURE fprintf (f : cFile; VAR format)
    [C, VARIABLE]; FAR; EXTERNAL '_fprintf';

IMPLEMENTATION

END.
