#include <stdio.h>
#include <stdlib.h>

#define  MAXARGS   20
#define  FALSE     0
#define  TRUE      1

_initio(stdfiles)
int     stdfiles;                /*stdfiles = 1 says open standard files*/
{
    extern  char   *_flagptr;
    extern  char   *_procptr;
    extern  int    _seed;
    char    indevice[]  = ":i";
    char    outdevice[] = ":o";
    char    errdevice[] = ":e";
    char    *STDIN, *STDOUT, *STDERR;
    char    cmdbuffer[128];
    char    *cmdline;
    char    *argv[MAXARGS];      /*pointers to command line arguments*/
    char    nullchar = NULL;
    char    mode[] = "w";
    int     argc;                /*number of command line arguments*/
    int     i;
    int     count;
    int     fopen();
    int     main();
    int     exit();
    int     movmem();
    int     filetrap();
    int     heaptrap();
    int     mathtrap();
    int     _getflag();
    int     _getproc();

    _flagptr = _getflag();
    _procptr = _getproc();
    _seed = 13849;
    heaptrap(0);
    filetrap(0);
    mathtrap(0);
    STDIN  = indevice;
    STDOUT = outdevice;
    STDERR = errdevice;
    for (i=0; i < MAXFILES; i++) _iob[i] = NULL;
    movmem(0x80, cmdbuffer, 128);
    count = cmdbuffer[0];
    cmdline = &cmdbuffer[1];
    argv[0] = &nullchar;
    argc = 1;
    while (count > 0 && argc < MAXARGS) {
        while (*cmdline == ' ' && count) {
            count--;
            cmdline++;
        }
        if (count) {
            if (*cmdline == '<') {
                STDIN = ++cmdline;
                count--;
            }
            else if (*cmdline == '>') {
                cmdline++;
                count--;
                if (*cmdline == '>') {
                    cmdline++;
                    count--;
                    mode[0] = 'a';
                }
                STDOUT = cmdline;
            }
            else {
                argv[argc] = cmdline;
                argc++;
            }
            while (*cmdline != ' ' && count) {
                cmdline++;
                count--;
            }
            *cmdline++ = '\0';
            count--;
        }
    }
    if (stdfiles == 1) {
        fopen(STDIN,"r");
        fopen(STDOUT,mode);
        fopen(STDERR,"w");
    }
    exit(main(argc,argv));
}

abs(i)
int i;
{
    if (i < 0) return -i;
    else return i;
}

atoi(s)                          /* decode an integer */
char    *s;                      /* pointer to integer string */
{
    int     sflag = 1, value = 0;
    while (*s == ' ' || *s == '\t' || *s == '\n') ++s;
    if (*s == '+' || *s == '-')
        if (*s++ == '-') sflag = -1;
    while (*s > 47 && *s < 58) value = 10 * value + (*s++ - 48);
    return value * sflag;
}

long atol(s)                     /* decode a long integer */
char    *s;                      /* pointer to integer string */
{
    int     sflag = 1;
    long    value = 0, base = 10;
    while (*s == 32 || *s == 9 || *s == 13) ++s;
    if (*s == '+' || *s == '-')
        if (*s++ == '-') sflag = -1;
    while (*s > 47 && *s < 58) value = base * value + (*s++ - 48);
    return value * sflag;
}

itoa(n, s)
int     n;
char    *s;
{
    char buffer[7], flag = '\0', *ptr;
    buffer[6] = '\0';
    ptr = &buffer[5];
    if (n < 0) {
       if (n == -32768) {
          strcpy(s, "-32768");
          return;
       }
       ++flag;
       n = -n;
    }
    do {
       *(ptr--) = n  % 10 + 48;
    } while ((n /= 10) > 0);
    if (flag) *ptr = '-';
    else ptr++;
    strcpy(s, ptr);
    return;
}

ltoa(n, s)
long    n;
char    *s;
{
    char buffer[12], flag, *ptr;
    flag = '\0';
    buffer[11] = '\0';
    ptr = &buffer[10];
    if (n < 0) {
       if (n == -2147483648) {
          strcpy(s, "-2147483648");
          return;
       }
       ++flag;
       n = -n;
    }
    do {
       *(ptr--) = n  % 10 + 48;
    } while ((n /= 10) > 0);
    if (flag) *ptr = '-';
    else ptr++;
    strcpy(s, ptr);
    return;
}

