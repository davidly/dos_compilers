/* Copyright (C) 1990 by Manx Software Systems, Inc. - All rights reserved */

/*****************************************************************************
 OBJ86.H - Aztec 8086 Object Format definitions.
*****************************************************************************/

/*---------------------------------------------------------------------------
							OBJECT RECORD TYPES
---------------------------------------------------------------------------*/

#define SPECIAL	0xf0	/* Mask for primary loader codes */
#define SPEC2	0x00	/* Value of above mask for debug items */
#define EXTEND	0x0f	/* Shift-code for extended object records (2-bytes) */

/* PRIMARY LOADER ITEM SET */

#define THEEND	0x00	/* End of the object module */

/* Debugging information types */

#define BLOCKST	0x01	/* block start */
#define AUTOSYM	0x02	/* auto variable def */
#define ARGSYM	0x03	/* function argument def */
#define REGSYM	0x04	/* register variable def */
#define AREGSYM	0x05	/* register var argument */
#define STATSYM	0x06	/* static variable def */
#define FILESYM	0x07	/* file scope static var def */
#define GBLTYPE	0x08	/* global variable type info */
#define TDEFSYM	0x09	/* typedef name */
#define STRCTAG	0x0a	/* structure tag definition */
#define STRCDEF	0x0b	/* start of structure definition */
#define SETFILE 0x0c	/* set working file name for line table */
#define SETLINE 0x0d	/* set current line # */

/* 0x0f reserved for EXTEND shift-code */

/* 'Normal' loader items (may use lower nybble for data) */

#define ABSDATA	0x10	/* Raw data items */
#define EXPR	0x20	/* Expression to follow */
#define SMLINT	0x30	/* Small sized integer (generally part of an EXPR) */
#define SMLNEG	0x40	/* Small sized neg int (generally part of an EXPR) */
#define MEDINT	0x50	/* Medium sized integer (generally part of an EXPR) */
#define LCLSYM	0x60	/* Unnamed symbol reference (ex: $20000) */
#define GBLSYM	0x70	/* Named symbol reference */
#define SPACE	0x80	/* Blank space (dup (?) in assembly) */
#define USECOMN	0x90	/* Switch current segment */
#define CODEREF	0xa0	/* Code reference w/ small offset */
#define DATAREF 0xb0	/* Data reference w/ small offset */
#define BSSREF	0xc0	/* BSS reference w/ small offset */
#define SEGREL	0xd0	/* General segment relative reference */

/* 'Special' loader items (use lower nybble for type code) */

#define DATASEG	0xf0	/* para # of data segment */
#define BEXPR	0xf1	/* Fixup modifier - byte-sized absolute ref */
#define BREL	0xf2	/* Fixup modifier - byte-sized self-relative ref */
#define LRGINT	0xf3	/* Large-sized integer (generally part of an EXPR) */
#define USECODE	0xf4	/* Switch to code segment */
#define USEDATA	0xf5	/* Switch to data segment */
#define STARTAD	0xf6	/* Specify starting address of program */
#define LRGCODE 0xf7	/* Code reference w/ large offset */
#define LRGDATA 0xf8	/* Data reference w/ large offset */
#define INTJSR	0xf9	/* interpreter call instruction (unused on 8086) */
#define WREL	0xfa	/* Fixup modifier - word-sized self-relative ref */
#define LRGBSS	0xfb	/* BSS reference w/ large offset */
#define HUGINT	0xfc	/* Really-large-sized int (generally part of an EXPR) */
#define LEXPR	0xfd	/* Fixup modifier - 32-bit absolute reference */
#define CODESEG	0xfe	/* para # of code segment */
#define NLINE	0xff	/* Increment source code line counter by one */

/*
   If no Fixup modifier is specified (BREL, BEXPR, etc.) then word-sized
   absolute is assumed.
*/

/* EXTENDED LOADER ITEM SET */

/*
	Extended loader item set (Selected by loader item EXTEND)
	Codes 01->3f in the extended set are reserved as normal 1-byte IDs
	Codes 40->f0 in the extended set are reserved as high-nybble IDs, with
	the low nybble usable for data.
*/
#define ORIGIN		0x01	/* Set location to an abs off w/in current seg */

/* LOW-NYBBLE OBJECT RECORD INFORMATION */

/* within STRCDEF the following are used */
#define MEMBDEF		0x01	/* structure member info */
#define FLDDEF		0x02	/* bit field member */

/* low nibble of EXPR item (operators) */
#define ADD	1
#define SUB	2
#define MUL	3
#define DIV	4
#define MOD	5
#define AND	6
#define OR	7
#define XOR	8
#define RSH	9
#define LSH	10
#define NOT	11 /* must be the first unary op, and only unarys may follow */
#define NEG	12
#define OHIGH 13
#define OLOW 14
#define OSEG 15

/*---------------------------------------------------------------------------
							MODULE MAGIC NUMBERS
---------------------------------------------------------------------------*/

#define M_MAGIC		0x5466				/* Small code object module */
#define M_LMAGIC	0x020c				/* Large code object module */
#define M_OVROOT	((short)0xcf56)		/* Root symbol table (overlay) */
#define M_LIBRARY	((short)0xec62)		/* Object code library */

