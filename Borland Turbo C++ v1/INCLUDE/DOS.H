/*	dos.h

	Defines structs, unions, macros, and functions for dealing
	with MSDOS and the Intel iAPX86 microprocessor family.

        Copyright (c) Borland International 1987,1988,1990
	All Rights Reserved.
*/
#ifndef __DOS_H
#define __DOS_H

#if __STDC__
#define _Cdecl
#else
#define _Cdecl	cdecl
#endif

#ifndef __PAS__
#define _CType _Cdecl
#else
#define _CType pascal
#endif

/* Variables */
extern	int		const _Cdecl _8087;
extern	int		_Cdecl _argc;
extern	char	      **_Cdecl _argv;
extern	char	      **_Cdecl  environ;

extern	int		_Cdecl _doserrno;

extern	unsigned	_Cdecl _heaplen;
extern	unsigned char	_Cdecl _osmajor;
extern	unsigned char	_Cdecl _osminor;
extern	unsigned 	_Cdecl _psp;
extern	unsigned	_Cdecl _stklen;
extern	unsigned	_Cdecl _fpstklen;
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

struct  COUNTRY {
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
        int     de_exterror;
        int     de_class;
        char    de_action;
        char    de_locus;
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
	int		da_year;        /* Year - 1980 */
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

typedef struct {
	char	ds_drive;	   /* do not change	   */
	char	ds_pattern [13];   /*  these fields,	   */
	char	ds_reserved [7];   /*	Microsoft reserved */
	char	ds_attrib;
	short	ds_time;
	short	ds_date;
	long	ds_size;
	char	ds_nameZ [13];	   /* result of the search, asciiz */
}	dosSearchInfo;	/* used with DOS functions 4E, 4F	*/


#ifdef __cplusplus
extern "C" {
#endif
int	 _Cdecl absread	(int __drive, int __nsects, long __lsect, void *__buffer);
int	 _Cdecl abswrite(int __drive, int __nsects, long __lsect, void *__buffer);
int	 _Cdecl allocmem(unsigned __size, unsigned *__segp);
int	 _CType bdos	(int __dosfun, unsigned __dosdx, unsigned __dosal);
int	 _Cdecl bdosptr	(int __dosfun, void *__argument, unsigned __dosal);
struct  COUNTRY *_Cdecl country (int __xcode, struct COUNTRY *__cp);
void     _Cdecl ctrlbrk	(int _Cdecl (*handler)(void));
void     _Cdecl delay	(unsigned __milliseconds);
void     _Cdecl disable	(void);
int	     _Cdecl dosexterr	(struct DOSERROR *__eblkp);
long     _Cdecl dostounix	(struct date *__d, struct time *__t);
void            __emit__();
void     _Cdecl enable	(void);
int	     _Cdecl freemem	(unsigned __segx);
int	     _Cdecl getcbrk	(void);
void     _CType getdate	(struct date *__datep);
void     _Cdecl getdfree(unsigned char __drive, struct dfree *__dtable);
void     _Cdecl getfat	(unsigned char __drive, struct fatinfo *__dtable);
void     _Cdecl getfatd	(struct fatinfo *__dtable);
unsigned _Cdecl getpsp	(void);
int	     _Cdecl getswitchar	(void);
void     _CType gettime	(struct time *__timep);
int	     _Cdecl getverify	(void);
void     _Cdecl harderr	(int _Cdecl (*handler)());
void     _Cdecl hardresume	(int __axret);
void     _Cdecl hardretn(int __retn);
int	     _Cdecl inport	(int __portid);
unsigned char	_Cdecl inportb(int __portid);
int	 _Cdecl int86	(int __intno, union REGS *__inregs, union REGS *__outregs);
int	 _Cdecl int86x	(int __intno, union REGS *__inregs, union REGS *__outregs,
		        	 struct SREGS *__segregs);
int	 _Cdecl intdos	(union REGS *__inregs, union REGS *__outregs);
int	 _Cdecl intdosx	(union REGS *__inregs, union REGS *__outregs,
        			 struct SREGS *__segregs);
void	 _Cdecl intr	(int __intno, struct REGPACK *__preg);
void	 _Cdecl keep	(unsigned char __status, unsigned __size);
void 	 _Cdecl nosound	(void);
void	 _Cdecl outport	(int __portid, int __value);
void	 _Cdecl outportb(int __portid, unsigned char __value);
char	*_Cdecl parsfnm	(const char *__cmdline, struct fcb *__fcb, int __opt);
int	     _Cdecl peek	(unsigned __segment, unsigned __offset);
char	 _Cdecl peekb	(unsigned __segment, unsigned __offset);
void	 _Cdecl poke	(unsigned __segment, unsigned __offset, int __value);
void	 _Cdecl pokeb	(unsigned __segment, unsigned __offset, char __value);
int	     _Cdecl randbrd	(struct fcb *__fcb, int __rcnt);
int	     _Cdecl randbwr	(struct fcb *__fcb, int __rcnt);
void	 _Cdecl segread	(struct SREGS *__segp);
int	     _Cdecl setblock(unsigned __segx, unsigned __newsize);
int	     _Cdecl setcbrk	(int __cbrkvalue);
void	 _Cdecl setdate	(struct date *__datep);
void	 _Cdecl setswitchar	(char __ch);
void	 _Cdecl settime	(struct time *__timep);
void	 _Cdecl setverify	(int __value);
void	 _Cdecl sleep	(unsigned __seconds);
void 	 _Cdecl sound	(unsigned __frequency);
void	 _Cdecl unixtodos	(long __time, struct date *__d, struct time *__t);
int	     _CType	unlink	(const char *__path);

	/* These are in-line functions.  These prototypes just clean up
	   some syntax checks and code generation.
	 */

void	_Cdecl	        __cli__		(void);
void	_Cdecl	        __sti__		(void);
void	_Cdecl          __int__		(int __interruptnum);
unsigned char	_Cdecl  __inportb__ (int __portid);
void	 _Cdecl         __outportb__(int __portid, unsigned char __value);

#define disable() __emit__( (char)(0xfa) )
#define enable()  __emit__( (char)(0xfb) )

#define geninterrupt(i) __int__(i)		/* Interrupt instruction */

#define outportb        __outportb__
#define inportb         __inportb__

/* some other compilers use inp, outp for inportb, outportb */
#define inp(portid)	inportb(portid)
#define outp(portid,v)	outportb(portid,v)

extern	unsigned	_Cdecl	_ovrbuffer;

#if !__STDC__
int cdecl far _OvrInitEms( unsigned __emsHandle, unsigned __emsFirst, unsigned __emsPages );
int cdecl far _OvrInitExt( unsigned long __extStart, unsigned long __extLength );

char far *cdecl getdta(void);
void	  cdecl setdta(char far *__dta);

#define MK_FP(seg,ofs)	((void _seg *)(seg) + (void near *)(ofs))
#define FP_SEG(fp)      ((unsigned)(void _seg *)(void far *)(fp))
#define FP_OFF(fp)      ((unsigned)(fp))

#ifdef __cplusplus
void	interrupt	(far * _CType getvect(int __interruptno)) (...);
void	_CType setvect (int __interruptno, void interrupt (far *__isr) (...));
int  inline _Cdecl peek(unsigned __segment, unsigned __offset)	
                   { return (*((int  far*)MK_FP(__segment, __offset))); }
char inline _Cdecl peekb(unsigned __segment, unsigned __offset) 
                   { return (*((char far*)MK_FP(__segment, __offset))); }
void inline _Cdecl poke(unsigned __segment, unsigned __offset, int __value)  
                   { (*((int  far*)MK_FP(__segment, __offset)) = __value); }
void inline _Cdecl pokeb(unsigned __segment, unsigned __offset, char __value)   
                   { (*((char far*)MK_FP(__segment, __offset)) = __value); }
#else
void	interrupt 	(far * _CType getvect(int __interruptno)) ();
void    _CType setvect (int __interruptno, void interrupt (far *__isr) ());
#define peek(a,b)	    (*((int  far*)MK_FP((a),(b))))
#define peekb(a,b)	    (*((char far*)MK_FP((a),(b))))
#define poke(a,b,c)	    (*((int  far*)MK_FP((a),(b))) = (int)(c))
#define pokeb(a,b,c)	(*((char far*)MK_FP((a),(b))) = (char)(c))
#endif

#endif
#ifdef __cplusplus
}
#endif

#endif
