/*$no list*//*$no trace <<< dos.h >>> */
/*   Copyright (c) Mix Software 1988   */

#define time_t     long

extern int           _doserrno;
extern unsigned char _osmajor;
extern unsigned char _osminor;
extern unsigned int  _psp;
extern unsigned int  _version;
extern int           _argc;
extern char         *_argv[];

extern int         _AX;
extern signed char _AH;
extern signed char _AL;
extern int         _BX;
extern signed char _BH;
extern signed char _BL;
extern int         _CX;
extern signed char _CH;
extern signed char _CL;
extern int         _DX;
extern signed char _DH;
extern signed char _DL;
extern int         _SI;
extern int         _DI;
extern int         _BP;
extern int         _CS;
extern int         _DS;
extern int         _ES;

#define FP_SEG(farptr) (*((unsigned *)&(farptr) + 1))
#define FP_OFF(farptr) (*((unsigned *)&(farptr)))
#define MK_FP(seg,off) ((void far *) \
                       (((unsigned long)(seg) << 16) | (unsigned) (off)))

#define FA_NORMAL  0x0000
#define FA_RDONLY  0x0001
#define FA_HIDDEN  0x0002
#define FA_SYSTEM  0x0004
#define FA_LABEL   0x0008
#define FA_DIREC   0x0010
#define FA_ARCH    0x0020


#if !Defined(struct WORDREGS)
struct WORDREGS {
    unsigned int ax;
    unsigned int bx;
    unsigned int cx;
    unsigned int dx;
    unsigned int si;
    unsigned int di;
    unsigned int cflag;
    unsigned int flags;
};
#endif

#if !Defined(struct BYTEREGS)
struct BYTEREGS {
    unsigned char al, ah;
    unsigned char bl, bh;
    unsigned char cl, ch;
    unsigned char dl, dh;
};
#endif

#if !Defined(union REGS)
union REGS {
    struct WORDREGS x;
    struct BYTEREGS h;
    struct WORDREGS word;
    struct BYTEREGS byte;
};
#endif

#if !Defined(struct SREGS)
struct SREGS {
    unsigned int es;
    unsigned int cs;
    unsigned int ss;
    unsigned int ds;
};
#endif

#if !Defined(struct REGPACK)
struct REGPACK {
    unsigned r_ax, r_bx, r_cx, r_dx;
    unsigned r_bp, r_si, r_di;
    unsigned r_ds, r_es, r_flags;
};
#endif

#if !Defined(struct DOSERROR)
struct DOSERROR {
    int exterror;
    char class;
    char action;
    char locus;
};
#endif

#if !Defined(struct date)
struct date {
    int da_year;
    char da_day;
    char da_mon;
};
#endif

#if !Defined(struct time)
struct time {
    unsigned char ti_min;
    unsigned char ti_hour;
    unsigned char ti_hund;
    unsigned char ti_sec;
};
#endif

#if !Defined(struct dfree)
struct dfree {
    unsigned df_avail;         /* available clusters */
    unsigned df_total;         /* total clusters */
    unsigned df_bsec;          /* bytes per sector */
    unsigned df_sclus;         /* sectors per cluster */
};
#endif

#if !Defined(struct fatinfo)
struct fatinfo {
    char fi_sclus;             /* Sectors per cluster */
    char fi_fatid;             /* identification byte */
    int  fi_nclus;             /* number of clusters */
    int  fi_bysec;             /* bytes per sector */
};
#endif

#if !Defined(struct ftime)
struct ftime {
    unsigned ft_tsec : 5;      /* two seconds */
    unsigned ft_min  : 6;      /* minutes */
    unsigned ft_hour : 5;      /* hours */
    unsigned ft_day  : 5;      /* day of month */
    unsigned ft_month: 4;      /* month */
    unsigned ft_year : 7;      /* year - 1980 */
};
#endif

