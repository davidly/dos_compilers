   typedef struct {
      char      init;      /* initialized flag */
      char      openflg;   /* file open */
      int       handle;    /* file handle */
      char      *bufr;     /* start of buffer */
      char      *ptr;      /* address of next character */
      int       count;     /* number of characters left in bufr */
      int       bufsize;   /* size of buffer */
      int       reclen;    /* record length */
      char      device;    /* device code */
      char      eofflag;   /* end of file detected */
      char      mode;      /* read, write or read/write */
      char      dirty;     /* buffer written to */
      char      error;     /* error code */
      char      flags;     /* control flags */
      char      column;    /* column (text files */
      char      ungetch;   /* character from ungetc (unbuffered files) */
      char      *gpbufr;   /* buffer used by get & put */
      char      *pathnm;   /* name of file */
      char      flag2;     /* more flags */
      char      fill2[5];
      } fdb;

#define fdbinary 0x02
#define fdctlz   0x04
#define fdfilter 0x08
#define fdecho   0x10
#define fdunbufr 0x20
#define fdappend 0x40
#define fdsetbuf 0x80
#define fdwrite  0x01
#define fdread   0x02
#define fd2temp  0x01
