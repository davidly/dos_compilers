/*_ dos.h   Sat Aug 19 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All rights reserved					*/
/* Written by Walter Bright				*/

#ifndef DOS_H
#define DOS_H	1

#if __cplusplus
extern "C" {
#endif

#define size_t	unsigned

/* DOS and IBM PC specific declarations			*/

/* Register structure required for functions int86() and intdos()	*/
struct WORDREGS {unsigned ax,bx,cx,dx,si,di,cflag,flags; };
struct BYTEREGS {unsigned char al,ah,bl,bh,cl,ch,dl,dh; };
union REGS { struct WORDREGS x; struct BYTEREGS h; };
struct SREGS { unsigned es,cs,ss,ds; };

int cdecl int86(int,union REGS *,union REGS *);
int cdecl int86x(int,union REGS *,union REGS *,struct SREGS *);
int cdecl intdos(union REGS *,union REGS *);
int cdecl intdosx(union REGS *,union REGS *,struct SREGS *);
void cdecl segread(struct SREGS *);

struct FIND		/* struct used by findfirst() and findnext()	*/
{	char reserved[21];	/* reserved by DOS			*/
	char attribute;		/* attribute found (FA_XXXX)		*/
	unsigned time,date;	/* file's time and date			*/
	unsigned long size;	/* file's size				*/
	char name[13];		/* filename followed by 0 byte		*/
};

struct FIND * cdecl findfirst(char *,int),* cdecl findnext(void);

/* Directory entry attributes	*/
#define FA_NORMAL	0x00
#define FA_RDONLY	0x01
#define FA_HIDDEN	0x02
#define FA_SYSTEM	0x04
#define FA_LABEL	0x08
#define FA_DIREC	0x10
#define FA_ARCH		0x20

extern unsigned _psp;
extern unsigned char _osmajor,_osminor,_osmode;
extern volatile int _doserrno;	/* MS-DOS error codes. Refer to the	*/
				/* ERROR RETURN TABLE in your MS-DOS	*/
				/* manual.				*/

/***************************
 * Define macros to get at the segment and offset of a far pointer.
 */

#define FP_SEG(fp)	((unsigned)((unsigned long)(fp) >> 16))
#define FP_OFF(fp)	((unsigned)(fp))

/* Generate a far pointer from a segment and an offset	*/
#define MK_FP(seg,offset) \
	((void far *)(((unsigned long)(seg)<<16) | (unsigned)(offset)))

void far * cdecl _farptr_norm(void far *);
void far * cdecl _farptr_fromlong(long);
long cdecl _farptr_tolong(void far *);

/***********************************
 * Far storage allocation functions
 */

void far * cdecl farmalloc(unsigned long size);
void far * cdecl farcalloc(unsigned long numelems,unsigned long elemsize);
void far * cdecl farrealloc(void far *oldptr,unsigned long newsize);
int cdecl farfree(void far *ptr);
unsigned long cdecl farcoreleft(void);

/*******************************
 * File modes for open().
 */

#ifndef __FCNTL_H
#define O_RDONLY	0
#define O_WRONLY	1
#define O_RDWR		2
#define O_CREAT		0
#endif

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
	int	year;
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
void	cdecl dos_set_verify(int);
void	cdecl dos_set_ctrl_break(int);
int	cdecl dos_get_verify(void);
int	cdecl dos_get_ctrl_break(void);
long	cdecl dos_getdiskfreespace(int);
int	cdecl dos_abs_disk_read(int,int,int,char *);
int	cdecl dos_abs_disk_write(int,int,int,char *);
void	cdecl dos_setdrive(unsigned, unsigned *);
void	cdecl dos_getdrive(unsigned *);
int	cdecl dos_setftime(int, unsigned, unsigned);
int	cdecl dos_getftime(int, unsigned *, unsigned *);
int	cdecl dos_setfileattr(char *, unsigned);
int	cdecl dos_getfileattr(char *, unsigned *);
int	cdecl dos_exterror(struct DOSERROR *);
int	cdecl dosexterror(struct DOSERROR *);
int	cdecl dos_setdate(struct dos_date_t *);
int	cdecl dos_getdate(struct dos_date_t *);
int	cdecl dos_settime(struct dos_time_t *);
int	cdecl dos_gettime(struct dos_time_t *);

/* For inline code generation for inp(), inpw(), outp() and outpw() functions */
unsigned char	cdecl _inline_inp(unsigned);
int		cdecl _inline_inpw(unsigned);
unsigned char	cdecl _inline_outp(unsigned,char);
int		cdecl _inline_outpw(unsigned,unsigned);

#define inp	_inline_inp
#define inpw	_inline_inpw
#define outp	_inline_outp
#define outpw	_inline_outpw

size_t cdecl _chkstack(void);
void cdecl peek(unsigned,unsigned,void *,size_t);
void cdecl poke(unsigned,unsigned,const void *,size_t);
int cdecl bdos(char,...);
int cdecl bdosx(char,void *,char);

/* From parall.asm	*/
unsigned cdecl dos_alloc(unsigned);
unsigned cdecl dos_calloc(unsigned);
int cdecl dos_free(unsigned);
void cdecl _copy(unsigned,unsigned,unsigned);
unsigned long cdecl dos_avail(void);
unsigned cdecl dos_setblock(unsigned,unsigned);

#if __cplusplus
}
#endif

#endif /* DOS_H */
