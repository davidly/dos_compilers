(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Devices                           			           *)
(*                                                                         *)
(*    Release :    Dec 89                                                  *)
(*                                                                         *)
(*    Copyright (C)  1987, 1989 Logitech, All rights reserved              *)
(*                                                                         *)
(*    Permission is hereby granted to registered users to use or abstract  *)
(*    the following program in the implementation of customized versions.  *)
(*    This permission does not include the right to redistribute the       *)
(*    source code of this program.                                         *)
(*                                                                         *)
(***************************************************************************)
(*$T-*)
(*$R-*)
IMPLEMENTATION MODULE Devices;
  FROM SYSTEM IMPORT
    ADDRESS, ADR, PROCESS, SWI,
    SETREG, GETREG, AX, BX, CX, DX;

  IMPORT RTSDevice;

  VAR
    interruptVectorTable[0000H:0000H]: ARRAY [0..255] OF ADDRESS;


  PROCEDURE GetDeviceStatus(device: CARDINAL; VAR enabled: BOOLEAN);
  BEGIN
    RTSDevice.GetDeviceStatus( device, enabled );
  END GetDeviceStatus;

  PROCEDURE SetDeviceStatus(device: CARDINAL; enable: BOOLEAN);
  BEGIN
    RTSDevice.SetDeviceStatus( device, enable );
  END SetDeviceStatus;

  PROCEDURE SaveInterruptVector(vectorNr: CARDINAL; VAR vector: ADDRESS);
  BEGIN
    vector := interruptVectorTable[vectorNr];
  END SaveInterruptVector;

  PROCEDURE RestoreInterruptVector(vectorNr: CARDINAL; vector: ADDRESS);
  BEGIN
    interruptVectorTable[vectorNr] := vector;
  END RestoreInterruptVector;


  PROCEDURE InstallHandler(process: PROCESS;
                           vectorNr: CARDINAL);
  (*
  - Install an interrupt handler permanently

  in:   process    process associated with the interrupt
                   handler
        vectorNr   interrupt vector number

  The process is associated permanently to the given
  interrupt vector number. This improves the performance
  of IOTRANSFER and of the implicit coroutine transfer
  that takes place when the interrupt occurs. A process
  may be associated to at most one interrupt, and at most
  one process may be associated to the same interrupt.

  'InstallHandler' must only be called after the process has
  been created (by means of NEWPROCESS) and before the
  process has called IOTRANSFER. For instance, it may be
  called right at the beginning of the code of the process.
  Except for the call to 'InstallHandler', the code of a
  permanently installed interrupt handler is identical to
  the code of a regular interrupt handler.
  *)
  BEGIN
    RTSDevice.InstallHandler( process, vectorNr );
  END InstallHandler;

  PROCEDURE UninstallHandler(process: PROCESS);
  (*
  - Uninstall an interrupt handler which has been
    installed permanently

  in:   process    process associated with the interrupt
                   handler

  In general, there is no need to call this procedure.
  The MODULA-2/86 run-time support automatically uninstalls
  interrupt handlers upon termination of a (sub-)program.
  *)
  BEGIN
    RTSDevice.UninstallHandler( process );
  END UninstallHandler;

END Devices.
