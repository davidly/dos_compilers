IMPLEMENTATION MODULE RTSM2Exit;

FROM RTSMain IMPORT Terminate, Status, errorCode;

PROCEDURE M2EXIT(errorLevel : CARDINAL);
BEGIN
  errorCode := errorLevel;
  Terminate(Normal);
END M2EXIT;

END RTSM2Exit.
