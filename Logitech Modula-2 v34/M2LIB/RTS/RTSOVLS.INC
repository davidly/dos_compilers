;******************************************************************************
;
;       MODULA-2    Run-Time Support   ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    OverlayDescriptor definition for the RTS
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
;----- Overlay descriptor

DD_KeySize        EQU 6
DD_NameSize       EQU 40
DD_UnusedSpace    EQU 4*8

DD_CheckwordValue EQU 6C8DH

DD_DRIVER_KEY     EQU 0                       ; Driver key (from compiler)
DD_DRIVER_NAME    EQU DD_DRIVER_KEY+DD_KeySize
DD_CHECKWORD      EQU DD_DRIVER_NAME+DD_NameSize

DD_MEMORY_ADDR    EQU DD_CHECKWORD+2
                                              ; address of allocated block
DD_MEMORY_SIZE    EQU DD_MEMORY_ADDR+4        ; size of allocated block
DD_CODE_SEGMENT   EQU DD_MEMORY_SIZE+2        ; first para. nr of loaded code

DD_PROG_ID        EQU DD_CODE_SEGMENT+2       ; Unique driver ID
DD_TERM_PROC      EQU DD_PROG_ID+2            ; Termination proc. list
DD_INIT_PROC      EQU DD_TERM_PROC+4          ; Initialization proc. list
DD_FREE_LIST      EQU DD_INIT_PROC+4          ; Free list of proc entries

DD_NEXT           EQU DD_FREE_LIST+4          ; list links
DD_PREVIOUS       EQU DD_NEXT+4

DD_OVERLAY        EQU DD_PREVIOUS+4           ; Kind of loaded code:
                                              ;   0 for a driver
                                              ;   1 for an overlay

DD_LOADER_PROCESS EQU DD_OVERLAY+2            ; loader process

; information saved at load time
DD_PRIO_MASK      EQU DD_LOADER_PROCESS+4
DD_SP             EQU DD_PRIO_MASK+2
DD_SS             EQU DD_SP+2
DD_BP             EQU DD_SS+2

DD_OVL_STATUS     EQU DD_BP+2

; links (not yet used)
DD_FATHER         EQU DD_OVL_STATUS+2
DD_PARENT         EQU DD_FATHER+4
DD_PROCESS_LIST   EQU DD_PARENT+4

; allocated resources
DD_RESOURCE       EQU DD_PROCESS_LIST+4
; reserved space
DD_UNUSED         EQU DD_RESOURCE+4

DRIVER_DESCR_SIZE EQU DD_UNUSED+DD_UnusedSpace
