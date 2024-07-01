/*$no list*//*$no trace <<< std_lib.h >>> */
/*   Copyright (c) Mix Software 1988     */
/* Header for compiling the standard libraries */

#define     V_ASM
#define     MAXFILES    20
#define     BUFSIZ      512
#define     EOF         -1
#define     NULL        0
#define     stdin       _iob[0]
#define     stdout      _iob[1]
#define     stderr      _iob[2]
#define     stdprn      _iob[3]
#define     stdaux      _iob[4]

#define     size_t  unsigned

#include "fdb.h"

typedef struct {
    fdb     file;      /* file descriptor */
    int     fd;        /* file descriptor number */
} FILE;

extern      FILE        *_iob[MAXFILES];

typedef struct {
    int     length;
    char    string[80];
} STRING;

typedef int (*onexit_t)();
typedef int (*atexit_t)();

#define P_tmpdir "\\TMP"
#define L_tmpnam sizeof(P_tmpdir)+8

#define _IOFBF 0
#define _IOLBF 0x40
#define _IONBF 0x04

/***************************************************************/

#define NEWLINE '\l'
#define RETURN  '\r'
#define CTLZ    '\x1A'
#define  MAXARGS   20
#define  FALSE     0
#define  TRUE      1
#define  FILEERR   0x89

/*********************** fcntl.h  ******************************/

#define O_RDONLY 0x0000
#define O_WRONLY 0x0001
#define O_RDWR   0x0002
#define O_APPEND 0x0008
#define O_CREAT  0x0100
#define O_TRUNC  0x0200
#define O_EXCL   0x0400
#define O_TEXT   0x4000
#define O_BINARY 0x8000

#define O_MODEMASK 0x00F3

/***************** Miscellaneous Definitions *******************/

typedef int jmp_buf[32];

  struct WORDREGS {
       unsigned int ax;
       unsigned int bx;
       unsigned int cx;
       unsigned int dx;
       unsigned int si;
       unsigned int di;
       unsigned int cflag;
       };
  struct BYTEREGS {
       unsigned char al, ah;
       unsigned char bl, bh;
       unsigned char cl, ch;
       unsigned char dl, dh;
       };
  union REGS {
       struct WORDREGS x;
       struct WORDREGS word;
       struct BYTEREGS h;
       struct BYTEREGS byte;
       };

  struct SREGS {
       unsigned int es;
       unsigned int cs;
       unsigned int ss;
       unsigned int ds;
       };

struct DOSERROR {
   int exterror;
   char class;
   char action;
   char locus;
   };

struct date {
   int da_year;
   char da_day;
   char da_mon;
   };

struct time {
   unsigned char ti_min;
   unsigned char ti_hour;
   unsigned char ti_hund;
   unsigned char ti_sec;
   };

struct dfree {
   unsigned df_avail;         /* available clusters */
   unsigned df_total;         /* total clusters */
   unsigned df_bsec;          /* bytes per sector */
   unsigned df_sclus;         /* sectors per cluster */
   };

struct fatinfo {
   char fi_sclus;             /* Sectors per cluster */
   char fi_fatid;             /* identification byte */
   int  fi_nclus;             /* number of clusters */
   int  fi_bysec;             /* bytes per sector */
   };

struct ftime {
   unsigned ft_tsec : 5;      /* two seconds */
   unsigned ft_min  : 6;      /* minutes */
   unsigned ft_hour : 5;      /* hours */
   unsigned ft_day  : 5;      /* day of month */
   unsigned ft_month: 4;      /* month */
   unsigned ft_year : 7;      /* year - 1980 */
   };

#define clock_t long

/**************************************************************/
/*   math.h */

struct complex {
   double x;
   double y;
   };

struct exception {
   int type;      /* type of exception */
   char *name;    /* name of function */
   double arg1;   /* first argument to function */
   double arg2;   /* second argument to function */
   double retval; /* value to be returned if error is not fatal */
   };

/* exception types */

#define DOMAIN    1   /* not in domain of function */
#define SING      2   /* singularity (function not defined) */
#define OVERFLOW  3   /* result too large */
#define UNDERFLOW 4   /* result too small */
#define TLOSS     5   /* total loss of precision */
#define PLOSS     6   /* partial loss of precision */

/**************************************************************/
/*   signal.h */

#define SIGABRT  1
#define SIGINT   2
#define SIGFPE   8

/**************************************************************/
/*   time.h */

struct tm {
   int tm_sec;
   int tm_min;
   int tm_hour;
   int tm_mday;
   int tm_mon;
   int tm_year;
   int tm_wday;
   int tm_yday;
   int tm_isdst;
   };
typedef long time_t;

/**************************************************************/
/* timeb.h  */

struct timeb {
   time_t time;
   int millitm;
   int timezone;
   int dstflag;
   };

/**************************************************************/
/*   exec and spawn  */

extern  int       _p_overlay;
#define P_WAIT    0
#define P_NOWAIT  1
#define P_OVERLAY _p_overlay

/* #define S_IREAD  0x0100 */
/* #define S_IWRITE 0x0080 */

/**************************************************************/
/*  stat.h - structure for stat() and fstat() */

struct statstr {
   short st_dev;
   unsigned short st_ino;
   unsigned short st_mode;
   short st_nlink;
   short st_uid;
   short st_gid;
   short st_rdev;
   long st_size;
   long st_atime;
   long st_mtime;
   long st_ctime;
   };

#define S_IFMT 0xf000      /* type mask */
#define S_IFDIR 0x4000
#define S_IFCHR 0x2000
#define S_IFREG 0x8000
#define S_IREAD 0x0100
#define S_IWRITE 0x0080
#define S_IEXEC 0x0040

/**************************************************************/
/* errors */

#define  EZERO      0
#define  EPERM      1
#define  ENOENT     2
#define  ESRCH      3
#define  EINTR      4
#define  EIO        5
#define  ENXIO      6
#define  E2BIG      7
#define  ENOEXEC    8
#define  EBADF      9
#define  ECHILD    10
#define  EAGAIN    11
#define  ENOMEM    12
#define  EACCES    13
#define  EFAULT    14
#define  ENOTBLK   15
#define  EBUSY     16
#define  EEXIST    17
#define  EXDEV     18
#define  ENODEV    19
#define  ENOTDIR   20
#define  EISDIR    21
#define  EINVAL    22
#define  ENFILE    23
#define  EMFILE    24
#define  ENOTTY    25
#define  ETXTBSY   26
#define  EFBIG     27
#define  ENOSPC    28
#define  ESPIPE    29
#define  EROFS     30
#define  EMLINK    31
#define  EPIPE     32
#define  EDOM      33
#define  ERANGE    34
#define  EUCLEAN   35
#define  EDEADLOCK 36
/*$list*//*$trace       <<< std_lib.h >>> */