#if !Defined(struct fcb)
struct  fcb     {
    char fcb_drive;      /* drive number */
    char fcb_name[8];    /* file name */
    char fcb_ext[3];     /* file extension */
    int fcb_curblk;      /* block number */
    int fcb_recsize;     /* logical record size */
    long fcb_filsize;    /* file size */
    int fcb_date;        /* Date file was last written */
    char fcb_resv[10];   /* Reserved for DOS */
    char fcb_currec;     /* record in block */
    long fcb_random;     /* random record number */
};
#endif

#if !Defined(struct country)
struct country {
    int co_date;            /* date format */
    char co_curr[5];        /* currency symbol string */
    char co_thsep[2];       /* thousands separator character */
    char co_desep[2];       /* decimal separator character */
    char co_dtsep[2];       /* date separator character */
    char co_tmsep[2];       /* time separator character */
    char co_currstyle;      /* currency format */
    char co_digits;         /* number digits after decimal */
    char co_timestyle;      /* time format */
    int (far *co_case)();   /* case map call address */
    char co_dasep;          /* data-list separator */
    char co_fill[11];       /* reserved */
};
#endif

#if !Defined(_INT_STK)
   extern int near _INT_STK;  /* stack reserved for interrupt handlers */
#endif

int       absread(int drive, int nsects, int sector, void *buffer);
int       abswrite(int drive, int nsects, int sector, void *buffer);
int       allocmem(unsigned size, unsigned *seg);
int       asm(void *codeptr, void *dataptr);
int       bdos(int fn, unsigned dx, unsigned al);
int       bdosptr(int fn, void *address, unsigned al);
struct    country *country(int code, struct country *info);
void      ctrlbrk(int (*handler)(void));
void      disable(void);
int       dosexterr(struct DOSERROR *errinfo);
time_t    dostounix(struct date *dosdate, struct time *dostime);
void      enable(void);
int       freemem(unsigned seg);
void      geninterrupt(int intno);
int       getcbrk(void);
int       getcseg(void);
void      getdate(struct date *datebuf);
void      getdfree(int drive, struct dfree *diskdata);
int       getdseg(void);
char far *getdta(void);
void      getfat(int drive, struct fatinfo *fat);
void      getfatd(struct fatinfo *fat);
unsigned  getpsp(void);
void      gettime(struct time *timebuf);
void interrupt (far *getvect(int intno))();
int       getverify(void);
void      harderr(int (*handler)(int error, int ax, int bp, int si));
void      hardresume(int cmd);
void      hardretn(int error);
int       inp(unsigned port);
int       inport(int port);
int       inportb(int port);
int       int86(int interrupt, union REGS *inregs, union REGS *outregs);
int       int86x(int interrupt, union REGS *inregs, union REGS *outregs,
                  struct SREGS *segregs);
int       intdos(union REGS *inregs, union REGS *outregs);
int       intdosx(union REGS *inregs, union REGS *outregs,
                  struct SREGS *segregs);
void      intr(int interrupt, struct REGPACK *regs);
void      keep(int status, int size);
int       outp(unsigned port, int c);
void      outport(unsigned port, int word);
void      outportb(int port, char c);
char     *parsfnm(char *filename, struct fcb *buffer, int option);
int       peek(unsigned segment, unsigned offset);
int       peekb(unsigned segment, unsigned offset);
void      poke(unsigned segment, unsigned offset, int value);
void      pokeb(unsigned segment, unsigned offset, char value);
void      segread(struct SREGS *sregs);
int       setblock(unsigned seg, unsigned size);
int       setcbrk(int flag);
void      setdate(struct date *datebuf);
void      setdta(char far *address);
void      settime(struct time *timebuf);
void      setvect(int intno, void interrupt (far *handler)());
void      setverify(int flag);
void      sleep(unsigned seconds);
void      unixtodos(time_t timer, struct date *dosdate, struct time *dostime);

/*$list*//*$trace       <<< dos.h >>> */
