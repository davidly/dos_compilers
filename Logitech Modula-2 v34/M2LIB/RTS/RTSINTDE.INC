;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    - Definition of InterruptDescriptor
;
;       Release :    3.10 - July 89
;
;       Copyright (C)  1987 - 1989 Logitech, All rights reserved
;
;       Permission is hereby granted to registered users to use or abstract
;       the following program in the implementation of customized versions.
;       This permission does not include the right to redistribute the source
;       code of this program.
;
;       History:
;          Jul-87:      Original version
;       05-May-88/akg:  Version 3.05
;       04-Jul-89/akg:  Version 3.10 (no changes).
;
;******************************************************************************

ID_OWNER       EQU     0             ; SS of process or link if empty
ID_OLDISR      EQU     ID_OWNER + 2  ; here we save the old isr
ID_SAVEI       EQU     ID_OLDISR + 4 ; addr of pointer to interrupted process
ID_INTOFF      EQU     ID_SAVEI + 4  ; offset of the interrupt vector
ID_INSTALLED   EQU     ID_INTOFF + 2 ; flag : 1 = installed, 0 = iotransfer
                                     ; !!! by default must be 0

ID_LENGTH      EQU     ID_INSTALLED + 1 