_atoi(ptr)                          /* decode an integer */
char    **ptr;                      /* pointer to addr of 1st digit */
{
    int     n = 0;
    while (*(*ptr) > 47 && *(*ptr) < 58) n = 10 * n + *(*ptr)++ - 48;
    return n;
}

rand()
{
    extern long _seed;
    _seed = _seed * 15790321;
    return  (int) ((_seed >> 17) & 0x7FFF);
}

ungetc(c,fp)
int     c;
FILE    *fp;
{
   if (c != EOF) {
      --fp->file[12];
      *((char *)(*(int *)&fp->file[10])+fp->file[12]) = c;
      }
}

execl(filename, args)
char *filename, *args;
{
    return _execlv(filename, &args, -1);
}

execv(filename, args)
char *filename, **args;
{
    return _execlv(filename, args, 1);
}

chain(filename)
char filename[];
{
    char cmdlin[129];
    char *arg[65];
    int  i = 0, c = 0;
    strncpy(cmdlin, filename, 128);
    cmdlin[128] = 0;
    while (cmdlin[i]) {
        while (cmdlin[i] == ' ') i++;
        if (cmdlin[i]) arg[c++] = &cmdlin[i];
        while (cmdlin[i] != ' ' && cmdlin[i] != 0) i++;
        if (cmdlin[i]) cmdlin[i++] = 0;
    }
    arg[c] = NULL;
    return _execlv(arg[0], arg, 1);
}

_execlv(filename, argptr, increment)
char *filename, **argptr;
int  increment;
{
    char *sptr;
    char c, name[64];
    char cmdlin[128];
    FILE *fp, *fopen();
    int  n = 0, extension = 0;
    while ((c = *filename++) && n < 63) {
        name[n++] = c;
        if (c == '.') ++extension;
        }
    if (!extension && n < 61) strcpy(&name[n], ".COM");
    else name[n] = '\0';
    fp = fopen(name, "r");
    if (fp != NULL) {
       cmdlin[0] = '\0';
       n = 1;
       if (*(argptr)) argptr = argptr + increment;
       while (sptr = *(argptr)) {
           argptr = argptr + increment;
           while ((c = *sptr++) && n < 126) cmdlin[n++] = c;
           cmdlin[0] = n - 1;
           cmdlin[n++] = ' ';
       }
       cmdlin[n] = '\r';
       _chain(fp, cmdlin);
    }
    else return -1;
}

FILE *fdopen(fd, type)
int  fd;
char *type;
{
    FILE *fp;
    int  c;
    fp = _iob[fd];
    if (fp != NULL) {
        c = tolower(*type);
        if ((c == 'w') || (c == 'a')) {
            if (fp->file[16]) return fp;
            else return NULL;
        }
        if ((c == 'r') && (!fp->file[16])) return fp;
        else return NULL;
    }
    else return NULL;
}

FILE *freopen(filename, type, old_fp)
char *filename, *type;
FILE *old_fp;
{
    FILE *fopen();
    if (fclose(old_fp)) return NULL;
    else return fopen(filename, type);
}

FILE *fopen(name,modes)
char *name, *modes;
{
    char c;
    int  fd, mode = 0;
    void _creat(), _openr(), _opena(), _fopenrw(), _openrw(), (*funcptr)();
    long lseek();
    int iomode = 0;
    FILE *fp;
    while ((c = tolower(*modes++))) {
        switch(c) {
            case 'w': funcptr = _creat; iomode = 1; break;
            case 'a': funcptr = _opena; iomode = 2; break;
            case 'r': funcptr = _openr; break;
            case '+':
                if (iomode == 0) funcptr = _openrw;
                else funcptr = _fopenrw;
                break;
            case 'b': mode = 0x8000;
        }
    }
    if ((fd = _open(name, funcptr, mode)) == -1) return NULL;
    if (iomode == 2) lseek(fd,0l,2);
    return _iob[fd];
}

creat(name, mode)
char *name;
int  mode;
{
    int _creat();
    return _open(name, _creat, mode);
}

