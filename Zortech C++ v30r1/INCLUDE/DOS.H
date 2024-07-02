/*_ dos.h   Sat Aug 19 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1991 by Walter Bright	*/
/* All rights reserved				*/
/* Written by Walter Bright			*/

#ifndef __DOS_H
#define __DOS_H	1

#if __cplusplus
extern "C" {
#endif

#if !(M_XENIX || M_UNIX)
#pragma ZTC align 1			/* no alignment for DOS structs	*/
#endif

typedef unsigned size_t;

/* DOS and IBM PC specific declarations			*/

#if DOS386
/* Valid for both Pharlap and x386. */
extern unsigned short _x386_zero_base_selector;

/* The following is actually only for X386, not Pharlap. */
/***************
Absolute address is given.  Selector is returned in dx, offset in eax.  A 
selector is normally allocated so the offset will normally be zero.  If all 
selectors are being used, the offset is returned in eax with
_x386_zero_base_selector in dx.  This should provide working long pointers to 
most applications even if we have insufficient selectors.  Return of zero in 
eax indicates allocation of a selector unless the requested base was zero in 
which case it is ambiguous.  Nonzero indicates all selectors have been 
allocated and _x386_zero_base_selector is in dx, requested absolute address 
is in eax.  In all cases the descriptor has a 4 gbyte limit.
****************/
extern void _far *(*_x386_mk_protected_ptr)(unsigned long abs_address); 

/***************
Pass a far pointer.  Offset portion of pointer is ignored, selector is 
examined to see if it matches pointers previously allocated.  If the selector 
is indeed a user definable selector then it is deactivated and a 0 is 
returned.  Any attempt to use the selector after it has been freed will 
result in a general protection fault.  

If the pointer does not contain a selector created through a call to 
mk_protected_ptr then it returns a -1 with no action taken.  This also 
happens if mk_protected_ptr returns nonzero in eax and an attempt is made to 
free the associated selector. 
****************/
extern int (*_x386_free_protected_ptr)(void _far *);

/***************
Function is called with a far pointer.  It  determines the absolute address 
of that pointer and returns the address in eax. 
****************/
extern unsigned long(*_x386_get_abs_address)(void _far *ptr);
#endif

/* Register structure required for functions int86() and intdos()	*/

#if M_I386 || M_I486

struct DWORDREGS
{	unsigned eax,ebx,ecx,edx,esi,edi,cflag,flags;
};
struct WORDREGS
{	unsigned short	ax,eaxmsw,bx,ebxmsw,cx,ecxmsw,dx,edxmsw,
			si,esimsw,di,edimsw;
	unsigned cflag,flags;
};
struct BYTEREGS
{	unsigned char al,ah,ax2,ax3,bl,bh,bx2,bx3,
		      cl,ch,cx2,cx3,dl,dh,dx2,dx3;
};
union REGS { struct DWORDREGS e; struct WORDREGS x; struct BYTEREGS h; };

struct SREGS { unsigned short es,cs,ss,ds,fs,gs; };

#else

struct WORDREGS { unsigned ax,bx,cx,dx,si,di,cflag,flags; };
struct BYTEREGS {unsigned char al,ah,bl,bh,cl,ch,dl,dh; };
union REGS { struct WORDREGS x; struct BYTEREGS h; };
struct SREGS { unsigned es,cs,ss,ds; };

#endif

int _cdecl int86(int,union REGS *,union REGS *);
int _cdecl int86x(int,union REGS *,union REGS *,struct SREGS *);
int _cdecl intdos(union REGS *,union REGS *);
int _cdecl intdosx(union REGS *,union REGS *,struct SREGS *);
void _cdecl segread(struct SREGS *);

#if DOS386
int _cdecl int86_real(int,union REGS *,union REGS *);
int _cdecl int86x_real(int,union REGS *,union REGS *,struct SREGS *);
#endif

#if (M_UNIX || M_XENIX)

/***************
The _vt_ functions help support the use of virtural terminals.  See SCREEN(HW)
for the basics of the ioctl()'s which are hidden by this set of functions.
Use _vt_add() to add functions to be called at time when requests are made
to switch screens.  Your function will be passed either VT_RELDISP or 
VT_ACTIVATE to identify which action is being taken.  If you do not wish to 
release the screen return VT_FALSE for relsig (VT_TRUE if you are ready to
release it).  The return value for acqsig is ignored. 

You may add as many functions to be notified as you wish -- the only memory 
constraints are governed by malloc().  Remove functions with _vt_remove.

If you wish to switch to another screen use _vt_activate().  Screen numbers
are normally 1 -> 12.  To find your screen number use _vt_get_num().
****************/

/***************
ioctls supported by the VT
****************/
#define VTIOC       ('v' << 8)
#define VT_OPENQRY  (VTIOC | 1)
#define VT_SETMODE  (VTIOC | 2)
#define VT_GETMODE  (VTIOC | 3)
#define VT_RELDISP  (VTIOC | 4)
#define VT_ACTIVATE (VTIOC | 5)

/***************
Modes of VT_RELDISP
****************/
#define VT_FALSE    0 /* user will not release display              */
#define VT_TRUE     1 /* user releases display                      */
#define VT_ACKACQ   2 /* user acknowleges the acquire signal        */

/***************
Modes of struct vt_mode.mode
****************/
#define VT_AUTO     0 /* this vt switching is automatic            */
#define VT_PROCESS  1 /* this vt switching controlled by a process */

struct vt_mode {char mode, waitv; short relsig, acqsig, frsig;};

typedef int (*_vt_sig_func_t)(int);

/***************
Return the mode the VT handler is in.
****************/
void _vt_get_mode(struct vt_mode *p);

/***************
Set the new mode to use with this VT.  Return -1 if failure.
****************/
int _vt_set_mode(struct vt_mode *p);

/***************
Get this processes VT screen number.
Return -1 if failure or screen number if successful.
****************/
int _vt_get_num(void);

/***************
Set this VT to be the active one.  Return -1 if failure.
****************/
int _vt_activate(int vt_num);

/***************
Adds a another function to the list to be notified in the event of a 
release/acquire request.  Returns -1 if failed.
****************/
int _vt_add(_vt_sig_func_t func);

/***************
Remove this function from the list of functions to be notified in the event
of a release/acquire request.  Returns -1 if failure to remove it.
****************/
int _vt_remove(_vt_sig_func_t func);


#include <sys/stat.h>

struct FIND		/* struct used by findfirst() and findnext()	*/
{
	struct stat stat;
	unsigned short attribute;/* attribute found (FA_XXXX)		*/
	unsigned short time,date;/* file's time and date		*/
	unsigned long size;	/* file's size				*/
	char name[16];		/* filename followed by 0 byte		*/
};

/* Directory entry attributes	*/
/* Use S_XXXX bit masks in sys/stat.h. */

#define FA_NORMAL	0x00
#define FA_DIREC	S_IFDIR
#else
struct FIND		/* struct used by findfirst() and findnext()	*/
{	char reserved[21];	/* reserved by DOS			*/
	char attribute;		/* attribute found (FA_XXXX)		*/
	unsigned short time,date; /* file's time and date		*/
	unsigned long size;	/* file's size				*/
	char name[13];		/* filename followed by 0 byte		*/
};

struct find_t		/* used by _dos_findfirst() and _dos_findnext()	*/
{	char reserved[21];	/* reserved by DOS			*/
	char attrib;		/* attribute found (FA_XXXX)		*/
	unsigned short wr_time,wr_date;	/* file's last write		*/
	unsigned long size;	/* file's size				*/
	char name[13];		/* filename followed by 0 byte		*/
};
/* Directory entry attributes	*/
#define FA_NORMAL	0x00
#define FA_RDONLY	0x01
#define FA_HIDDEN	0x02
#define FA_SYSTEM	0x04
#define FA_LABEL	0x08
#define FA_DIREC	0x10
#define FA_ARCH		0x20

#define _A_NORMAL	0x00
#define _A_RDONLY	0x01
#define _A_HIDDEN	0x02
#define _A_SYSTEM	0x04
#define _A_VOLID	0x08
#define _A_SUBDIR	0x10
#define _A_ARCH		0x20

#endif

struct FIND * _cdecl findfirst(const char *,int),* _cdecl findnext(void);

#if MSDOS || _WINDOWS
int     _cdecl _dos_findfirst(char *, unsigned, struct find_t *);
int     _cdecl _dos_findnext(struct find_t *);
#endif

extern unsigned short _cdecl _psp;
extern unsigned char _cdecl _osmajor;
extern unsigned char _cdecl _osminor;
extern unsigned char _cdecl _osmode;
extern volatile int _cdecl _doserrno;	/* MS-DOS error codes. Refer to the	*/
				/* ERROR RETURN TABLE in your MS-DOS	*/
				/* manual.				*/

/***************************
 * Define macros to get at the segment and offset of a far pointer.
 */

#define FP_OFF(fp)	((unsigned)(fp))
#if M_I386 || M_I486
extern unsigned _cdecl FP_SEG(void _far *);
#else
#define FP_SEG(fp)	((unsigned)((unsigned long)(fp) >> 16))
#endif

/* Generate a far pointer from a segment and an offset	*/
#if M_I386 || M_I486
extern void _far * _cdecl MK_FP(unsigned short,unsigned);
#define MK_FP(seg,offset) MK_FP((seg),(unsigned)(offset))
#else
#define MK_FP(seg,offset) \
	((void _far *)(((unsigned long)(seg)<<16) | (unsigned)(offset)))
#endif

void _far * _cdecl _farptr_norm(void _far *);
void _far * _cdecl _farptr_fromlong(long);
long _cdecl _farptr_tolong(void _far *);
long _cdecl _farptr_diff(void _far *,void _far *);

/***********************************
 * Far storage allocation functions
 */

void _far * _cdecl farmalloc(unsigned long size);
void _far * _cdecl farcalloc(unsigned long numelems,unsigned long elemsize);
void _far * _cdecl farrealloc(void _far *oldptr,unsigned long newsize);
int _cdecl farfree(void _far *ptr);
unsigned long _cdecl farcoreleft(void);

/*******************************
 * File modes for open().
 */

#define O_RDONLY	0
#define O_WRONLY	1
#define O_RDWR		2

#define O_APPEND	8
#define O_NOINHERIT	0x80
#define O_CREAT		0x100
#define O_TRUNC		0x200
#define O_EXCL		0x400

/* structure for dos_exterr */

struct DOSERROR
{
	int exterror;	/* extended error code */
	char eclass;		/* error class */
	char action;	/* recommended action */
	char locus;		/* error locus */
};

/* structure for dos_setdate/dos_getdate */

struct dos_date_t
{
	char day;
	char month;
	short	year;
	char dayofweek;
};

/* structure for dos_settime/dos_gettime */

struct dos_time_t
{
	char hour;
	char minute;
	char second;
	char hsecond;
};

/* DOS specific functions:	*/
int	_cdecl dos_creat(char *,int);
void	_cdecl dos_set_verify(int);
void	_cdecl dos_set_ctrl_break(int);
int	_cdecl dos_get_verify(void);
int	_cdecl dos_get_ctrl_break(void);
long	_cdecl dos_getdiskfreespace(int);
int	_cdecl dos_abs_disk_read(int,int,int,char *);
int	_cdecl dos_abs_disk_write(int,int,int,char *);
void	_cdecl dos_setdrive(unsigned, unsigned *);
void	_cdecl dos_getdrive(unsigned *);
int	_cdecl dos_setftime(int, unsigned, unsigned);
int	_cdecl dos_getftime(int, unsigned *, unsigned *);
int	_cdecl dos_setfileattr(char *, unsigned);
int	_cdecl dos_getfileattr(char *, unsigned *);
int	_cdecl dos_exterror(struct DOSERROR *);
int	_cdecl dosexterror(struct DOSERROR *);
int	_cdecl dos_setdate(struct dos_date_t *);
int	_cdecl dos_getdate(struct dos_date_t *);
int	_cdecl dos_settime(struct dos_time_t *);
int	_cdecl dos_gettime(struct dos_time_t *);

/* For inline code generation for inp(), inpw(), outp() and outpw() functions */
unsigned char	_cdecl _inline_inp(unsigned);
int		_cdecl _inline_inpw(unsigned);
unsigned char	_cdecl _inline_outp(unsigned,char);
int		_cdecl _inline_outpw(unsigned,unsigned);

#define inp	_inline_inp
#define inpw	_inline_inpw
#define outp	_inline_outp
#define outpw	_inline_outpw

#if M_I386 || M_I486
long		_cdecl inpl(unsigned);
long		_cdecl outpl(unsigned,unsigned long);
#endif

#if _WINDOWS
#define _chkstack()
#else
size_t _cdecl _chkstack(void);
#endif
void _cdecl peek(unsigned,unsigned,void *,size_t);
void _cdecl poke(unsigned,unsigned,const void *,size_t);
int _cdecl bdos(char,...);
int _cdecl bdosx(char,void *,char);

/* From parall.asm	*/
unsigned _cdecl dos_alloc(unsigned);
unsigned _cdecl dos_calloc(unsigned);
int _cdecl dos_free(unsigned);
void _cdecl _copy(unsigned,unsigned,unsigned);
unsigned long _cdecl dos_avail(void);
unsigned _cdecl dos_setblock(unsigned,unsigned);

/* From response.c	*/
int _pascal response_expand(int *,char ***);

int _cdecl cputype(void);

/* Use this macro if you wish to cause wildcard expansion	*/
#if MSDOS || _WINDOWS || __OS2__
#define WILDCARDS	extern int _cdecl __wildcard; int *__wild = &__wildcard;
#else
#define WILDCARDS
#endif

/* Executable type	*/
#define EXE_DOS		1		/* MSDOS			*/
#define EXE_DOS16RM	2		/* Rational 286 DOS Extender	*/
#define	EXE_ZPM		4		/* ZPM 286 DOS Extender		*/
#define EXE_PHAR386	8		/* Pharlap 386 DOS Extender	*/
#define EXE_DOSX	0x10		/* DOSX 386 DOS Extender	*/
#define EXE_WINDOWS	0x20		/* Windows 3			*/
#define EXE_OS2		0x40		/* OS/2 1.x			*/
#define EXE_SCOUNIX	0x80		/* SCO Unix			*/

extern unsigned short _cdecl _exe_type;	/* EXE_XXXX			*/

#if !(M_UNIX || M_XENIX)
#pragma ZTC align
#endif

#if __cplusplus
}
#endif

#endif /* __DOS_H */
