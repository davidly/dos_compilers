#include <stdio.h>
#include <dos.h>
#include <process.h>
#include <fcntl.h>
#include <stat.h>

/*   Functions present in Mix C that are not in the Power C
     standard libraries.  Also includes functions (such as
     chmod) whose definition has been changed.  For portability
     from mix c, this library should be searched first.
     It is recommended that these functions not be used in
     new programs.
     */

typedef union {   /* register structure used by asm and asmx */
    struct {
       char al, ah, bl, bh, cl, ch, dl, dh;
    } byte;
    struct {
       int ax, bx, cx, dx, si, di, bp, es, ds, cs;
    } word;
} MREGS;

int asm(address, bx)
   int address;   /* address of code (in data segment) */
   int bx;        /* value to pass in bx register */
{
   MREGS r;
   r.word.bx = bx;
   return asmx(address,&r);
   }

int bdos(fn, dx)
   int fn;        /* function number */
   int dx;        /* value to pass in dx */
{
   union REGS r;
   r.h.ah = fn;
   r.x.dx = dx;
   intdos(&r, &r);
   return r.h.al;
   }

chain(command)
   char *command;
{
   static char nullchar = '\0';
   char filename[130];
   char *p, *q;
   int  argc;
   char *argv[32];
   p = command;
   q = filename;
   while (*p != ' ' && *p != '/' && *p != '\0') *q++ = *p++;
   *q = '\0';
   argv[0] = &nullchar;
   argc = 1;
   while (*p != '\0' && argc < 32) {
      while (*p == ' ') ++p;
      if (*p != '\0') {
         argv[argc] = p;
         argc++;
         while (*p != ' ' && *p != '\0') ++p;
         *p = '\0';
         }
      }
   return execvp(filename,argv);
   }  /* chain */

chmod(name, mode)
   char *name;    /* name of file */
   int  mode;     /* new mode */
{
   extern int errno, _doserrno;
   int status;
   if (_sysacdc(0x4301,mode,name,&status) == 0) return 0;
   errno = _doserrno;
   return -1;
   }

creat(name, mode)
char *name;
int mode;
{
   int fd, status;
   fd = open(name,O_CREAT|O_RDWR|O_TRUNC,S_IREAD|S_IWRITE);
   if (fd != -1) _sys_acd(0x4300,mode,name,&status);
   return fd;
   }

exec(command)
   char *command;
{
   static char nullchar = '\0';
   char filename[130];
   char *p, *q;
   int  argc;
   char *argv[32];
   p = command;
   q = filename;
   while (*p != ' ' && *p != '/' && *p != '\0') *q++ = *p++;
   *q = '\0';
   argv[0] = &nullchar;
   argc = 1;
   while (*p != '\0' && argc < 32) {
      while (*p == ' ') ++p;
      if (*p != '\0') {
         argv[argc] = p;
         argc++;
         while (*p != ' ' && *p != '\0') ++p;
         *p = '\0';
         }
      }
   return spawnvp(P_WAIT,filename,argv);
   }  /* exec */

getd(dptr, fp)
   double *dptr;
   FILE *fp;
{
   char buffer[128];
   char *p;
   int c;
   while (isspace(c = fgetc(fp)));
   if (c == '+' || c == '-') *p++ = c;
   while (isdigit(c)) { *p++ = c; c = fgetc(fp); }
   if (c == '.') {
      *p++ = c;
      c = fgetc(fp);
      while (isdigit(c = fgetc(fp))) {*p++ = c; c = fgetc(fp); }
      }
   if (toupper(c) == 'E') {
      *p++ = c;
      c = fgetc(fp);
      while (isdigit(c = fgetc(fp))) {*p++ = c; c = fgetc(fp); }
      }
   if (c != -1) ungetc(c,fp);
   *dptr = atof(buffer);
   return 0;
   }

geti(iptr, fp)
   int *iptr;
   FILE *fp;
{
   char buffer[128];
   char *p;
   int c;
   while (isspace(c = fgetc(fp)));
   if (c == '+' || c == '-') *p++ = c;
   while (isdigit(c = fgetc(fp))) *p++ = c;
   *p = '\0';
   if (p == buffer) return -1;
   if (c != -1) ungetc(c,fp);
   *iptr = atio(buffer);
   return 0;
   }

getmode()
{
  return getvmode();
  }

int puti(i, fp)
   int i;
   FILE *fp;
{
   char buffer[16];
   __itoa(i,buffer);
   return fputs(buffer,fp);
   }

itoa(n,s)
int     n;
char    *s;
{
   return __itoa(n,s);
   }

__itoa(n, s)
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

int open(name, rwmode)
   char *name;
   int rwmode;
{
   int openmode;
   int r;
   r = rwmode & 0x03;
   if (r == 0) openmode = O_RDONLY;
   else if (r == 1) openmode = O_WRONLY;
   else openmode = O_RDWR;
   if (rwmode & 0x8000) openmode += O_BINARY;
   return _open(name,openmode,0);
   }

int peek(address)
   char *address;
{
   return *address;
   }

int putd(d, fp)
   double d;
   FILE *fp;
{
   char buffer[64];
   ftoa(d,buffer,0x8a,1,16);
   return fputs(buffer,fp);
   }

setdate(s)
char *s;
{
   int mm, dd, yy;
   int result;
   mm = (*s++ - '0')*10 + *s++ - '0';
   ++s;
   dd = (*s++ - '0')*10 + *s++ - '0';
   ++s;
   yy = (*s++ - '0')*10 + *s++ - '0';
   _sys_acd(0x2b00,yy+1900,(mm<<8)+dd,&result);
   return;
}

setmode(mode)
   int mode;
{
  return setvmode(mode);
  }

settime(s)
char *s;
{
   int hh, mm, ss;
   int result;
   hh = (*s++ - '0')*10 + *s++ - '0';
   ++s;
   mm = (*s++ - '0')*10 + *s++ - '0';
   ++s;
   ss = (*s++ - '0')*10 + *s++ - '0';
   _sys_acd(0x2b00,(hh<<8)+mm,ss<<8,&result);
   return;
}

double sqr(x)
   double x;
{
   return x*x;
   }

char *strsave(s)
   char *s;
{
   return strdup(s);
   }
