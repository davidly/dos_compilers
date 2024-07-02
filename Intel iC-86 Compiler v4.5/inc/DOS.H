/* dos.h - This file defines data structures for DOS access.
 * $Version: 1.32 $
 * Copyright (c) 1988-91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef _dosh
#define _dosh
/*lint -library */

#pragma fixedparams("_dos_allocmem",    "_dos_close",       "_dos_creat")
#pragma fixedparams("_dos_creatnew",    "_dos_findfirst",   "_dos_findnext")
#pragma fixedparams("_dos_freemem",     "_dos_getdate",     "_dos_getdiskfree")
#pragma fixedparams("_dos_getdrive",    "_dos_getfileattr", "_dos_getftime")
#pragma fixedparams("_dos_gettime",     "_dos_open",        "_dos_read")
#pragma fixedparams("_dos_setblock",    "_dos_setdate",     "_dos_setdrive")
#pragma fixedparams("_dos_setfileattr", "_dos_setftime",    "_dos_settime")
#pragma fixedparams("_dos_write")
#pragma fixedparams("bdos",     "_ctlcint", "dosexterr", "int86")
#pragma fixedparams("int86x",   "intdos",   "intdosx",   "loadexec")
#pragma fixedparams("ptrdiff",  "_quit",    "sysint",    "sysint21")

/*
 * File attribute masks:
 */
#define _A_NORMAL        0x00           /* Normal file access, read/write OK */
#define _A_RDONLY        0x01           /* File is read-only */
#define _A_HIDDEN        0x02           /* File is hidden */
#define _A_SYSTEM        0x04           /* File is a system file */
#define _A_VOLID         0x08           /* File holds volume ID */
#define _A_SUBDIR        0x10           /* File is a subdirectory */
#define _A_ARCH          0x20           /* File needs to be archived */


#ifndef _FAR
#define _FAR far
#define _NEAR near
#endif

/* used by functions needing the DS register or seg. and off. of a pointer */

extern unsigned _dataseg;

#define DATASEG() _dataseg

#define FP_OFF(p) (((unsigned *)(&(p)))[0])
#define FP_SEG(p) (((unsigned *)(&(p)))[1])
#define _NP_OFF(p) ((unsigned)p)
#define _NP_SEG(p) _dataseg

#if !_FAR_DATA_                         /* near data */
#define P_SEG(p) _NP_SEG(p)
#define P_OFF(p) _NP_OFF(p)
#else                                   /* far or huge data */
#define  P_SEG(p) FP_SEG(p)
#define  P_OFF(p) FP_OFF(p)
#endif

#define _doserrno ((_thread_ptr()->__doserrno)) /* DOS system error variable */

#pragma align (DOSERROR)
struct DOSERROR {
    int exterror;
    char class, action, locus;
};

/*
 * Structure used by loadexec function:
 */
#pragma align (pblock)
struct pblock {
    unsigned env;                       /* segment address of environment */
    char _FAR *com_line;                /* program command line */
    char _FAR *fcb1;
    char _FAR *fcb2;
};

/*
 * Used by sysint() and sysint21():
 */
#pragma align (regval)
struct regval {
    unsigned int  ax, bx, cx, dx, si, di, ds, es, bp;
};

#ifndef _regs
#pragma align (DWORDREGS)
#pragma align (WORDREGS)
#pragma align (BYTEREGS)
union REGS {
  struct DWORDREGS {unsigned  eax, ebx, ecx, edx, esi,
                              edi, cflag, eflags, ebp;} w;

  struct WORDREGS  {unsigned  ax, bx, cx, dx, si,
                              di, cflag, flags, bp;} x;

#if _ARCHITECTURE_ == 386 ||  _ARCHITECTURE_ == 486

  struct BYTEREGS  {unsigned  al:8, ah:8, :16, bl:8, bh:8, :16,
                              cl:8, ch:8, :16, dl:8, dh:8, :16;} h;
#else
  struct BYTEREGS  {unsigned  al:8, ah:8, bl:8, bh:8,
                              cl:8, ch:8, dl:8, dh:8;} h;
#endif

};

#pragma align (SREGS)
struct SREGS {
    unsigned short es, cs, ss, ds, fs, gs;
};

#define _regs
#endif  /* _regs */

#ifndef _find_t
/* structure used by _dos_findfirst */
/*
 * Structure used by _dos_findfirst:
 */
#pragma noalign (find_t)
struct find_t {
    char reserved[21];                  /* Reserved for DOS */
    char attrib;                        /* Returned attribute */
    unsigned short wr_time;             /* Time file last written */
    unsigned short wr_date;             /* Date file last written */
    long  size;                         /* Size of file */
    char name[13];                      /* String containing the filename */
    };
