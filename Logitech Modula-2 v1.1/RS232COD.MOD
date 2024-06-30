(*$S+ *)
(*$T- *)
(*$R- *)
(****************************************************************)
(*								*)
(*	MODULA-2/86 Library					*)
(*								*)
(*	  LOGITECH SA.,  CH-1143 Apples   (Switzerland)		*)
(*								*)
(*	Module: RS232Code					*)
(*	  Library module to read and write over the RS-232	*)
(*	  asynchronous serial port. Received characters are	*)
(*	  stored in a buffer of 100H characters.		*)
(*	  The Interrupt Service Routine is implemented		*)
(*	  using inline-code (as opposed to IOTRANSFER).		*)
(*	  This approach is NOT portable to other Modula-2	*)
(*	  implementations, but it allows for treatment of	*)
(*	  interrupts with high frequency.			*)
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

IMPLEMENTATION MODULE RS232Code;		(* WS *)

IMPORT SYSTEM;
IMPORT Devices;

FROM SYSTEM IMPORT INBYTE, OUTBYTE;


  CONST
    LineContrReg = 3FBH;    (* to specify format of transmitted data *)
    LowBaudRateDiv = 3F8H;  (* lower byte of divisor to select baud rate *)
    HighBaudRateDiv = 3F9H; (* higher byte of divisor *)
    LineStatusReg = 3FDH;   (* holds status info on the data transfer *)
    ReceiverReg = 3F8H;     (* received char is in this register *)
    TransmitReg = 3F8H;     (* char to send is to put in this reg *)
    IntEnableReg = 3F9H;    (* to enable the selected interrupt *)
    ModemContrReg = 3FCH;   (* controls the interface to a modem *)




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
      |19200: divisorLow := 06H;
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



  PROCEDURE BusyRead (VAR ch: CHAR; VAR received: BOOLEAN);
    (* If a character has been received, it is read and assigned to 'ch'
       and 'received' is set to TRUE. If no character has been received,
       'ch' is set to 0C and 'received' is set to FALSE.
    *)
  BEGIN
    GetByte (ch, received);
  END BusyRead;


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


  MODULE InterruptHandler;(********************************************)

    FROM SYSTEM IMPORT INBYTE, OUTBYTE, ADR, BYTE, ADDRESS,
		       ENABLE, DISABLE;

    FROM Devices IMPORT
      GetDeviceStatus, SetDeviceStatus,
      SaveInterruptVector, RestoreInterruptVector;
   
    IMPORT LineStatusReg, ReceiverReg, IntEnableReg, ModemContrReg;

    EXPORT GetByte, StartReading, StopReading;

    CONST
      I8259ContrWord1 = 21H;  (* Interrupt controller,
				 Operation Control Word 1 *)
      I8259ContrWord2 = 20H;  (* Interrupt controller,
				 Operation Control Word 2 *)
      EndOfInterrupt = 20H;   (* code to send to the 8259 in the ISR *)
      deviceMaskBitNumber = 4;
        (* bit number in device mask for async. comm. contr. *)
      asyncInterrupt = 0CH;   (* vector used by the communication contr. *)

      BufferSize = 100H;


    VAR
      oldModemContrRegBit3 : BOOLEAN;
      alreadyEnabled : BOOLEAN;
      buffer : ARRAY [0..BufferSize-1] OF CHAR;
      xin, xout : CARDINAL;
      ISR : ARRAY [0..30] OF BYTE; (* It will contain the code of the ISR *)
      oldVector0C : ADDRESS;


    PROCEDURE GetByte (VAR c: BYTE; VAR valid: BOOLEAN);
    BEGIN
      IF xin=xout THEN
	valid := FALSE;
	c := BYTE (0C);
      ELSE
	valid := TRUE;
	c := BYTE(buffer[xout]);
	xout := (xout + 1) MOD BufferSize;
      END;
    END GetByte;

    PROCEDURE PutByte (c: BYTE);
    BEGIN
      IF (xin + 1) MOD BufferSize = xout THEN RETURN END;
      buffer [xin] := CHAR (c);
      xin := (xin + 1) MOD BufferSize;
    END PutByte;


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


    PROCEDURE Receiver;  (* Body of the Interrupt Service Routine *)
      VAR ch: CHAR;  done: BOOLEAN;
    BEGIN
      (* This procedure is called from the code in the array ISR,
	 after execution of the prolog in that array.
	 When arriving here, we have received a character.
      *)
      LineBusyRead (ch, done);
      IF done THEN  PutByte (ch);  END;
      OUTBYTE (I8259ContrWord2, CHR(EndOfInterrupt));
    END Receiver;


    PROCEDURE StartReading;
      VAR tempSet : BITSET; ch: CHAR; dummy: BOOLEAN;
	  ISRbody: PROC; p: POINTER TO ADDRESS;
    BEGIN
      ISR[ 0] := BYTE (50H);	(* push ax *)
      ISR[ 1] := BYTE (51H);	(* push cx *)
      ISR[ 2] := BYTE (52H);	(* push dx *)
      ISR[ 3] := BYTE (53H);	(* push bx *)
      ISR[ 4] := BYTE (56H);	(* push si *)
      ISR[ 5] := BYTE (57H);	(* push di *)
      ISR[ 6] := BYTE (1EH);	(* push ds *)
      ISR[ 7] := BYTE (06H);	(* push es *)
      ISR[ 8] := BYTE (9AH);	(* call far *)
      ISR[ 9] := BYTE (00H);	(* address will be fixed below *)
      ISR[10] := BYTE (00H);	(* that routine saves and restores bp *)
      ISR[11] := BYTE (00H);
      ISR[12] := BYTE (00H);
      ISR[13] := BYTE (07H);	(* pop es *)
      ISR[14] := BYTE (1FH);	(* pop ds *)
      ISR[15] := BYTE (5FH);	(* pop di *)
      ISR[16] := BYTE (5EH);	(* pop si *)
      ISR[17] := BYTE (5BH);	(* pop bx *)
      ISR[18] := BYTE (5AH);	(* pop dx *)
      ISR[19] := BYTE (59H);	(* pop cx *)
      ISR[20] := BYTE (58H);	(* pop ax *)
      ISR[21] := BYTE (0CFH);	(* iret *)

      ISRbody := Receiver;
      p := ADR (ISR[9]);
      p^:= ADDRESS (ISRbody);

      SaveInterruptVector(asyncInterrupt, oldVector0C);
      RestoreInterruptVector(asyncInterrupt, ADR(ISR));

      LineBusyRead (ch, dummy);  (* clear the controller *)

      DISABLE;
      xin := 0;  xout := 0;
      (* select interrupts upon reception: *)
      INBYTE (ModemContrReg, ch);
      tempSet := BITSET (ORD(ch));
      oldModemContrRegBit3 := 3 IN tempSet;
      INCL (tempSet, 3);
      OUTBYTE (ModemContrReg, CHR(CARDINAL(tempSet)));

      (* enable interrupts in the communication controller (8250): *)
      OUTBYTE (IntEnableReg, 1C);

      GetDeviceStatus(deviceMaskBitNumber, alreadyEnabled);
      SetDeviceStatus(deviceMaskBitNumber, TRUE);
      ENABLE;
    END StartReading;


    PROCEDURE StopReading;
      VAR tempSet: BITSET;  ch: CHAR;
    BEGIN
      DISABLE;
      IF alreadyEnabled THEN
        SetDeviceStatus(deviceMaskBitNumber, FALSE);
      END;
      (* disable interrupts in 8250: *)
      OUTBYTE (IntEnableReg, 0C);
      (* restore modem control register in 8250: *)
      INBYTE (ModemContrReg, ch);
      tempSet := BITSET (ORD(ch));
      IF oldModemContrRegBit3 THEN
	INCL (tempSet, 3);
      ELSE
	EXCL (tempSet, 3);
      END;
      OUTBYTE (ModemContrReg, CHR(CARDINAL(tempSet)));

      RestoreInterruptVector(asyncInterrupt, oldVector0C);

      ENABLE;
    END StopReading;

  END InterruptHandler;(*******************************************)



VAR done: BOOLEAN;

BEGIN
  Init (1200, 1, FALSE, FALSE, 8, done);
END RS232Code.
