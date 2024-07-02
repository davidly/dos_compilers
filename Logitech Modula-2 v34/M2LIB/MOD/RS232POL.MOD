(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*	  Library module to read and write over the RS-232		   *)
(*	  asynchronous serial port.					   *)
(*	  This implementation does NOT work with interrupts,		   *)
(*	  so it is the responsability of the user to poll (i.e		   *)
(*	  call 'Read' or 'BusyRead') frequently enough to		   *)
(*	  ensure that no characters are lost on reception.		   *)
(*	  Automatic initialization at the beginning sets		   *)
(*	  the following parameters:					   *)
(*	      baudRate = 9600, stopBits = 1,				   *)
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
IMPLEMENTATION MODULE RS232Polling;		(* WS *)

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

  BEGIN
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

                       

  PROCEDURE BusyRead (VAR ch: CHAR; VAR received: BOOLEAN);
    (* If a character has been received, it is read and assigned to 'ch'
       and 'received' is set to TRUE. If no character has been received,
       'ch' is set to 0C and 'received' is set to FALSE.
    *)       
    VAR status: BITSET;
  BEGIN
    received := FALSE;
    ch := 0C;
    INBYTE (LineStatusReg, status);
    IF 0 IN status THEN
      INBYTE (ReceiverReg, ch);
      received := TRUE;
    END;
  END BusyRead;


  PROCEDURE Read (VAR ch: CHAR);
    (* Reads a character from the port and returns it in 'ch'.
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
      IF status * {5,6} = {5,6} THEN
        (* transmitter holding register and Tx shift register empty *)
        EXIT;
      END;
    END;
    OUTBYTE (TransmitReg, ch);
  END Write;


  VAR done: BOOLEAN;

BEGIN
  Init (9600, 1, FALSE, FALSE, 8, done);

  (* Define Modem Control parameters: *)
  OUTBYTE (ModemContrReg, 3H); (* set DTR and RTS signals on
                                  output to logical 0  *)

  (* Disable Interrupts: *)
  OUTBYTE (IntEnableReg, 0H);

END RS232Polling.
