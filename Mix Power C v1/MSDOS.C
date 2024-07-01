
/* MSDOS Functions */
/*   Copyright (c) Mix Software 1988    */

chdir(dirname)
char *dirname;
{
   extern int errno;
   extern int _doserrno;
   int result;
   int _sys_ad();
   if (_sys_ad(0x3b00,dirname,&result) == 0) return 0;
   errno = ENOENT;
   return -1;
}

/* ------------------------------------------------------------ */

char *getcwd(pathbuf,n)    /* get current working directory */
   char *pathbuf;    /* buffer for result */
   int n;            /* maximum length of result */
{
   extern int errno,_doserrno;
   int drive;
   char buf[64];
   char *path;
   union REGS reg;
   if (pathbuf == NULL) {
      pathbuf = malloc(n);
      if (pathbuf == NULL) return NULL;
      }
   reg.x.ax = 0x4700;
   reg.h.dl = 0;
   reg.x.si = buf;
   intdos(&reg,&reg);
   if (reg.x.cflag) { errno = _doserrno; return -1; }
   if (strlen(buf)+3 >= n) { errno = ERANGE; return -1; }
   drive = _sys_al(0x1900);
   path = pathbuf;
   *path++ = drive + 'A';
   *path++ = ':';
   *path++ = '\\';
   strcpy(path,buf);
   return pathbuf;
}

/* ------------------------------------------------------------ */

getch()
{
    extern int _ungetch;
    int ch = _ungetch;
    if (ch != EOF) {
        _ungetch = EOF;
        return ch;
    }
    else return _sys_al(0x0700);
}

/* ------------------------------------------------------------ */

void putch(c)
   int c;
{
   int s;
    _sys_ad(0x0600,c,&s);
}

/* ------------------------------------------------------------ */

getche()
{
   return _sys_al(0x0100);
}

/* ------------------------------------------------------------ */

getkey()
{
    union REGS reg;
    int bdosx();
    reg.h.dl = 0xFF;
    if (bdosx(0x06, &reg) & 0x40) return EOF;
    else return reg.h.al;
}

/* ------------------------------------------------------------ */

int isatty(fd)
   int fd;
{
   union REGS reg;
   reg.x.ax = 0x4400;
   reg.x.bx = fd;
   reg.x.cx = 0;
   reg.x.dx = 0;
   intdos(&reg,&reg);
   if (reg.x.cflag != 0) return 0;
   if ((reg.x.dx & 0x0080) == 0) return 0; else return 1;
}

/* ------------------------------------------------------------ */

int kbhit()
{
   return _sys_al(0x0b00);
}

/* ------------------------------------------------------------ */

keypress()
{
   return _sys_al(0x0b00);
}

/* ------------------------------------------------------------ */

unlink(name)
char *name;
{
   extern int errno, _doserrno;
   int _sys_ad();
   int result;
   if (_sys_ad(0x4100,name,&result) == 0) return 0;
   errno = _doserrno;
   return -1;
}

/* ------------------------------------------------------------ */

remove(name)
char *name;
{
   extern int errno, _doserrno;
   int _sys_ad();
   int result;
   if (_sys_ad(0x4100,name,&result) == 0) return 0;
   errno = _doserrno;
   return -1;
}

/* ------------------------------------------------------------ */

mkdir(dirname)
char *dirname;
{
   extern int errno, _doserrno;
   int _sys_ad();
   int result;
   if (_sys_ad(0x3900,dirname,&result) == 0) return 0;
   errno = _doserrno;
   return -1;
}

/* ------------------------------------------------------------ */

rmdir(dirname)
char *dirname;
{
   extern int errno, _doserrno;
   int _sys_ad();
   int result;
   if (_sys_ad(0x3A00,dirname,&result) == 0) return 0;
   errno = _doserrno;
   return -1;
}

/* ------------------------------------------------------------ */

rename(oldname, newname)
char *oldname, *newname;
{
   int _sysdxdi();
   int result;
   extern int errno;
   return _sysdxdi(0x5600,oldname,newname,&result);
}

/* ------------------------------------------------------------ */

int sbrk(incr)
   int incr;
{ return -1; }

int brk(endds)
   int endds;
{ return -1; }

/* ------------------------------------------------------------ */

int getpid()
{
   static unsigned _pid = 0;
   extern unsigned char _osmajor;
   union REGS reg;
   if (_pid != 0) return _pid;
   if (_osmajor > 3) _pid = _sys_al(0x8700);
   if (_pid == 0) {
      reg.h.ah = 0x2c;
      intdos(&reg,&reg);
      _pid = reg.x.dx;
      }
   return _pid;
}