#define _find_t
#endif

/*
 * Structure used by _dos_getdate and _dos_setdate:
 */
#pragma align (dosdate_t)
struct dosdate_t {
    unsigned char day;                    /* Range: 1-31 */
    unsigned char month;                  /* Range: 1-12 */
    unsigned short year;                  /* Range: 1980-2099 */
    unsigned char dayofweek;              /* Range: 0-6 (0=Sun, 1=Mon, etc.) */
    };

/*
 * Structure used by _dos_gettime and _dos_settime:
 */
#pragma align (dostime_t)
struct dostime_t {
    unsigned char hour;                   /* Range: 0-23 */
    unsigned char minute;                 /* Range: 0-59 */
    unsigned char second;                 /* Range: 0-59 */
    unsigned char hsecond;                /* Range: 0-99 */
    };

/*
 * Structure used by _dos_getdiskfree:
 */
#pragma align (diskfree_t)
struct diskfree_t {
    unsigned short total_clusters;
    unsigned short avail_clusters;
    unsigned short sectors_per_cluster;
    unsigned short bytes_per_sector;
    };

/*
 * Function prototypes:
 */
int         bdos(int, unsigned int, unsigned int);
void _FAR  _ctlcint(void);
unsigned   _dos_allocmem(unsigned, unsigned *);
unsigned   _dos_close(int);
unsigned   _dos_creat(const char *, unsigned, int *);
unsigned   _dos_creatnew(const char *, unsigned, int *);
unsigned   _dos_findfirst(const char *, unsigned, struct find_t *);
unsigned   _dos_findnext(struct find_t *);
unsigned   _dos_freemem(unsigned);
void       _dos_getdate(struct dosdate_t *);
unsigned   _dos_getdiskfree(unsigned, struct diskfree_t *);
void       _dos_getdrive(unsigned *);
unsigned   _dos_getfileattr(const char *, unsigned *);
unsigned   _dos_getftime(int, unsigned *, unsigned *);
void       _dos_gettime(struct dostime_t *);
unsigned   _dos_open(const char *, unsigned, int *);
unsigned   _dos_read(int, void *, unsigned, unsigned *);
unsigned   _dos_setblock(unsigned, unsigned, unsigned *);
unsigned   _dos_setdate(struct dosdate_t *);
void       _dos_setdrive(unsigned, unsigned *);
unsigned   _dos_setfileattr(const char *, unsigned);
unsigned   _dos_setftime(int, unsigned, unsigned);
unsigned   _dos_settime(struct dostime_t *);
unsigned   _dos_write(int, const void *, unsigned, unsigned *);
int         dosexterr(struct DOSERROR *);
int         int86(int, const union REGS *, union REGS *);
int         int86x(int, const union REGS *, union REGS *, struct SREGS *);
int         intdos(const union REGS *, union REGS *);
int         intdosx(const union REGS *, union REGS *, struct SREGS *);
int         loadexec(char _FAR *, struct pblock _FAR *, int);
long        ptrdiff(void _FAR *, void _FAR *);
void       _quit(int);
int         sysint(unsigned, const struct regval *, struct regval *);
int         sysint21(const struct regval *, struct regval *);


/*
 * Non-ANSI function also prototyped in stdlib.h
 */
#ifndef _stdlib_dos
#define _stdlib_dos
#pragma fixedparams("segread")
void     segread(struct SREGS *);
#endif

#ifndef _dosh_builtin
#define _dosh_builtin
/*
 * Processor status flag values:
 */
#define _FLAG_CARRY      0x0001         /* Carry flag */
#define _FLAG_PARITY     0x0004         /* Parity flag */
#define _FLAG_AUXCARRY   0x0010         /* Auxillary carry flag */
#define _FLAG_ZERO       0x0040         /* Zero flag */
#define _FLAG_SIGN       0x0080         /* Sign flag */
#define _FLAG_TRAP       0x0100         /* Trap flag */
#define _FLAG_INTERRUPT  0x0200         /* Interrupt enable flag */
#define _FLAG_DIRECTION  0x0400         /* Direction flag */
#define _FLAG_OVERFLOW   0x0800         /* Overflow flag */
#define _FLAG_IOPL       0x3000         /* IO privilege level mask */
#define _FLAG_NESTED     0x4000         /* Nested task flag */
#define _FLAG_RESUME    0x10000         /* Resume flag */
#define _FLAG_VM        0x20000         /* Virtual 86 mode */

#endif /* _dosh_builtin */

#endif /* _dosh */

