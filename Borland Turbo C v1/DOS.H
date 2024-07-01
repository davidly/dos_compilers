/*	dos.h

	Defines structs, unions, macros, and functions for dealing
	with MSDOS and the Intel iAPX86 microprocessor family.

	Copyright (c) Borland International 1987
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

	/* Variables */

extern	unsigned int	_Cdecl	 _psp;
extern	char		**_Cdecl environ;
extern	unsigned int	_Cdecl	 _version;
extern	unsigned char	_Cdecl	 _osmajor;
extern	unsigned char	_Cdecl	 _osminor;
extern	int		_Cdecl	 _doserrno;

#define FA_RDONLY	0x01		/* Read only attribute */
#define FA_HIDDEN	0x02		/* Hidden file */
#define FA_SYSTEM	0x04		/* System file */
#define FA_LABEL	0x08		/* Volume label */
#define FA_DIREC	0x10		/* Directory */
#define FA_ARCH		0x20		/* Archive */

#define NFDS	20			/* Maximum number of fds */

struct	fcb	{
	char	fcb_drive;		/* 0 = default, 1 = A, 2 = B */
	char	fcb_name[8];		/* File name */
	char	fcb_ext[3];		/* File extension */
	short	fcb_curblk;		/* Current block number */
	short	fcb_recsize;		/* Logical record size in bytes */
	long	fcb_filsize;		/* File size in bytes */
	short	fcb_date;		/* Date file was last written */
	char	fcb_resv[10];		/* Reserved for DOS */
	char	fcb_currec;		/* Current record in block */
	long	fcb_random;		/* Random record number */
	};

struct	xfcb	{
	char		xfcb_flag;	/* Contains 0xff to indicate xfcb */
	char		xfcb_resv[5];	/* Reserved for DOS */
	char		xfcb_attr;	/* Search attribute */
	struct	fcb	xfcb_fcb;	/* The standard fcb */
	};

struct	country {
	int	co_date;
	char	co_curr[5];
	char	co_thsep[2];
	char	co_desep[2];
	char	co_dtsep[2];
	char	co_tmsep[2];
	char	co_currstyle;
	char	co_digits;
	long	co_case;
	char	co_dasep;
	char	co_fill[10];
	};

struct	DOSERROR {
	int	exterror;
	char	class;
	char	action;
	char	locus;
	};

struct	dfree	{
	unsigned df_avail;
	unsigned df_total;
	unsigned df_bsec;
	unsigned df_sclus;
	};

struct	fatinfo {
	char	fi_sclus;
	char	fi_fatid;
	int	fi_nclus;
	int	fi_bysec;
	};

struct	devhdr	{
	long		dh_next;	/* Next device pointer */
	short		dh_attr;	/* Attributes */
	unsigned short	dh_strat;	/* Driver strategy routine */
	unsigned short	dh_inter;	/* Driver interrupt routine */
	char		dh_name[8];	/* Device name */
	};

struct	time	{
	unsigned char	ti_min;		/* Minutes */
	unsigned char	ti_hour;	/* Hours */
	unsigned char	ti_hund;	/* Hundredths of seconds */
	unsigned char	ti_sec;		/* Seconds */
	};

struct	date	{
	int		da_year;	/* Year - 1980 */
	char		da_day;		/* Day of the month */
	char		da_mon;		/* Month (1 = Jan) */
	};

struct WORDREGS
	{
	unsigned int	ax, bx, cx, dx, si, di, cflag, flags;
	};

struct BYTEREGS
	{
	unsigned char	al, ah, bl, bh, cl, ch, dl, dh;
	};

union	REGS	{
	struct	WORDREGS x;
	struct	BYTEREGS h;
	};

struct	SREGS	{
	unsigned int	es;
	unsigned int	cs;
	unsigned int	ss;
	unsigned int	ds;
	};

struct	REGPACK
	{
	unsigned	r_ax, r_bx, r_cx, r_dx;
	unsigned	r_bp, r_si, r_di, r_ds, r_es, r_flags;
	};

#define FP_OFF(fp)	((unsigned)(fp))
#define FP_SEG(fp)	((unsigned)((unsigned long)(fp) >> 16))


typedef struct
{
	char	drive;		/* do not change	*/
	char	pattern [13];	/*  these fields,	*/
	char	reserved [7];	/*   Microsoft reserved */
	char	attrib;
	short	time;
	short	date;
	long	size;
	char	nameZ [13];	/* result of the search, asciiz */
}
	dosSearchInfo;	/* used with DOS functions 4E, 4F	*/


