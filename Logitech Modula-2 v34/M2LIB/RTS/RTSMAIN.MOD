IMPLEMENTATION MODULE RTSMain;

PROCEDURE GetMessage(status: Status; VAR message: ARRAY OF CHAR);
BEGIN END GetMessage;

PROCEDURE Terminate( st : Status );
BEGIN END Terminate;

PROCEDURE Execute;
BEGIN END Execute;

PROCEDURE InstallTermProc( p : PROC );
BEGIN END InstallTermProc;
PROCEDURE CallTermProc;
BEGIN END CallTermProc;

PROCEDURE InstallInitProc( p : PROC );
BEGIN END InstallInitProc;
PROCEDURE CallInitProc;
BEGIN END CallInitProc;

END RTSMain.
