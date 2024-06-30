/**
*
* This header file supplies information needed to interface with the
* particular operating system and C compiler being used.
*
**/


/**
*
* The following symbols define which processor is being used.
*
*	I8080		Intel 8080
*	I8085		Intel 8085
*	Z80		Zilog Z80
*	I8086		Intel 8086 or 8088
*	M68000		Motorola 68000
*	GA16		General Automation 16-bit mini
*	IBMPC		IBM Personal Computer (also sets I8086)
*/
#define IBMPC 1

#ifdef IBMPC
#define I8086 1
#endif

#ifdef I8086
#include "m8086.h"
#endif

/**
*
* The following symbols specify which operating system is being used.
*
*	CPM		Any CP/M OS
*	CPM80		CP/M for Intel 8080 or Zilog Z80
*	CPM86		CP/M for Intel 8086
*	CPM68		CP/M for Motorola 68000
*	MSDOS		Microsoft's MSDOS
*	MSDOS1		MSDOS Version 1 (also sets MSDOS)
*	MSDOS2		MSDOS Version 2 (also sets MSDOS)
*
* Note: CPM will be set to 1 for any of the above.
*
*	UNIX		"Standard" UNIX
*	QUNIX		Quantum's QUNIX OS
*	MIBS		General Automation's MIBS OS
*	OASIS		OASIS OS
*	PICK		PICK OS
*
*/
#define MSDOS 1

#ifdef MSDOS
#include "msdos.h"
#endif

#ifdef CPM80
#define CPM 1
#endif
#ifdef CPM86
#define CPM 1
#endif
#ifdef CPM68
#define CPM 1
#endif
#ifdef MSDOS
#define CPM 1
#endif


/**
*
* The following definitions specify the particular C compiler being used.
*
*	LATTICE		Lattice C compiler
*	BDS		BDS C compiler
*	BTL		Bell Labs C compiler or equivalent
*	MANX		MANX Aztec C compiler
*
*/
#define LATTICE 1



/**
*
* The following type definitions take care of the particularly nasty
* machine dependency caused by the unspecified handling of sign extension
* in the C language.  When converting "char" to "int" some compilers
* will extend the sign, while others will not.  Both are correct, and
* the unsuspecting programmer is the loser.  For situations where it
* matters, the new type "byte" is equivalent to "unsigned char".
*
*/
#ifdef LATTICE
typedef char byte;
#endif

#ifdef BDS
#define byte char
#endif

#ifdef BTL
typedef unsigned char byte;
#endif

#ifdef MANX
#define byte char
#endif

/**
*
* Miscellaneous definitions
*
*/
#define SECSIZ 128		/* disk sector size */
#ifdef CPM
#define DMA (char *)0x80	/* disk buffer address */
#endif

/**
*
* The following structure is a File Control Block.  Operating systems
* with CPM-like characteristics use the FCB to store information about
* a file while it is open.
*
*/
struct FCB
	{
	char fcbdrv;		/* drive code */
	char fcbnam[8];		/* file name */
	char fcbext[3];		/* file name extension */
#ifdef MSDOS
	short fcbcb;		/* current block number */
	short fcblrs;		/* logical record size */
	long fcblfs;		/* logical file size */
	short fcbdat;		/* create/change date */
	char fcbsys[10];	/* reserved */
	char fcbcr;		/* current record number */
	long fcbrec;		/* random record number */
#else
	char fcbexn;		/* extent number */
	char fcbs1;		/* reserved */
	char fcbs2;		/* reserved */
	char fcbrc;		/* record count */
	char fcbsys[16];	/* reserved */
	char fcbcr;		/* current record number */
	short fcbrec;		/* random record number */
	char fcbovf;		/* random record overflow */
#endif
	};

#define FCBSIZ sizeof(struct FCB)

/**
*
* The following symbols define the sizes of file names and node names.
*
*/
#ifdef CPM
#define FNSIZE 16	/* maximum file node name size */
#define FMSIZE 16	/* maximum file name size */
#endif

#ifdef MSDOS2
#define FNSIZE 16
#define FMSIZE 64
#endif

#ifdef UNIX
#define FNSIZE 16	
#define FMSIZE 64
#endif


/**
*
* The following structures define the 8086 registers that are passed to
* various low-level operating system service functions.
*
*/
#ifdef I8086
struct XREG
	{
	short ax,bx,cx,dx,si,di;
	};

struct HREG
	{
	byte al,ah,bl,bh,cl,ch,dl,dh;
	};

union REGS
	{
	struct XREG x;
	struct HREG h;
	};

struct SREGS
	{
	short es,cs,ss,ds;
	};
#endif

/**
*
* The following symbols define the code numbers for the various service
* functions.
*
*/
#ifdef MSDOS
#define SVC_DATE 0x2a		/* get date */
#define SVC_TIME 0x2c		/* get time */
#endif

/**
*
* The following codes are used to open files in various modes.
*
*/
#ifdef LATTICE
#define OPENR 0x8000		/* open for reading */
#define OPENW 0x8001		/* open for writing */
#define OPENU 0x8002		/* open for read/write */
#define OPENC 0x8001		/* create and open for writing */
#else 
#define OPENR 0
#define OPENW 1
#define OPENU 2
#endif

/**
*
* The following codes are returned by the low-level operating system service
* calls.  They are usually placed into _oserr by the OS interface functions.
*
*/
#if MSDOS2
#define E_FUNC 1		/* invalid function code */
#define E_FNF 2			/* file not found */
#define E_PNF 3			/* path not found */
#define E_NMH 4	 		/* no more file handles */
#define E_ACC 5			/* access denied */
#define E_IFH 6			/* invalid file handle */
#define E_MCB 7			/* memory control block problem */
#define E_MEM 8			/* insufficient memory */
#define E_MBA 9			/* invalid memory block address */
#define E_ENV 10		/* invalid environment */
#define E_FMT 11		/* invalid format */
#define E_IAC 12		/* invalid access code */
#define E_DATA 13		/* invalid data */
#define E_DRV 15		/* invalid drive code */
#define E_RMV 16		/* remove denied */
#define E_DEV 17		/* invalid device */
#define E_NMF 18		/* no more files */
#endif
