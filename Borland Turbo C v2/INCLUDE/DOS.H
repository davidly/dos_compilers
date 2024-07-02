/*	dos.h

	Defines structs, unions, macros, and functions for dealing
	with MSDOS and the Intel iAPX86 microprocessor family.

	Copyright (c) Borland International 1987,1988
	All Rights Reserved.
*/
#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#if     !defined(__DOS_DEF_)
#define __DOS_DEF_

/* Variables */
extern	int		_Cdecl _8087;
extern	int		_Cdecl _argc;
extern	char	      **_Cdecl _argv;
extern	char	      **_Cdecl  environ;
extern	int		_Cdecl _doserrno;
extern	unsigned	_Cdecl _heaplen;
extern	unsigned char	_Cdecl _osmajor;
extern	unsigned char	_Cdecl _osminor;
extern	unsigned 	_Cdecl _psp;
extern	unsigned	_Cdecl _stklen;
extern	unsigned 	_Cdecl _version;

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
	char	co_time;
	long	co_case;
	char	co_dasep[2];
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

struct WORDREGS {
	unsigned int	ax, bx, cx, dx, si, di, cflag, flags;
};

struct BYTEREGS {
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

struct	REGPACK {
	unsigned	r_ax, r_bx, r_cx, r_dx;
	unsigned	r_bp, r_si, r_di, r_ds, r_es, r_flags;
};

#define FP_OFF(fp)	((unsigned)(fp))
#define FP_SEG(fp)	((unsigned)((unsigned long)(fp) >> 16))


typedef struct {
	char	drive;		/* do not change	*/
	char	pattern [13];	/*  these fields,	*/
	char	reserved [7];	/*   Microsoft reserved */
	char	attrib;
	short	time;
	short	date;
	long	size;
	char	nameZ [13];	/* result of the search, asciiz */
}	dosSearchInfo;	/* used with DOS functions 4E, 4F	*/


int	 _Cdecl absread	(int drive, int nsects, int lsect, void *buffer);
int	 _Cdecl abswrite(int drive, int nsects, int lsect, void *buffer);
int	 _Cdecl allocmem(unsigned size, unsigned *segp);
int	 _Cdecl bdos	(int dosfun, unsigned dosdx, unsigned dosal);
int	 _Cdecl bdosptr	(int dosfun, void *argument, unsigned dosal);
struct	country *_Cdecl country	(int xcode, struct country *cp);
void	 _Cdecl ctrlbrk	(int _Cdecl (*handler)(void));
void	 _Cdecl delay	(unsigned milliseconds);
void	 _Cdecl disable	(void);
int	 _Cdecl dosexterr	(struct DOSERROR *eblkp);
long	 _Cdecl dostounix	(struct date *d, struct time *t);
void          __emit__();
void	 _Cdecl enable	(void);
int	 _Cdecl freemem	(unsigned segx);
int	 _Cdecl getcbrk	(void);
void	 _Cdecl getdate	(struct date *datep);
void	 _Cdecl getdfree(unsigned char drive, struct dfree *dtable);
void	 _Cdecl getfat	(unsigned char drive, struct fatinfo *dtable);
void	 _Cdecl getfatd	(struct fatinfo *dtable);
unsigned _Cdecl getpsp	(void);
int	 _Cdecl getswitchar	(void);
void	 _Cdecl gettime	(struct time *timep);
void	interrupt 	(* _Cdecl getvect(int interruptno)) ();
int	 _Cdecl getverify	(void);
void	 _Cdecl harderr	(int _Cdecl (*handler)());
void	 _Cdecl hardresume	(int axret);
void	 _Cdecl hardretn(int retn);
int	 _Cdecl inport	(int portid);
unsigned char	_Cdecl inportb(int portid);
int	 _Cdecl int86	(int intno, union REGS *inregs, union REGS *outregs);
int	 _Cdecl int86x	(int intno, union REGS *inregs, union REGS *outregs,
			 struct SREGS *segregs);
int	 _Cdecl intdos	(union REGS *inregs, union REGS *outregs);
int	 _Cdecl intdosx	(union REGS *inregs, union REGS *outregs,
			 struct SREGS *segregs);
void	 _Cdecl intr	(int intno, struct REGPACK *preg);
void	 _Cdecl keep	(unsigned char status, unsigned size);
void 	 _Cdecl nosound	(void);
void	 _Cdecl outport	(int portid, int value);
void	 _Cdecl outportb(int portid, unsigned char value);
char	*_Cdecl parsfnm	(const char *cmdline, struct fcb *fcb, int opt);
int	 _Cdecl peek	(unsigned segment, unsigned offset);
char	 _Cdecl peekb	(unsigned segment, unsigned offset);
void	 _Cdecl poke	(unsigned segment, unsigned offset, int value);
void	 _Cdecl pokeb	(unsigned segment, unsigned offset, char value);
int	 _Cdecl randbrd	(struct fcb *fcb, int rcnt);
int	 _Cdecl randbwr	(struct fcb *fcb, int rcnt);
void	 _Cdecl segread	(struct SREGS *segp);
int	 _Cdecl setblock(unsigned segx, unsigned newsize);
int	 _Cdecl setcbrk	(int cbrkvalue);
void	 _Cdecl setdate	(struct date *datep);
void	 _Cdecl setswitchar	(char ch);
void	 _Cdecl settime	(struct time *timep);
void	 _Cdecl setvect	(int interruptno, void interrupt (*isr) ());
void	 _Cdecl setverify	(int value);
void	 _Cdecl sleep	(unsigned seconds);
void 	 _Cdecl sound	(unsigned frequency);
void	 _Cdecl unixtodos	(long time, struct date *d, struct time *t);
int	 _Cdecl	unlink	(const char *path);

	/* These are in-line functions.  These prototypes just clean up
	   some syntax checks and code generation.
	 */

void	_Cdecl	__cli__		(void);
void	_Cdecl	__sti__		(void);
unsigned char _Cdecl __inportb__(int portid);
void	_Cdecl	__outportb__	(int portid, unsigned char value);
void	_Cdecl	__int__		(int interruptnum);

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

#define MK_FP(seg,ofs)	((void far *) \
			   (((unsigned long)(seg) << 16) | (unsigned)(ofs)))

#define poke(a,b,c)	(*((int  far*)MK_FP((a),(b))) = (int)(c))
#define pokeb(a,b,c)	(*((char far*)MK_FP((a),(b))) = (char)(c))
#define peek(a,b)	(*((int  far*)MK_FP((a),(b))))
#define peekb(a,b)	(*((char far*)MK_FP((a),(b))))
#endif

#endif