/*---------------------------------------------------------------------------
					  LIBRARY AND MODULE HEADER RECORDS
---------------------------------------------------------------------------*/

/* Header record for an object module */
struct module {
	short m_magic;			/* magic number for object files */
	char m_name[8];			/* module name */
	unsigned short m_code;	/* size of code in this module */
	unsigned short m_data;	/* size of data in this module */
	unsigned short m_static;/* size of static storage (bss) in this module */
	unsigned short m_global;/* offset of start of global symbols */
	short m_nglobal;		/* # of global symbols */
	unsigned short m_local;	/* offset of start of local symbols */
	short m_nlocal;			/* # of local symbols */
	unsigned short m_end;	/* end of local symbols */
	unsigned short m_next;	/* offset of next module in this file */
	unsigned short m_nfix;	/* number of segment fixes required */
};

#define LBSIZE (2048-2*sizeof(short))

/* Header record for a library file */
struct newlib {
	short nl_magic;		/* magic number for library files */
	unsigned short nl_next;	/* location of next dictionary block */
	char nl_dict[LBSIZE];		/* dictionary buffer */
	/* the format of the dictionary is:
		two bytes - (position of module defining symbol) / 128
		nul terminated string - name of symbol
	*/
};

/*---------------------------------------------------------------------------
					  NAMED AND UNNAMED SYMBOL STRUCTURE
---------------------------------------------------------------------------*/

struct symtab {
	char s_type,s_flags;
	unsigned short s_value;
};

/*
	symbol table entry is followed by a segment or group # if the SF_HAVSEG
	flag is set.

	Global symbols are followed by a nul terminated string which is the
	name of the symbol.
*/

/*---------------------------------------------------------------------------
					  SYMBOL TYPES AND FLAGS
---------------------------------------------------------------------------*/

/* S_TYPE FIELD VALUES FOR SYMBOLS/SEGMENTS */
#define S_ABS		1		/* Equ-type absolute symbols & abs segments */
#define S_CODE		2		/* Item in code segment */
#define S_DATA		3		/* Item in data segment */
#define S_COMN		4		/* common segment (obsolete) */
#define S_CMNREF	5		/* Item in a general segment */

#define S_ROOTSYM	6		/* used by DOS linker to tag root symbols */
#define S_ABSOLUTE	6		/* used by ROM linker to designate absolute syms */

#define S_EXPR		6		/* Used internally by assembler */
#define S_UND		7		/* Symbol is undefined or BSS */
#define S_WEAK		8		/* Currently unused */
#define S_BSS		9		/* Symbol is BSS */
#define S_GROUP		10		/* Group */
#define S_PSEG		11		/* public segment */
#define S_SSEG		12		/* stack segment */
#define S_MSEG		13		/* memory segment */
#define S_CSEG		14		/* common segment (new form) */
#define S_CLASS		15		/* segment class name */

#define ST_TYPE		0x0f	/* Mask for type portion of a symbol */

/* S_TYPE FIELD MODIFIERS (SEGMENTS) */

#define ST_ALIGN	0x70	/* Mask for alignment type (for segments) */

#define ST_BYTE		0x00	/* alignment boundarys (byte) */
#define ST_WORD		0x10	/* even */
#define ST_PARA		0x20	/* 16-byte */
#define ST_PAGE		0x30	/* 256-byte */
#define ST_INPAGE	0x40	/* Must fit completely within 256 byte page */
#define	ST_ABSSEG	0x70	/* segment @ absolute address */
#define ST_BIGSEG	0x80	/* set for 64k segment */

/* S_FLAGS FIELD VALUES (MIXED SEGMENT/NON-SEGMENT) */

#define SF_HAVEAT	0x01	/* Segment followed by par # (seg only) */
#define SF_HAVTYPE	0x01	/* symbol is followed by type info (sym only) */

#define SF_DATAREF	0x02	/* used for dataseg references */
#define SF_HAVCLAS	0x04	/* symbol is followed by class index */
#define SF_GLOBL 	0x08	/* symbol is public/extern */
#define SF_HAVSEG	0x10	/* symbol is followed by segment/group # */
#define SF_OVSYM	0x20	/* overlay symbol */
#define S_FIXED		0x40
#define S_UNNAMED	0x80

/*
						TYPICAL DATA DECLATAIONS
						------------------------

	extern code:
		    Declaration: extern int func();
				 s_type: S_UND
				s_flags: S_FIXED | SF_GLOBL
				s_value: always 0

	defined code:
		    Declaration: int func() { }
				 s_type: S_CODE
				s_flags: S_FIXED | SF_GLOBL
				s_value: offset from the base of the module's code segment

	extern data:
		    Declaration: extern int an_int;
				 s_type: S_UND
				s_flags: S_FIXED | SF_GLOBL
				s_value: always 0

	defined BSS data:
		    Declaration: int an_int;
				 s_type: S_DATA
				s_flags: S_FIXED | SF_GLOBL | SF_DATAREF
				s_value: size of the object

	defined init data:
		    Declaration: int an_int = 5;
				 s_type: S_DATA
				s_flags: S_FIXED | SF_GLOBL | SF_DATAREF
				s_value: offset from the base of the module's data segment

*/
