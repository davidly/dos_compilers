(*$S+ *)
(*$T- *)
(*$R- *)
(****************************************************************)
(*								*)
(*	MODULA-2/86 Library					*)
(*								*)
(*	  LOGITECH SA.,  CH-1143 Apples   (Switzerland)		*)
(*								*)
(*	Module: RS232Int					*)
(*	  Library module to read and write over the RS232	*)
(*	  asynchronous serial port, using interrupts for the	*)
(*	  reception. Interrupts are treated with the standard	*)
(*	  procedure IOTRANSFER.					*)
(*	  Received characters are stored in a buffer of		*)
(*	  400H characters.					*)
(*								*)
(*	  Automatic initialization at the beginning sets	*)
(*	  the following parameters:				*)
(*	      baudRate = 1200, stopBits = 1,			*)
(*	      parityBit = FALSE, evenParity = don't care,	*)
(*	      nbrOfBits = 8					*)
(*								*)
(*	Version  1.10  (Dec '84)				*)
(*	         for IBM-PC, Controller chip is INS8250		*)
(*								*)
(*	(C) Copyright 1983, 1984 Logitech,  All Rights Reserved *)
(*								*)
(*    Permission is hereby granted to registered users to use or*)
(*    abstract the following program in the implementation of	*)
(*    customized versions. This permission does not include the	*)
(*    right to redistribute the source code of this program.	*)
(*								*)
(****************************************************************)

IMPLEMENTATION MODULE RS232Int;		(* WS *)

IMPORT SYSTEM;
FROM SYSTEM IMPORT INBYTE, OUTBYTE, SIZE, ADR, SWI, ADDRESS,
                   PROCESS, NEWPROCESS, TRANSFER, ENABLE, DISABLE;

FROM Devices IMPORT
  GetDeviceStatus, SetDeviceStatus,
  SaveInterruptVector, RestoreInterruptVector;

  CONST
    LineContrReg = 3FBH;    (* to specify format of transmitted data *)
    LowBaudRateDiv = 3F8H;  (* lower byte of divisor to select baud rate *)
    HighBaudRateDiv = 3F9H; (* higher byte of divisor *)
    LineStatusReg = 3FDH;   (* holds status info on the data transfer *)
    ReceiverReg = 3F8H;     (* received char is in this register *)
    TransmitReg = 3F8H;     (* char to send is to put in this reg *)
    IntEnableReg = 3F9H;    (* to enable the selected interrupt *)

    ModemContrReg = 3FCH;   (* controls the interface to a modem *)
    AsyncInterrupt = 0CH;   (* vector used by the communication contr. *)

    deviceMaskBitNumber = 4; (* bit in device mask for async. comm. contr. *)

    VAR
      alreadyEnabled, oldModemContrRegBit3 : BOOLEAN;
      terminated : BOOLEAN;
      workspace : ARRAY [0..100H] OF CARDINAL;
      mainP, receiverP : PROCESS;
      oldISR: ADDRESS;



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
    VAR divisorLow, divisorHigh: CARDINAL; parameters: BITSET;

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
      ELSE RETURN;
    END;
    (* load the divisor of the baud rate generator: *)
    OUTBYTE (LineContrReg, CHR(80H));
    OUTBYTE (HighBaudRateDiv, CHR(divisorHigh));
    OUTBYTE (LowBaudRateDiv, CHR(divisorLow));

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
    OUTBYTE (LineContrReg, CHR(CARDINAL(parameters)));

    (* Define Modem Control parameters: *)
    OUTBYTE (ModemContrReg, 3C); (* set DTR and RTS signals on
 				    output to logical 0  *)

    (* Disable Interrupts: *)
    OUTBYTE (IntEnableReg, 0C);

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
    VAR status: CHAR;
  BEGIN
    LOOP
      (* Wait until port is ready to accept a character: *)
      INBYTE (LineStatusReg, status);
      IF 5 IN BITSET(ORD(status)) THEN EXIT END;
    END;
    OUTBYTE (TransmitReg, ch);
  END Write;


  MODULE InterruptHandler [4];(********************************************)
    (* We execute the routines in this module at the priority of
       the asynchronous controller, to avoid a second interrupt
       while we treat the first one.
    *)
    FROM SYSTEM IMPORT INBYTE, OUTBYTE, BYTE,
		       PROCESS, TRANSFER, IOTRANSFER;
    IMPORT LineStatusReg, ReceiverReg, terminated, AsyncInterrupt,
           mainP, receiverP;

    EXPORT BusyRead, Receiver, LineBusyRead;

    CONST
      BufferSize = 400H;


    VAR
      buffer : ARRAY [0..BufferSize-1] OF CHAR;
      xin, xout : CARDINAL;



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




    PROCEDURE LineBusyRead (VAR c: CHAR; VAR received: BOOLEAN);
      VAR status : CHAR;
    BEGIN
      c := 0C; received := FALSE;
      INBYTE (LineStatusReg, status);
      IF 0 IN BITSET(ORD(status)) THEN
	INBYTE (ReceiverReg, c);
	received := TRUE;
      END;
    END LineBusyRead;


    PROCEDURE Receiver;  (* coroutine *)
      VAR ch: CHAR; valid: BOOLEAN;
	  tempSet : BITSET;
          auxIndex : CARDINAL;
    BEGIN
      LOOP
	IOTRANSFER (receiverP, mainP, AsyncInterrupt);
	IF terminated THEN
	  TRANSFER (receiverP, mainP);
	END;
	(* we have received a character: *)
	INBYTE (ReceiverReg, ch);
        auxIndex := (xin + 1) MOD BufferSize;
        IF auxIndex <> xout THEN
          buffer [xin] := ch;
          xin := auxIndex;
        END;
      END; (* LOOP *)
    END Receiver;


  BEGIN
    xin := 0;  xout := 0;
    terminated := TRUE;
  END InterruptHandler;(*******************************************)



    PROCEDURE StartReading;
      VAR tempSet : BITSET; ch: CHAR; valid: BOOLEAN;
    BEGIN
      SaveInterruptVector(AsyncInterrupt, oldISR);
      (* clear the modem controller: *)
      LineBusyRead (ch, valid);
      (* Start coroutine, which listens on the line for reception: *)
      NEWPROCESS (Receiver, ADR(workspace), SIZE(workspace), receiverP);
      terminated := FALSE;
      TRANSFER (mainP, receiverP); (* we'll come back right away *)

      (* select interrupts upon reception (in communication contr): *)
      INBYTE (ModemContrReg, ch);
      tempSet := BITSET(ORD(ch));
      oldModemContrRegBit3 := 3 IN tempSet;
      INCL (tempSet, 3);
      OUTBYTE (ModemContrReg, CHR(CARDINAL(tempSet)));
      (* enable interrupts in the communication controller (8250): *)
      OUTBYTE (IntEnableReg, CHR(1H));
      GetDeviceStatus(deviceMaskBitNumber, alreadyEnabled);
      SetDeviceStatus(deviceMaskBitNumber, TRUE);
    END StartReading;


    PROCEDURE StopReading;
      VAR tempSet : BITSET; ch: CHAR;
    BEGIN
      IF alreadyEnabled THEN
        SetDeviceStatus(deviceMaskBitNumber, FALSE);
      END;

      terminated := TRUE;
      SWI (AsyncInterrupt);
      (* This interrupt causes the interrupt service routine (ISR)
	 to be executed a last time. Since the flag 'terminated' is
	 set, the ISR will just return. The effect is that there is
         no more active ISR in the Run-Time Support for 'AyncInterrupt'.
      *)

      DISABLE;
      (* disable interrupts in 8250: *)
      OUTBYTE (IntEnableReg, 0C);
      (* restore modem control register in 8250: *)
      INBYTE (ModemContrReg, ch);
      tempSet := BITSET(ORD(ch));
      IF oldModemContrRegBit3 THEN
        INCL (tempSet, 3);
      ELSE
        EXCL (tempSet, 3);
      END;
      OUTBYTE (ModemContrReg, CHR(CARDINAL(tempSet)));
      ENABLE;
      RestoreInterruptVector(AsyncInterrupt, oldISR);
    END StopReading;


VAR done: BOOLEAN;

BEGIN
  Init (1200, 1, FALSE, FALSE, 8, done);
END RS232Int.