int	 _Cdecl absread(int drive, int nsects, int lsect, void *buffer);
int	 _Cdecl abswrite(int drive, int nsects, int lsect, void *buffer);
int	 _Cdecl allocmem(unsigned size, unsigned *segp);
int	 _Cdecl bdos(int dosfun, unsigned dosdx, unsigned dosal);
int	 _Cdecl bdosptr(int dosfun, void *argument, unsigned dosal);
struct	country *_Cdecl country(int xcode, struct country *cp);
void	 _Cdecl ctrlbrk(int (*fptr)(void));
int	 _Cdecl dosexterr(struct DOSERROR *eblkp);
long	 _Cdecl dostounix(struct date *d, struct time *t);
int	 _Cdecl freemem(unsigned segx);
int	 _Cdecl getcbrk(void);
void	 _Cdecl getdate(struct date *datep);
int	 _Cdecl getdfree(unsigned char drive, struct dfree *dtable);
int	 _Cdecl getfat(unsigned char drive, struct fatinfo *dtable);
int	 _Cdecl getfatd(struct fatinfo *dtable);
unsigned _Cdecl getpsp(void);
int	 _Cdecl getswitchar(void);
void	 _Cdecl gettime(struct time *timep);
void	interrupt (* _Cdecl getvect(int interruptno)) ();
int	 _Cdecl getverify(void);
void	 _Cdecl harderr(int _Cdecl (*fptr)());
void	 _Cdecl hardresume(int axret);
int	 _Cdecl hardretn(int retn);
int	 _Cdecl int86(int intno, union REGS *inregs, union REGS *outregs);
int	 _Cdecl int86x(int intno, union REGS *inregs, union REGS *outregs,
			struct SREGS *segregs);
int	 _Cdecl intdos(union REGS *inregs, union REGS *outregs);
int	 _Cdecl intdosx(union REGS *inregs, union REGS *outregs,
			struct SREGS *segregs);
void	 _Cdecl intr(int int_type, struct REGPACK *preg);
void	 _Cdecl keep(unsigned char status, unsigned size);
char	*_Cdecl parsfnm(char *cmdline, struct fcb *fcb, unsigned char opt);
int	 _Cdecl randbrd(struct fcb *fcb, int rcnt);
int	 _Cdecl randbwr(struct fcb *fcb, int rcnt);
void	 _Cdecl segread(struct SREGS *segp);
int	 _Cdecl setblock(unsigned segx, unsigned newsize);
int	 _Cdecl setcbrk(int cbrkvalue);
void	 _Cdecl setdate(struct date *datep);
void	 _Cdecl setswitchar(char ch);
void	 _Cdecl settime(struct time *timep);
void	 _Cdecl setvect(int interruptno, void interrupt (*isr) ());
int	 _Cdecl setverify(int value);
void	 _Cdecl sleep(unsigned seconds);
void	 _Cdecl unixtodos(long time, struct date *d, struct time *t);
int	 _Cdecl unlink(char *filename);

int	_Cdecl peek(unsigned segment, unsigned offset);
void	_Cdecl poke(unsigned segment, unsigned offset, int value);
int	_Cdecl peekb(unsigned segment, unsigned offset);
void	_Cdecl pokeb(unsigned segment, unsigned offset, char value);
int	_Cdecl inport(int portid);
int	_Cdecl inportb(int portid);
void	_Cdecl outport(int portid, int value);
void	_Cdecl outportb(int portid, char value);
void	_Cdecl disable(void);
void	_Cdecl enable(void);

	/* These are in-line functions.  These prototypes just clean up
	   some syntax checks and code generation.
	 */

void	__cli__(void);
void	__sti__(void);
unsigned char __inportb__(int portid);
void	__outportb__(int portid, char value);
void	__int__(int interruptnum);

#define disable()	__cli__()		/* Clear interrupt flag */
#define enable()	__sti__()		/* Set interrupt flag */
#define inportb(portid) __inportb__(portid)	/* Byte IN instruction */
#define outportb(portid, v) __outportb__(portid,v)/* Byte OUT instruction */
#define geninterrupt(i) __int__(i)		/* Interrupt instruction */

/* some other compilers use inp, outp for inportb, outportb */
#define inp(portid)	inportb(portid)
#define outp(portid,v)	outportb(portid,v)

#if !__STDC__
char far *cdecl getdta(void);
void	  cdecl setdta(char far *dta);

#define MK_FP(seg,ofs)	((void far *)(((unsigned long)(seg) << 16) | (ofs)))

#define poke(a,b,c)	(*((int  far*)MK_FP((a),(b))) = (int)(c))
#define pokeb(a,b,c)	(*((char far*)MK_FP((a),(b))) = (char)(c))
#define peek(a,b)	(*((int  far*)MK_FP((a),(b))))
#define peekb(a,b)	(*((char far*)MK_FP((a),(b))))
#endif