open(name, mode)
char *name;
int  mode;
{
    void _openr(), _openw(), _openrw(), (*funcptr)();
    int modemask;
    modemask = mode & 0x7FFF;
    if (modemask == 0) funcptr = _openr;
    else
        if (modemask == 1) funcptr = _openw;
        else
            funcptr = _openrw;
    return _open(name, funcptr, mode);
}

_open(name, funcptr, mode)
char name[];
void (*funcptr)();
int  mode;
{
    extern int errno;
    int fd;
    int len;
    char c,id[8],*buffer;
    FILE *fp;
    void _setname();
    fd = 0;
    while (fd < MAXFILES && _iob[fd] != NULL) fd++;
    if (fd < MAXFILES) {
        id[0] = 'F';
        for (len=0; (c = name[len]) != '\0'; len++)
        if (len < 7) id[len+1] = c;
        _iob[fd] = fp = calloc(1, sizeof(FILE));
        if (fp) {
            fp->fd = fd;
            _setname(fp, name, len, id);
            if (!(fp->file[18])) {
                (*funcptr)(mode, fp, id);
                if (fp->file[17] != '\0') {
                    if (mode < 0) fp->file[23] = '\2';
                    return fd;
                }
                else {
                   _iob[fd] = NULL;
                   buffer = *((char **) &fp->file[8]);
                   free(*((char **) (buffer - 11)));
                   free(buffer - 16);
                   free(*((char **) &fp->file[21]));
                   free(fp);
                   return -1;
                }
            }
            else {
                errno = fp->file[18];
                return -1;
            }
        }
        else return -1;
    }
    else return -1;
}

close(fd)
int  fd;
{
   return fclose(_iob[fd]);
}

fclose(fp)
FILE    *fp;
{
   void _close();
   _close(fp);
   if (fp->file[17]) return -1;
   else {
       _iob[fp->fd] = NULL;
       free(fp);
       return 0;
   }
}

exit(status)
int status;
{
   int  i;
   int  _exit();
   void _close();
   i = 0;
   while (i < MAXFILES) {
      if (_iob[i] != NULL) _close(_iob[i]->file);
      i++;
   }
   _exit(status);
}

