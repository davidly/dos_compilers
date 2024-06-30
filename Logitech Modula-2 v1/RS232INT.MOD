(*
    Copyrigth (C) 1984 Logitech. All Rights Reserved.

    Permission is hereby granted to registered users to use or
    abstract the following program in the implementation of
    customized versions. This permission does not include the
    right to redistribute the source code of this program.
*)
(*$S+ *)
(*$T- *)
(*$R- *)
(************************************************************)
(*							    *)
(*     MODULA-2 / 86		(Library Module)	    *)
(*							    *)
(*     Module: RS232Int 				    *)
(*	    Library module to read and write over the	    *)
(*	    RS-232 asynchronous serial port, using inter-   *)
(*	    rupts for the reception. Interrupts are treated *)
(*	    with the standard procedure IOTRANSFER.	    *)
(*	    Received characters are stored in a buffer of   *)
(*	    100H characters.				    *)
(*	    Automatic initialization at the beginning sets  *)
(*	    the following parameters:			    *)
(*	      baudRate = 1200, stopBits = 1,		    *)
(*	      parityBit = FALSE, evenParity = don't care,   *)
(*	      nbrOfBits = 8				    *)
(*							    *)
(*     Version: 					    *)
(*	    IBM-PC, V1.0 january 84			    *)
(*     Author:						    *)
(*	    Willy Steiger				    *)
(*	    LOGITECH SA.				    *)
(*	    CH-1143 Apples   (Switzerland)		    *)
(*							    *)
(************************************************************)

IMPLEMENTATION MODULE RS232Int;

IMPORT SYSTEM;
FROM SYSTEM IMPORT INBYTE, OUTBYTE, SIZE, ADR, SWI,
                   PROCESS, NEWPROCESS, TRANSFER, ENABLE, DISABLE;


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
    InterruptCtrlMask = 21H;(* port address of mask-reg. in int.contr. *)
    CommCtrlLevel = 4;      (* level of communication interrupts inside
                               interrupt controller *)


    VAR
      commCtrlMasked, oldModemContrRegBit3 : BOOLEAN;
      terminated : BOOLEAN;
      workspace : ARRAY [0..100H] OF CARDINAL;
      mainP, receiverP : PROCESS;




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


  MODULE InterruptHandler [4];(********************************************)
    (* We execute the routines in this module at the priority of
       the asynchronous controller, to avoid a second interrupt
       while we treat the first one.
    *)
    FROM SYSTEM IMPORT INBYTE, OUTBYTE, BYTE,
		       PROCESS, TRANSFER, IOTRANSFER;
    IMPORT LineStatusReg, ReceiverReg, terminated, AsyncInterrupt,
           mainP, receiverP;

    EXPORT GetByte, Receiver, LineBusyRead;

    CONST
      BufferSize = 100H;


    VAR
      buffer : ARRAY [0..BufferSize-1] OF CHAR;
      xin, xout : CARDINAL;



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


    PROCEDURE Receiver;  (* coroutine *)
      VAR ch: CHAR; valid: BOOLEAN;
	  tempSet : BITSET;
	  interruptedP : PROCESS;
    BEGIN
      interruptedP := mainP;
      LOOP
	IOTRANSFER (receiverP, interruptedP, AsyncInterrupt);
	IF terminated THEN
	  TRANSFER (receiverP, interruptedP);
	END;
	(* we have received a character: *)
	LineBusyRead (ch, valid);
	IF valid THEN PutByte (ch) END;
      END; (* LOOP *)
    END Receiver;


  BEGIN
    xin := 0;  xout := 0;
    terminated := TRUE;
  END InterruptHandler;(*******************************************)



    PROCEDURE StartReading;
      VAR tempSet : BITSET; ch: CHAR; valid: BOOLEAN;
    BEGIN
      (* clear the modem controller: *)
      LineBusyRead (ch, valid);
      (* Start coroutine, which listens on the line for reception: *)
      NEWPROCESS (Receiver, ADR(workspace), SIZE(workspace) DIV 16,receiverP);
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

      (* set interrupt controller (8259) to accept interrupts
         from asynchronous communication controller: *)
      INBYTE (InterruptCtrlMask, ch);
      tempSet := BITSET(ORD(ch));
      commCtrlMasked := CommCtrlLevel IN tempSet;
      EXCL (tempSet, CommCtrlLevel);
      OUTBYTE (InterruptCtrlMask, CHR(CARDINAL(tempSet)));
    END StartReading;


    PROCEDURE StopReading;
      VAR tempSet : BITSET; ch: CHAR;
    BEGIN
      (* set interrupt controller (8259) to the state it was
         prior to 'StartReading' (as far as asynchronous
         communication controller is concerned): *)
      INBYTE (InterruptCtrlMask, ch);
      tempSet := BITSET(ORD(ch));
      IF commCtrlMasked THEN INCL (tempSet, CommCtrlLevel);
      ELSE EXCL (tempSet, CommCtrlLevel);
      END;
      OUTBYTE (InterruptCtrlMask, CHR(CARDINAL(tempSet)));

      terminated := TRUE;
      SWI (AsyncInterrupt);
      (* This interrupt causes the interrupt service routine (ISR)
	 to be executed a last time. Since the flag 'terminated' is
	 set, the ISR will just return. The effect is that there is
         no more active ISR in the Run-Time Support for 'AyncInterrupt'.
      *)

      DISABLE;
      (* disable interrupts in 8250: *)
      OUTBYTE (IntEnableReg, CHR(1H));
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
    END StopReading;


VAR done: BOOLEAN;

BEGIN
  Init (1200, 1, FALSE, FALSE, 8, done);
END RS232Int.
