(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*	  Library module to read and write over the RS-232		   *)
(*	  asynchronous serial port, using interrupts for the		   *)
(*	  reception. Characters received are stored in a		   *)
(*	  buffer of 400H characters.					   *)
(*	  Interrupts are handled with the Modula-2 standard		   *)
(*	  procedure IOTRANSFER.						   *)
(*									   *)
(*	  Automatic initialization at the beginning sets		   *)
(*	  the following parameters:					   *)
(*	      baudRate = 1200, stopBits = 1,				   *)
(*	      parityBit = FALSE, evenParity = don't care,		   *)
(*	      nbrOfBits = 8						   *)
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
(*$S+ *)
(*$T- *)
(*$R- *)
IMPLEMENTATION MODULE RS232Int;		(* WS *)

  IMPORT SYSTEM;
  IMPORT Devices;

  FROM SYSTEM IMPORT INBYTE, OUTBYTE;


  CONST
    (* the following constant declaration may be modified to change *)
    (* the module for the alternate communications adapter.         *)

    com1 = 1; (* = 1 means TRUE  or COM1 is used *)
              (* = 0 means FALSE or COM2 is used *)

    iobase = 2F0H + com1 * 100H;

    LineContrReg    = iobase+0BH; (* to specify format of transmitted data  *)
    LowBaudRateDiv  = iobase+08H; (* lower byte of divisor                  *)
    HighBaudRateDiv = iobase+09H; (* higher byte of divisor                 *)
    LineStatusReg   = iobase+0DH; (* holds status info on the data transfer *)
    ReceiverReg     = iobase+08H; (* received char is in this register      *)
    TransmitReg     = iobase+08H; (* char to send is to put in this reg     *)
    IntEnableReg    = iobase+09H; (* to enable the selected interrupt       *)
    ModemContrReg   = iobase+0CH; (* controls the interface to a modem      *)

    AsyncInterrupt  = 0BH + com1; (* vector used by communications contr.   *)

    deviceMaskBitNr = 3 + com1;   (* bit in device mask for asynchronous    *)
                                  (* communications controller              *)

    priority = 7 - deviceMaskBitNr;
      (* priority level for async. comm. contr. *)


  PROCEDURE Init (baudRate: CARDINAL; stopBits: CARDINAL;
		  parityBit: BOOLEAN; evenParity: BOOLEAN;
		  nbrOfBits: CARDINAL; VAR result: BOOLEAN);
    (* Used to initialze the serial port to specific values. The legal
       values for the parameters are:
	 baudRate: 300..9600
	 stopBits: 1 or 2
	 parityBit: TRUE / FALSE
	 evenParity: TRUE / FALSE
	 nbrOfBits: 5..8
    *)
    VAR
      divisorLow, divisorHigh: CARDINAL;
      parameters: BITSET;

  BEGIN (* Init *)
    result := FALSE;
    divisorHigh := 0;
    CASE baudRate OF
	 300: divisorLow := 80H;
	      divisorHigh := 1H;
      |  600: divisorLow := 0C0H;
      | 1200: divisorLow := 60H;
      | 2400: divisorLow := 30H;
      | 4800: divisorLow := 18H;
      | 9600: divisorLow := 0CH;
      |19200: divisorLow := 06H;
      ELSE RETURN;
    END;
    (* load the divisor of the baud rate generator: *)
    OUTBYTE (LineContrReg, 80H);
    OUTBYTE (HighBaudRateDiv, divisorHigh);
    OUTBYTE (LowBaudRateDiv, divisorLow);

    (* prepare the parameters: *)
    parameters := {};
    IF stopBits = 2 THEN INCL (parameters, 2);
    ELSIF stopBits <> 1 THEN RETURN;
    END;
    IF parityBit THEN INCL (parameters, 3); END;
    IF evenParity THEN INCL (parameters, 4); END;
    IF (nbrOfBits < 5) OR (nbrOfBits > 8) THEN RETURN END;
    IF NOT ODD (nbrOfBits) THEN INCL (parameters, 0); END;
    IF nbrOfBits >= 7 THEN INCL (parameters, 1); END;
    OUTBYTE (LineContrReg, parameters);

    result := TRUE;
  END Init;


  PROCEDURE Read (VAR ch: CHAR);
    (* Reads a character from the buffer and returns it in 'ch'.
       This routine returns control to the calling program only after
       a character has been received.
    *)
    VAR done: BOOLEAN;
  BEGIN
    LOOP
      BusyRead (ch, done);
      IF done THEN EXIT END;
    END;
  END Read;


  PROCEDURE Write (ch: CHAR);
    (* Writes 'ch' to the port. No interpretation of characters is made *)
    VAR status: BITSET;
  BEGIN
    LOOP
      (* Wait until port is ready to accept a character: *)
      INBYTE (LineStatusReg, status);
      IF {5,6} * status = {5,6} THEN
        (* transmitter holding register and Tx shift register empty *)
        EXIT;
      END;
    END;
    OUTBYTE (TransmitReg, ch);
  END Write;


  MODULE InterruptHandler (* [priority] *); (**********************)
    (* In principle, the routines in this module should run at the
       priority of the asynchronous controller, to monitor the access
       to the input buffer and to prevent a second interrupt while
       the first one is handled. However, this implementation has
       been designed carefully, such that monitor protection is not
       needed (assuming that the interrupt handling is fast enough).
       This allows for faster buffer access.
    *)
    FROM SYSTEM IMPORT
      INBYTE, OUTBYTE, ADDRESS, ADR, SIZE,
      PROCESS, NEWPROCESS, TRANSFER, IOTRANSFER;

    FROM Devices IMPORT
      GetDeviceStatus, SetDeviceStatus,
      SaveInterruptVector, RestoreInterruptVector,
      InstallHandler, UninstallHandler;

    IMPORT
      LineStatusReg, ReceiverReg, IntEnableReg, ModemContrReg,
      AsyncInterrupt, deviceMaskBitNr;

    EXPORT BusyRead, StartReading, StopReading;


    CONST
      BufferSize = 400H;


    VAR
      buffer: ARRAY [0..BufferSize-1] OF CHAR;
      xin, xout: CARDINAL;
      alreadyEnabled: BOOLEAN;
      oldMCR: BITSET;
      oldISR: ADDRESS;
      level: CARDINAL; (* level of calls to StartReading/StopReading *)
      workspace: ARRAY [0..100H] OF CARDINAL;
      mainP, receiverP: PROCESS;


    PROCEDURE BusyRead (VAR ch: CHAR; VAR received: BOOLEAN);
      (* If a character has been received, it is read and assigned to 'ch'
         and 'received' is set to TRUE. If no character has been received,
         'ch' is set to 0C and 'received' is set to FALSE.
      *)
    BEGIN
      IF xin=xout THEN
	received := FALSE;
	ch := 0C;
      ELSE
	received := TRUE;
	ch := buffer[xout];
	xout := (xout + 1) MOD BufferSize;
      END;
    END BusyRead;


    PROCEDURE Receiver;  (* coroutine *)
      VAR ch: CHAR; auxIndex: CARDINAL;
    BEGIN
      LOOP
        IOTRANSFER (receiverP, mainP, AsyncInterrupt);
        (* we have received a character: *)
        INBYTE (ReceiverReg, ch);
        auxIndex := (xin + 1) MOD BufferSize;
        IF auxIndex <> xout THEN
          buffer [xin] := ch;
          xin := auxIndex;
        END;
      END; (* LOOP *)
    END Receiver;


    PROCEDURE StartReading;
      VAR tempSet: BITSET; dummy: CHAR;
    BEGIN
      IF level = 0 THEN
        (* At this point, interrupts are disabled in the interrupt
           enable register of the communications controller (8250),
           either from the initialization of this module or from
           the last call to StopReading. *)
        (* reset input buffer: *)
        xin := 0; xout := 0;

        (* save current interrupt service routine: *)
        SaveInterruptVector(AsyncInterrupt, oldISR);

        (* create coroutine, which listens on the line for reception: *)
        NEWPROCESS (Receiver, ADR(workspace), SIZE(workspace), receiverP);
        (* install it as a permanent interrupt handler: *)
        InstallHandler(receiverP, AsyncInterrupt);
        (* start it: *)
        TRANSFER (mainP, receiverP); (* we'll come back right away *)

        (* clear the controller: *)
        INBYTE (LineStatusReg, tempSet);
        IF 0 IN tempSet THEN (* data ready *)
	  INBYTE (ReceiverReg, dummy);
        END;

        (* select interrupts upon reception (in communications contr.): *)
        INBYTE (ModemContrReg, oldMCR);
        tempSet := oldMCR;
        INCL (tempSet, 3); (* bit 3 must be set, otherwise no *)
                           (* interrupts will be generated;   *)
                           (* see technical reference of      *)
                           (* IBM-PC, page 1-186              *)
        INCL (tempSet, 0); (* set DTR *)
        INCL (tempSet, 1); (* set RTS *)
        OUTBYTE (ModemContrReg, tempSet);

        (* enable interrupts in the communications controller (8250): *)
        OUTBYTE (IntEnableReg, 1H);

        (* save old status and enable interrupts from the communications
           controller in the interrupt controller (8259): *)
        GetDeviceStatus(deviceMaskBitNr, alreadyEnabled);
        SetDeviceStatus(deviceMaskBitNr, TRUE);
      END;
      INC(level);
    END StartReading;


    PROCEDURE StopReading;
      VAR ch: CHAR;
    BEGIN
      IF level <> 0 THEN
        DEC(level);
        IF level = 0 THEN
          (* disable interrupts in the communications controller (8250): *)
          OUTBYTE (IntEnableReg, 0H);

          (* remove (terminate) the interrupt handler process: *)
          UninstallHandler(receiverP);

          (* restore modem control register in 8250: *)
          OUTBYTE (ModemContrReg, oldMCR);
	  (* restore old interrupt service routine: *)
          RestoreInterruptVector(AsyncInterrupt, oldISR);
	  (* restore old device status: *)
          SetDeviceStatus(deviceMaskBitNr, alreadyEnabled);
        END;
      END;
    END StopReading;

  BEGIN
    level := 0;
  END InterruptHandler;(*******************************************)


VAR done: BOOLEAN;

BEGIN
  (* disable interrupts: *)
  OUTBYTE (LineContrReg, 0H);
  OUTBYTE (IntEnableReg, 0H);
  Init (1200, 1, FALSE, FALSE, 8, done);
END RS232Int.
