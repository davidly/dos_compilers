(*
    Copyrigth (C) 1984 Logitech. All Rights Reserved.

    Permission is hereby granted to registered users to use or
    abstract the following program in the implementation of
    customized versions. This permission does not include the
    right to redistribute the source code of this program.
*)
(*$R- *)
(*$T- *)
(********************************************************************)
(*                                                                  *)
(*     MODULA-2 / 86                                                *)
(*                                                                  *)
(*     RS232:                                                       *)
(*          Library module to read and write over the RS-232        *)
(*          asynchronous serial port.                               *)
(*          This implementation does NOT work with interrupts,      *)
(*          so it is the responsability of the user to poll (i.e    *)
(*          call 'Read' or 'BusyRead') frequently enough to ensure  *)
(*          that no characters are lost on reception.               *)
(*          Automatic initialization sets the following parameters: *)
(*            baudRate = 9600, stopBits = 1,                        *)
(*            parityBit = FALSE, evenParity = don't care,           *)
(*            nbrOfBits = 8                                         *)
(*                                                                  *)
(*     History:                                                     *)
(*          May 26 83   First revision (0.0-260583)                 *)
(*          July 8 83   Version 0.1 - 07.07.83                      *)
(*     Version:                                                     *)
(*          IBM-PC                                                  *)
(*     Author:                                                      *)
(*          Willy Steiger                                           *)
(*          LOGITECH SA.                                            *)
(*          CH-1143 Apples   (Switzerland)                          *)
(*                                                                  *)
(********************************************************************)

IMPLEMENTATION MODULE RS232Polling;

FROM SYSTEM IMPORT INBYTE, OUTBYTE;

  CONST
    LineContrReg = 3FBH;    (* to specify format of transmitted data *)
    LowBaudRateDiv = 3F8H;  (* lower byte of divisor to select baud rate *)
    HighBaudRateDiv = 3F9H; (* higher byte of divisor *)
    LineStatusReg = 3FDH;   (* holds status info on the data transfer *)
    ReceiverReg = 3F8H;     (* received char is in this register *)
    TransmitReg = 3F8H;     (* char to send is to put in this reg *)
    IntEnableReg = 3F9H;    (* to enable the selected interrupt *)



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

    (* Disable Interrupts: *)
    OUTBYTE (IntEnableReg, 0H);

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
      INBYTE (ReceiverReg, status);
      ch := CHR (CARDINAL(status));
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
      IF 5 IN status THEN EXIT END;
    END;
    OUTBYTE (TransmitReg, ORD(ch));
  END Write;


(* To use the RS232 without interrupts, we have to turn off the
   updating of the time on the screen. To do this, we can set
   the corresponding Interrupt Vector (1CH) to point to a dummy
   Interrupt Service Routine. Such a routine is included here
   for illustration. The vector should actually be saved and
   restored in the program that uses this module, since 'RS232Polling'
   doe not know, when the transmittion is terminated and can
   therefore not restore that vector.


  VAR saveVector: PROC;
      vector1C[112]: PROC; (* at address 1CH * 4 *)


  PROCEDURE DummyISR;
    (* Used to disable the updating of the time on the screen. *)
    CONST
      I8259ContrWord2 = 20H;
      EndOfInterrupt = 20H;
      PopBP = 5DH;
      IRET  = 0CFH;
  BEGIN
    OUTBYTE (I8259ContrWord2, EndOfInterrupt);
    CODE (PopBP); (* simulate a procedure exit *)
    CODE (IRET);  (* return from interrupt service routine *)
  END DummyISR;
*)

  VAR done: BOOLEAN;

BEGIN
  Init (9600, 1, FALSE, FALSE, 8, done);
(* In the program that uses this module, the interrupt vector 1CH
   should be saved and restored after termination of the transmition.
   During transmition, that vector should point to a dummy Interrupt
   Service Routine:
  saveVector := vector1CH;
  vector1CH := DummyISR;
*)
END RS232Polling.
