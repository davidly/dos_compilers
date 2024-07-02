/* Copyright (C) 1985 by Manx Software Systems, Inc. */

#define RECORDSIZE	64

#define DBG_MAGIC		0x356e	/* Magic # for relative .dbg files */
#define	DBG_MAGICROM	0x4d53	/* Magic # for absolute .dbg files */
#define LINE_MAGIC		0x3039	/* Magic # for line number records */
#define BLOCK_MAGIC		0x3c48	/* Magic # for block records */
#define LOCAL_MAGIC		0x3c47	/* Magic # for symbol records */

#define LOCSIZE	6	/* # of local symbols per record */
#define BLKSIZE	6	/* # of blocks per record */
#define STRSIZE (RECORDSIZE/sizeof(struct structab)) /* # of structs/record */

struct dbgheader {
	short h_stsize;				/* 02 */ /* # of struct table entries */
	short h_stpos;				/* 04 */ /* record # for start of structs */
	short h_stgsize;			/* 06 */ /* # of string table entries */
	unsigned short h_stgbytes;	/* 08 */ /* total length of strings */
	short h_stgpos;				/* 0a */ /* record # for start of strings */
	short h_linerec;			/* 0c */ /* # of line # records */
	short h_blkrec;				/* 0e */ /* # of block records */
	short h_symrec;				/* 10 */ /* # of symbol table records */
	unsigned short h_abssym;	/* 12 */ /* symbol # of first absolute global */
	unsigned short h_codesym;	/* 14 */ /* symbol # of first code global */
	unsigned short h_datasym;	/* 16 */ /* symbol # of first data global */
};

struct structab {
	unsigned short st_tag;
	unsigned short st_size;
	unsigned short st_first;	/* first member contained in this struct */
	unsigned short st_last;		/* last member	"" */
};

/* macros for bit field stuff in localsym records for struct members */
#define FIELDPACK(pos, wid)	((pos)&0x7f | ((wid)&0x7f)<<8)
#define GETPOS(x)	((x)&0x7f)
#define GETWID(x)	((x)>>8 & 0x7f)

/* special flag values for ls_seg */
#define AUTOFLG	-2		/* auto-variable on the stack */
#define REGFLG	-3		/* Register variable */
#define ARGFLG	-4		/* function-parameter on the stack */
#define AREGFLG	-5		/* Register fucntion-parameter */
#define TDEFFLG	-6		/* Typedef */

struct localsym {
	unsigned short ls_name;
	unsigned short ls_type;
	short ls_struct;	/* for bit fields, pos and wid */
	short ls_offset;
	short ls_seg; 		/* see special flag values above */
	/* for struct members: 0 for standard members, !0 for bit fields */
};

struct block {
	short b_function;		/* function containing this block */
	unsigned short b_start;	/* start of block (relative to function start) */
	unsigned short b_end;	/* end of block */
	unsigned short b_first;	/* first local contained in this block */
	unsigned short b_last;	/* last local	"" */
};

#define LINEENTRY (RECORDSIZE-5*sizeof(short))

struct lineinfo {
	unsigned short l_offset, l_seg;
	unsigned short l_file;
	unsigned short l_lnum;
	unsigned char l_data[LINEENTRY];
};

/* codes in LINE info blocks */
#define NEXTREC	0xff	/* line info continues in the next line record */
#define EXTADDR	0x80	/* if bit on then 15 bit address increment */
#define EXTMAX	0x7f00	/* largest possible displacement + 1 */

#define db_blk	db_u.u_block
#define db_syms	db_u.u_syms
#define db_line db_u.u_line
#define db_head db_u.u_head

typedef struct {
	short db_magic;
	union {
		struct block u_block[BLKSIZE];
		struct localsym u_syms[LOCSIZE];
		struct lineinfo u_line;
		struct dbgheader u_head;
		char u_buffer[RECORDSIZE-sizeof(short)];
	} db_u;
} dbgrec;

/* type modifiers */
#define D_PTR	'*'
#define D_LPTR	'#'
#define D_ARRAY	'['
#define D_FUNC	'('
#define D_FFUNC '{'

/* base type values (always last char of type string) */
#define D_CHAR	'c'
#define D_UCHAR	'C'
#define D_INT	'i'
#define D_UINT	'I'
#define D_LONG	'l'
#define D_ULONG	'L'
#define D_FLOAT	'f'
#define D_DOUBLE 'd'
#define D_VOID	'v'
#define D_STRUCT ':'	/* type string is followed by struct # */

#define BASETYPES	"cCiIlLfdv:"
