UNIT Spiffy;

(*$//NOMODINIT*)

INTERFACE

VAR
    SpiffyStatus : INTEGER EXTERNAL 'SpiffyStatus';

PROCEDURE SpiffyIn
    (channel : INTEGER; VAR str; VAR size : INTEGER)
    [C]; FAR; EXTERNAL 'SpiffyIn';

PROCEDURE SpiffyOut (channel : INTEGER; VAR str)
    [C]; FAR; EXTERNAL 'SpiffyOut';

IMPLEMENTATION
END.
