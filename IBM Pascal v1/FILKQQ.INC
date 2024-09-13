{  IBM Personal Computer Pascal file control block  }
{    Version 1.00 (C) Copyright 1981 by IBM Corp    }

INTERFACE;  UNIT 
  FILKQQ (FCBFQQ, FILEMODES, SEQUENTIAL, TERMINAL, DIRECT,
          DEVICETYPE, CONSOLE, LDEVICE, DISK,
          DOSEXT, DOSFCB, FNLUQQ, SCTRLNTH);

CONST

  FNLUQQ = 21;		{ length of a DOS filename }
  SCTRLNTH = 512;	{ length of a disk sector }

TYPE

DOSEXT = RECORD		{ DOS file control block extension }

    PS  [0]: BYTE;	{ boundary byte, not in extension }
    FG  [1]: BYTE;	{ flag;  must be 255 in extension }
    XZ  [2]: ARRAY [0..4] OF BYTE;	{ padding, internal use }
    AB  [7]: BYTE;	{ attribute bits }

  END;

DOSFCB = RECORD		{ DOS file control block (normal) }

    DR  [0]: BYTE;	{ drive number, 0=def, 1=A etc }
    FN  [1]: STRING (8);	{ file name - 8 bytes }
    FT  [9]: STRING (3);	{ file extension - 3 bytes }
    EX [12]: BYTE;	{ current extent, lo byte }
    E2 [13]: BYTE;	{ current extent, hi byte }
    S2 [14]: BYTE;	{ sector size, lo byte }
    RC [15]: BYTE;	{ sector size, hi hyte (ext sect) }
    Z1 [16]: WORD;	{ file size, lo word;  readonly }
    Z2 [18]: WORD;	{ file size, hi word;  readonly }
    DA [20]: WORD;	{ date, bits DDDDDMMMMYYYYYYY }
    DN [16]: ARRAY [0..9] OF BYTE;	{ reserved for DOS }
    CR [32]: BYTE;	{ current sector within extent }
    RN [33]: WORD;	{ direct sector number lo word }
    R2 [35]: BYTE;	{ direct sector number hi byte }
    R3 [36]: BYTE;	{ hi byte (iff sect size < 64) }
    PD [37]: BYTE;	{ pad to a word boundary, not DOS }

  END;

DEVICETYPE = (CONSOLE, LDEVICE, DISK);
		{ physical device type }

FILEMODES = (SEQUENTIAL, TERMINAL, DIRECT);
		{ access mode for file }

FCBFQQ = RECORD     {byte offsets start every field comment}

{fields accessible by Pascal user as <file variable>.<field>}

TRAP: BOOLEAN;      {00 Pascal user trapping errors if true}
ERRS: WRD(0)..15;   {01 error status, set only by all units}
MODE: FILEMODES;    {02 user file mode;  not used in unit U}

{fields shared by units F, V, U;  ERRC is write-only}

MISC: BYTE;         {03 pad to word bound, unused, reserved} 
ERRC: WORD;         {04 error code, error exists if nonzero}
                        {1000..1099:  set for unit U errors}
                        {1100..1199:  set for unit F errors}
                        {1200..1299:  set for unit V errors}
ESTS: WORD;         {06 unused - reserved }
CMOD: FILEMODES;    {08 system file mode;  copied from MODE}

{fields set / used by units F and V, and read-only in unit U}

TXTF: BOOLEAN;      {09 true: formatted / ASCII / TEXT file}
                        {false: not formatted / binary file}
SIZE: WORD;         {10 record size set when file is opened}
                        {DIRECT: always fixed record length}
                        {others: max length (UPPER (BUFFA))}
MISB: WORD;         {12 unused - reserved }
OLDF: BOOLEAN;      {14 true: must exist before open; RESET}
                        {false: can create on open; REWRITE}
INPT: BOOLEAN;      {15 true: user is now reading from file}
                        {false: user is now writing to file}
RECL: WORD;         {16 DIRECT record number, lo order word}
RECH: WORD;         {18 DIRECT record number, hi order word}
USED: WORD;         {20 number bytes used in current record}

{field used internally by units F and V not needed by unit U}

LINK: ADR OF FCBFQQ;{22 DS offset address of next open file}

{fields used internally by unit F not needed by units V or U}

BADR: ADRMEM;       {24 ADR of buffer variable (end of FCB)}
TMPF: BOOLEAN;      {26 true if temp file;  delete on CLOSE}
FULL: BOOLEAN;      {27 buffer lazy evaluation status, TEXT}
MISA: BYTE;         {28 unused - reserved }
OPEN: BOOLEAN;      {29 file opened; RESET / REWRITE called}

{fields used internally by unit V not needed by units F or U}

FUNT: INTEGER;      {30 Unit V's unit number always above 0}
ENDF: BOOLEAN;      {32 Unit V's file-at-end operation flag}

{fields set / used by unit U, and read-only in units F and V}

REDY: BOOLEAN;      {33 reserved }
BCNT: WORD;         {34 number of data bytes actually moved}
EORF: BOOLEAN;      {36 true if end of record read, written}
EOFF: BOOLEAN;      {37 end of file flag set after EOF read}

     {unit U (operating system) information starts here}

NAME: LSTRING (FNLUQQ);	{ 38 DOS file name for this file }
DEVT: DEVICETYPE;	{ 60 type of device accessed by this file }
RDFC: BYTE;		{ 61 function code to read from a device }
WRFC: BYTE;		{ 62 function code to write to a device }
CHNG: BOOLEAN;		{ 63 true if data in sbuf was changed }
SPTR: WORD;		{ 64 pointer (index) into sbuf }
DOSX: DOSEXT;		{ 66 extended DOS file control block }
DOSF: DOSFCB;		{ 74 normal DOS file control block }
IEOF: BOOLEAN;		{112 true if eoff should be true next get }
FNER: BOOLEAN;		{113 true if a filename error has occured }
SBFL: BYTE;		{114 max length of textfile line in sbuf }
SBFC: BYTE;		{115 number of chars read into sbuf }
SBUF: ARRAY [WRD(0)..SCTRLNTH-1] OF BYTE;	{116 sector buffer }
PMET: ARRAY [0..5] OF BYTE;	{116 + sctrlnth: reserved pad }

BUFF: CHAR;		{ Pascal buffer variable, (component) }

     {end of section for unit U specific OS information}

END;
END;
