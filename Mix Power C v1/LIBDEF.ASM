;
; Definitions for Power C assembly language library functions
;    Copyright (c) Mix Software 1988
;
LONGNAME EQU  >FFFF           ; include long (>8 character) names
SHORTNAM EQU  >0              ; include short (8 character) names
UPPER    EQU  >0              ; include uppercase names
;
;  Parameter offsets for large memory
;
PARMORG  EQU  >6              ; offset to parameters
PARM1    EQU  PARMORG         ; offset of first word parameter (c)
PARM2    EQU  PARMORG+2
PARM3    EQU  PARMORG+4
PARM4    EQU  PARMORG+6
PARM5    EQU  PARMORG+8
PARM6    EQU  PARMORG+10
;
;    typedef struct {
;        char      init;      { initialized flag }
;        char      openflg;   { file open }
;        int       handle;    { file handle }
;        char      *bufr;     { start of buffer }
;        char      *ptr;      { address of next character }
;        int       count;     { number of characters left in bufr }
;        int       bufsize;   { size of buffer }
;        int       reclen;    { record length }
;        char      device;    { device code }
;        char      eofflag;   { end of file detected }
;        char      mode;      { read, write or read/write }
;        char      dirty;     { buffer written to }
;        char      error;     { error code }
;        union  {
;            char   flagbyte;
;            struct {
;               unsigned  noblank : 1 ;
;               unsigned  binary  : 1 ;
;               unsigned  ctlz    : 1 ;
;               unsigned  filter  : 1 ;
;               unsigned  echo    : 1 ;
;               unsigned  unbufr  : 1 ;
;               unsigned  fill    : 2 ;
;               } flagbits;
;             } flags;
;        char      column;    { column (text files }
;        char      fill1;
;        char      *gpbufr;   { buffer used by get & put }
;        char      *pathnm;   { name of file }
;        char      fill2[6];
;        } fdb;
;
;   FILE DESCRIPTOR DISPLACEMENTS
;
FD$INIT  EQU  0               ; File initialized if non-zero
FD$OPEN  EQU  1               ; File open if non-zero
FD$HNDL  EQU  2               ; File handle
FD$BUFR  EQU  4               ; Address of buffer
FD$PTR   EQU  6               ; Pointer to next character in buffer
FD$COUNT EQU  8               ; remaining characters in buffer
FD$BUFSZ EQU  10              ; Size of buffer
FD$RECLN EQU  12              ; Record length (pascal only) (-1 for text)
FD$DEV   EQU  14              ; DISK OR DEVICE
FD$EOF   EQU  15              ; At end of file
FD$MODE  EQU  16              ; Read, Write or read/write
FD$DIRTY EQU  17              ; Buffer has been written to
FL$READ  EQU  >02             ; Buffer has been read
FL$WRITE EQU  >01             ; Buffer has been written
FD$ERR   EQU  18              ; error code
FD$FLAGS EQU  19              ; flags for console
FL$NOBL  EQU  >01             ;     Flag bit for no blank
FL$BIN   EQU  >02             ;     Flag bit for binary file
FL$CTLZ  EQU  >04             ;     Flag bit for ctl/z = eof
FL$LFEED EQU  >08             ;     Flag bit for filter line feed
FL$ECHO  EQU  >10             ;     Flag bit for echo to console
FL$UNBUF EQU  >20             ;     Flag bit for unbuffered
FL$APPEN EQU  >40             ;     Flag bit for append mode
FL$SETBF EQU  >80             ;     Flag bit for external buffer
FD$COL   EQU  20              ; current column
FD$GPBUF EQU  22              ; buffer for get & put
FD$PATH  EQU  24              ; Pointer to path string
FD$SIZE  EQU  32              ; size of file descriptor
;
DV$LST   EQU  26
DV$CON   EQU  27
DV$DMY   EQU  28
;
;
; ---------------------------------------------------
;    CODES FOR FATAL ERRORS
;
E$STACK  EQU  >81             ; STACK OVERFLOW
E$HEAP   EQU  >82             ; HEAP EXHAUSTED
E$PACKET EQU  >83             ; INVALID PACKET POINTER
E$LEVEL  EQU  >84             ; INVALID STATIC LEVEL
E$DIVZ   EQU  >85             ; DIVIDE BY ZERO
E$NOINS  EQU  >86             ; INSTRUCTION NOT IMPLEMENTED
E$SET    EQU  >87             ; SETS NOT COMPATIBLE
E$IERR   EQU  >88             ; UNDEFINED INTERNAL PROCEDURE
E$IOERR  EQU  >89             ; IO ERROR
E$SETIX  EQU  >8A             ; SET INDEX OUT OF RANGE
E$WERR   EQU  >8B             ; WRITE TO INPUT FILE
E$NOTOPEN EQU >8C             ; FILE NOT OPEN
E$GPERR  EQU  >8D             ; GET, PUT FOR TEXT ONLY
E$OPEN   EQU  0ECH            ; FILE NOT OPEN
E$READ   EQU  0EDH            ; FILE NOT OPEN FOR READING
E$WRIT   EQU  0EBH            ; FILE NOT OPEN FOR WRITING
E$NOHEAP EQU  0EEH            ; NO HEAP FOR FILE BUFFER
E$PASTEN EQU  >99
E$NOSPAC EQU  >9A
;
EOFCHR   EQU  >1A
;
EZERO    EQU    0
EPERM    EQU    1
ENOENT   EQU    2
ESRCH    EQU    3
EINTR    EQU    4
EIO      EQU    5
ENXIO    EQU    6
E2BIG    EQU    7
ENOEXEC  EQU    8
EBADF    EQU    9
ECHILD   EQU   10
EAGAIN   EQU   11
ENOMEM   EQU   12
EACCES   EQU   13
EFAULT   EQU   14
ENOTBLK  EQU   15
EBUSY    EQU   16
EEXIST   EQU   17
EXDEV    EQU   18
ENODEV   EQU   19
ENOTDIR  EQU   20
EISDIR   EQU   21
EINVAL   EQU   22
ENFILE   EQU   23
EMFILE   EQU   24
ENOTTY   EQU   25
ETXTBSY  EQU   26
EFBIG    EQU   27
ENOSPC   EQU   28
ESPIPE   EQU   29
EROFS    EQU   30
EMLINK   EQU   31
EPIPE    EQU   32
EDOM     EQU   33
ERANGE   EQU   34
EUCLEAN  EQU   35
EDEADLOCK EQU   36
;