isalpha(c)                      /* returns c is alphabetic */
int     c;                      /*    else returns 0       */
{
    if (c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z') return 1;
    else return 0;
}

isdigit(c)
int     c;
{
    if (c >= '0' && c <= '9') return 1;
    else return 0;
}

isspace(c)
int     c;
{
    if (c == ' ' || c == '\t' || c == '\n') return 1;
    else return 0;
}

islower(c)
int     c;
{
    if (c >= 'a' && c <= 'z') return 1;
    else return 0;
}

isupper(c)
int     c;
{
    if (c >= 'A' && c <= 'Z') return 1;
    else return 0;
}

isalnum(c)
int c;
{
    if ((c >= 48 && c <=  57) ||
        (c >= 65 && c <=  90) ||
        (c >= 97 && c <= 122)) return 1;
    else return 0;
}

isascii(c)
int c;
{
    if (c < 128) return 1;
    else return 0;
}

iscntrl(c)
int c;
{
    if ((c < 32) || (c == 127)) return 1;
    else return 0;
}

isprint(c)
int c;
{
    if ((c > 31) && (c < 127)) return 1;
    else return 0;
}

ispunct(c)
int c;
{
    if ((c > 31 && c <  48) ||
        (c > 57 && c <  65) ||
        (c > 90 && c <  97) ||
        (c >122 && c < 127)) return 1;
    else return 0;
}

toupper(c)
int     c;
{
    if (c >= 'a' && c <= 'z') c -= 32;
    return c;
}

tolower(c)
int     c;
{
    if (c >= 'A' && c <= 'Z') c += 32;
    return c;
}

char *index(s, c)
char *s;
int  c;
{
    while (*s != c && *s != 0) s++;
    if (*s) return s;
    else return NULL;
}

char *rindex(s, c)
char *s;
int  c;
{
    int len;
    len = strlen(s);
    if (len) {
       s = s + len - 1;
       while (*s != c && len) {
          s--;
          len--;
       }
       if (len) return s;
    }
    return NULL;
}

char *strsave(s)
char    *s;
{
    char    *ptr;
    char    *calloc();
    int     len;
    if (ptr = malloc(len = strlen(s)+1)) movmem(s, ptr, len);
    return(ptr);
}

strcpy(dest, source)
char    *dest;
char    *source;
{
   movmem(source, dest, strlen(source)+1);
   return(dest);
}

strcmp(first, second)
char    *first;
char    *second;
{
    while (*first == *second) {
       if (*first) {
           first++;
           second++;
       }
       else return 0;
    }
    return *first - *second;
}

strcat(first, second)
char    *first;
char    *second;
{
    movmem(second, first + strlen(first), strlen(second)+1);
    return(first);
}

strncpy(dest, source, n)
char    *dest;
char    *source;
int     n;
{
   int  len;
   movmem(source, dest, (len = strlen(source)+1) < n ? len : n);
   return(dest);
}

strncmp(first, second, n)
char    *first;
char    *second;
int     n;
{
    while ((n--) && (*first == *second)) {
       if (*first) {
           if (n) {
               first++;
               second++;
           }
       }
       else return 0;
    }
    return *first - *second;
}

strncat(first, second, n)
char    *first;
char    *second;
int     n;
{
    int len;
    movmem(second, first + strlen(first),
          ((len = strlen(second)+1) < n ? len : n));
    return(first);
}

perror(s)
char *s;
{
    extern int  errno;
    extern int  sys_nerr;
    extern char *sys_errlist[];
    extern char *int_errlist[];
    fputs(s, stderr); putc(':', stderr);
    if (errno <= sys_nerr) fputs(sys_errlist[errno], stderr);
    else
        if (errno > 0x80 && errno < 0x97)
            fputs(int_errlist[errno - 0x81], stderr);
    else
        fputs("Error Cause Unknown", stderr);
    putc('\n', stderr);
}

char *gets(s)                       /* reads one line from stdin */
char    *s;                         /*      into string s        */
                                    /* newline replaced by '\0'  */
{
    int     _fgets();
    char    c;
    if (_fgets(stdin, s, &c, '\n', 32767) > 0 || c == '\n')
        return s;
    else return NULL;
}

char *fgets(s, n, fp)               /* read a line from fp */
char    *s;                         /*      into s         */
int     n;                          /* maximum characters  */
FILE    *fp;                        /*      is n-1         */
{
    int     _fgets();
    int     count;
    char    c;
    if (n > 1) {
        count = _fgets(fp, s, &c, '\n', n);
        if (c == '\n') {
            *(s+count++) = c;
            *(s+count) = NULL;
        }
        else if (count < 1) return NULL;
    }
    else *s = NULL;
    return s;
}

char *puts(s)                   /* write s to stdout */
char    *s;
{
    int     _write();
    int     strlen();
    _write(stdout, s, strlen(s));
    if (putc('\n', stdout) != EOF) return s;
    else return EOF;
}

char *fputs(s, fp)              /* write s to fp */
char    *s;
FILE    *fp;
{
    int     _write();
    int     strlen();
    if (_write(fp, s, strlen(s)) < 0) return EOF;
    else return s;
}

STRING *stods(s)                    /* convert string to dynamic string */
char    *s;                         /* s is a normal C string */
{
   int    length;
   STRING *ptr;
   STRING *calloc();
   int    strlen();                 /* get length of string */
   length = strlen(s);
   ptr = malloc(sizeof(int) + length);
   if (ptr != NULL) {
      ptr->length = length;
      movmem(s, ptr->string, length);
   }
   return ptr;
}

dstos(ptr,s)                 /* convert dynamic string into normal C string */
STRING  *ptr;                /* pointer to dynamic string */
char    *s;                  /* normal string */
{
   movmem(ptr->string, s, ptr->length);
   *(s + ptr->length) = '\0';
}

clearerr(fp)
FILE *fp;
{
    fp->file[18] = '\0';
}

ferror(fp)
FILE *fp;
{
    return fp->file[18];
}

fflush(fp)
FILE *fp;
{
    long fseek();
    if (fseek(fp, 0L, 1) == -1) return -1;
    else return 0;
}

fileno(fp)
FILE *fp;
{
    return fp->fd;
}


double hypot(x, y)
double x,y;
{
    double sqrt();
    return (sqrt(x*x + y*y));
}

double log10(x)
double x;
{
    double log();
    return log(x) / 2.302585093;
}


char *realloc(oldptr, newsize)
char *oldptr;
int  newsize;
{
    char *newptr, *malloc();
    if (newptr = malloc(newsize)) {
        movmem(oldptr, newptr, newsize);
        free(oldptr);
        return newptr;
    }
    else return NULL;
}

rewind(fp)
FILE *fp;
{
    return fseek(fp, 0L, 0);
}

ungetch(c)
int c;
{
    extern char _ungetch;
    return _ungetch ?  EOF : (_ungetch = c);
}

setbufsiz(size)
int size;
{
    extern char *_flagptr;
    int  blocks, *sizeptr;
    blocks = (size/128) <= 0 ? 1 : (size/128);
    *(_flagptr + 8) = blocks;
    sizeptr = _flagptr + 9;
    *sizeptr = blocks * 128;
}

setbuf(fp, bufptr)
FILE *fp;
char *bufptr;
{
    char **oldbufptr, **oldbuforg;
    if (fp) {
        if (bufptr) {
            oldbuforg = &(fp->file[21]);
            oldbufptr = &(fp->file[10]);
            free(*oldbuforg);
            *oldbuforg = *oldbufptr = bufptr;
        }
        else fp->file[14] = '\100';
    }
}

conbuf(flag)
int flag;
{
    return _setflag(flag, 42);
}

mathtrap(flag)
int flag;
{
    return _setflag(flag, 43);
}

exitmsg()
{
    _setflag(0, 3);
}

_setflag(flag, offset)
int flag, offset;
{
    extern char *_flagptr;
    char oldvalue;
    oldvalue = *(_flagptr + offset);
    *(_flagptr + offset) = flag;
    return oldvalue;
}

filetrap(flag)
int flag;
{
    return _settrap(flag, 62);
}

heaptrap(flag)
int flag;
{
    return _settrap(flag, 63);
}

_settrap(flag, offset)
int  flag, offset;
{
    extern char *_procptr;
    char oldflag;
    oldflag = *(_procptr + offset);
    *(_procptr + offset) = flag;
    return oldflag;
}

iofilter(linefeed, ctrlz)
int linefeed, ctrlz;
{
    extern char *_flagptr;
    *(_flagptr +  4) = linefeed;
    *(_flagptr +  5) = ctrlz;
}


/*******************  MSDOS Functions ********************/

chdir(dirname)
char *dirname;
{
    REGS reg;
    return _syscall(0x3B, dirname, &reg);
}

chmod(name, mode)
char *name;
int  mode;
{
    REGS reg;
    reg.word.cx = mode;
    reg.byte.al = 1;
    return _syscall(0x43, name, &reg);
}

getch()
{
    extern char _ungetch;
    char ch;
    if (ch = _ungetch) {
        _ungetch = '\0';
        return ch;
    }
    else return bdos(0x07, 0);
}

putch(c)
int c;
{
    bdos(0x06, c);
}

getkey()
{
    REGS reg;
    reg.byte.dl = 0xFF;
    if (bdosx(0x06, &reg) & 0x40) return EOF;
    else return reg.byte.al;
}

keypress()
{
    return bdos(0x0B, 0);
}

unlink(name)
char *name;
{
    REGS reg;
    return _syscall(0x41, name, &reg);
}

mkdir(dirname)
char *dirname;
{
    REGS reg;
    return _syscall(0x39, dirname, &reg);
}

rmdir(dirname)
char *dirname;
{
   REGS reg;
   return _syscall(0x3A, dirname, &reg);
}

rename(oldname, newname)
char *oldname, *newname;
{
    REGS reg;
    reg.word.di = newname;
    if (_syscall(0x56, oldname, &reg)) return EOF;
    else return 0;
}

settime(s)
char *s;
{
    return _settd(0, s);
}

setdate(s)
char *s;
{
    return _settd(1, s);
}

_syscall(fn, s, regptr)
int fn;
char *s;
REGS *regptr;
{
   regptr->word.ds = regptr->word.es = getdseg();
   regptr->word.dx = s;
   if (bdosx(fn, regptr) & 0x0001) return regptr->word.ax;
   else return 0;
}

/*******************  IBM PC BIOS Functions ********************/

cursblk()
{
    _setcurs(0, _graphic() ? 7 : 13);
}

curslin()
{
    int start;
    _setcurs((start = _graphic() ? 7 : 13), start);
}

_graphic()  /* returns 1 if graphics display, 0 if monochrome */
{
    REGS reg;
    int display;
    bios(0x11, &reg); /* get display type (bits 4 and 5 of ax) */
    if ((reg.word.ax & 0x30) < 0x30) return 1; /* graphics   */
    else return 0;                        /* monochrome */
}

curson()  /* set bit 5 of start scan line to 0 : IBM PC      */
{         /* set bit 6 of start scan line to 0 : Tandy 2000
             use & 0x00BF                                    */
    unsigned cursor, _getcurs();
    cursor = _getcurs();
    _setcurs((cursor >> 8) & 0x00DF, cursor & 0x00FF);
}

cursoff() /* set bit 5 of start scan line to 1 : IBM PC      */
{         /* set bit 6 of start scan line to 1 : Tandy 2000
             use | 0x0040                            */
    unsigned cursor, _getcurs();
    cursor = _getcurs();
    _setcurs((cursor >> 8) | 0x0020, cursor & 0x00FF);
}

unsigned _getcurs()
{
    REGS reg;
    reg.byte.ah = 3;
    reg.byte.bh = 0;
    bios(0x10, &reg);
    return reg.word.cx;
}

_setcurs(start, stop)
int start, stop;
{
    REGS reg;
    reg.byte.ah = 1;
    reg.byte.ch = start;
    reg.byte.cl = stop;
    bios(0x10, &reg);
}

clrscrn()
{
    REGS reg;
    reg.byte.ah = 6;
    reg.byte.al = reg.byte.ch = reg.byte.cl = 0;
    reg.byte.dh = 24; reg.byte.dl = 79;
    reg.byte.bh = 7;
    bios(0x10, &reg);
    poscurs(0,0);
}

clrscrn2(attribute)
unsigned int attribute;
{
    REGS reg;
    reg.byte.ah = 6;
    reg.byte.al = reg.byte.ch = reg.byte.cl = 0;
    reg.byte.dh = 24; reg.byte.dl = 79;
    reg.byte.bh = attribute;
    bios(0x10, &reg);
    poscurs(0,0);
}

getmode()
{
    REGS reg;
    reg.byte.ah = 15;
    bios(0x10, &reg);
    return reg.byte.al;
}

setmode(mode)
int mode;
{
    REGS reg;
    reg.byte.ah = 0;
    reg.byte.al = mode;
    bios(0x10, &reg);
}

setcolor(background, palette)
int background, palette;
{
    REGS reg;
    reg.byte.ah = 11;
    reg.byte.bh = 0;
    reg.byte.bl = background;
    bios(0x10, &reg);
    reg.byte.bh = 1;
    reg.byte.bl = palette;
    bios(0x10, &reg);
}

/*******************  External Variables ********************/

FILE    *_iob[MAXFILES];
char    _ungetch = '\0';
char    *_flagptr;
char    *_procptr;
int     sys_nerr = 17;
long    _seed;

_dumy1_(){}

char    *sys_errlist[] = {"No Errors",
                          "Invalid Function Number",
                          "File not Found",
                          "Path not Found",
                          "No More File Handles",
                          "File Access Denied",
                          "Invalid  File Handle",
                          "Memory Blocks Destroyed",
                          "Insufficient Memory",
                          "Invalid Block Address",
                          "Invalid Environment",
                          "Invalid Format",
                          "Invalid Access Code",
                          "Invalid Data",
                          "Invalid Drive",
                          "Can't Remove Current Directory",
                          "Not Same Device",
                          "No More Files"                    };

_dumy2_(){}

char    *int_errlist[] = {"Out of Stack",
                          "Out of Heap",
                          "Damaged Stack or Heap",
                          "Damaged Stack or Heap",
                          "Divide by Zero",
                          "Invalid Instruction",
                          "Damaged Stack or Heap",
                          "Damaged Stack or Heap",
                          "I/O Error",
                          "Error Cause Unknown",
                          "Attempt to Write Input",
                          "File Not Open",
                          "Attempt to Read Output",
                          "No Memory for File Buffer",
                          "Error Cause Unknown",
                          "Damaged Stack or Heap",
                          "Bad Digit in Number",
                          "Damaged Stack or Heap",
                          "Arithmetic Overflow",
                          "Error Cause Unknown",
                          "Arithmetic Underflow",
                          "Log of Negative Number",
                          "Sqrt of Negative Number" };
