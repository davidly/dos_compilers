
/* File manipulation */
/*   Copyright (c) Mix Software 1988    */

int access(pathname, mode)    /* can file be accessed in this mode */
   char *pathname;   /* name of file */
   int mode;         /* mode 02 = write, 04 = read, 06 = r/w, 00 = exists */
{
   extern int errno;
   int curmode;
   if (_sysacdc(0x4300, 0, pathname, &curmode) == 0) {
      if (curmode & 0x0001) { /* file is read only */
         if ((mode & 0x0002) == 0) return 0;
         errno = EACCES;
         return -1;
         }
      return 0;
      }
   errno = ENOENT;
   return -1;
   }

/* ------------------------------------------------------------ */

int chmod(pathname, pmode)
   char *pathname;
   int pmode;
{
   extern int errno;
   int mode = 0;
   if (pmode & S_IWRITE) mode = 1;
   if (_sys_acd(0x4300, 0, pathname, &mode) == 0) return 0;
   errno = ENOENT;
   return -1;
   }

/* ------------------------------------------------------------ */

int eof(fd)
   int fd;
{
   extern int errno;
   if ((fd < 0) || (fd >= MAXFILES)) { errno = EBADF; return -1; }
   return feof(_iob[fd]);
}

/* ------------------------------------------------------------ */

int feof(fp)
   FILE *fp;
{
   int c;
   extern int errno;
   if (fp == NULL) { errno = EBADF; return -1; }
   if (fp->file.eofflag) return 1;
   c = _getc(fp);
   ungetc(c,fp);
   if ((fp->file.flags & fdctlz)) {
      if (c == CTLZ) return 1;
      }
   if (c == EOF) {
      if ((fp->file.flags & fdfilter) || fp->file.eofflag) return 1;
      }
   return 0;
   }

/* ------------------------------------------------------------ */

getchar() { return fgetc(stdin); }
fgetchar() { return fgetc(stdin); }

/* ------------------------------------------------------------ */

getc(fp)
   FILE *fp;
{ return fgetc(fp); }

/* ------------------------------------------------------------ */

putchar(c) int c; { return fputc(c,stdout); }
fputchar(c) int c; { return fputc(c,stdout); }

/* ------------------------------------------------------------ */

putc(c,fp)
   int c;
   FILE *fp;
{
   return fputc(c,fp);
   }

/* ------------------------------------------------------------ */

write(fd, bufptr, n)
    int n;
    int fd;
    char *bufptr;
{
    return _write(_iob[fd],bufptr,n);
    }

/* ------------------------------------------------------------ */

fflush(fp)
FILE *fp;
{
    int fseek();
    return fseek(fp, 0L, 1);
}

/* ------------------------------------------------------------ */

flushall() {
   int fd;
   int count = 0;
   int fseek();
   for (fd = 5; fd < MAXFILES; fd++) {
      if (_iob[fd] != NULL) {
         if (fseek(_iob[fd],0L,1) == 0) count++;
         }
      }
   return count;
}

/* ------------------------------------------------------------ */

rewind(fp)
FILE *fp;
{
    clearerr(fp);
    return fseek(fp, 0L, 0);
}

/* ------------------------------------------------------------ */

int chsize(fd, size)
   int fd;
   long size;
{
   extern int errno, _doserrno;
   long lseek();
   long cursize, clear, here;
   int st, writesize;
   int zero[256];
   int handle = _iob[fd]->file.handle;
   if (fd < 0 || fd > MAXFILES) {
      errno = EBADF;
      return -1L;
      }
   here = lseek(fd,0l,1);
   cursize = lseek(fd,0l,2);
   if (cursize > size) {   /* truncate to requested length */
      lseek(fd,size,0);
      if (_sysabcd(0x4000,handle,0,0,&st) != 0) {
         errno = _doserrno;
         return -1;
         }
      }
   else {   /* extend file by filling with zero */
      memset(zero,0,sizeof(zero));
      clear = size-cursize;
      while (clear != 0) {
         writesize = (clear > sizeof(zero)) ? sizeof(zero) : clear;
         if (_sysabcd(0x4000,handle,writesize,zero,&st) != 0) {
            errno = _doserrno;
            return -1;
            }
         if (st != writesize) {
            errno = ENOSPC;
            return -1;
            }
         clear -= writesize;
         }
      }
   lseek(fd,here,0);
   return 0;
   }

/* ------------------------------------------------------------ */

long filelength(fd)
   int fd;
{
   long _fseek();
   long here, len;
   extern int errno;
   if (fd < 0 || fd > MAXFILES) {
      errno = EBADF;
      return -1L;
      }
   here = _fseek(_iob[fd],0L,1);
   if (here == -1L) {
      errno = EBADF;
      return -1L;
      }
   len = _fseek(_iob[fd],0L,2);
   _fseek(_iob[fd],here,0);
   return len;
}

/* ------------------------------------------------------------ */

long lseek(fd, offset, origin)
   int  fd;
   long offset;
   int  origin;
{
   long _fseek();
   return _fseek(_iob[fd],offset,origin);
   }

/* ------------------------------------------------------------ */

clearerr(fp)
FILE *fp;
{
   union REGS r;
   fp->file.error = '\0';
   fp->file.eofflag = '\0';
   r.x.ax = 0x4400;
   r.x.bx = fp->file.handle;
   r.x.dx = 0;
   intdos(&r,&r);
   if (r.x.cflag) return;
   if ((r.x.dx & 0x80) != 0) {
      /* clear eof flag for character device */
      r.h.dh = 0;
      r.h.dl |= 0x40;
      r.x.ax = 0x4401;
      intdos(&r,&r);
      }
}

/* ------------------------------------------------------------ */

ferror(fp)
FILE *fp;
{
    return fp->file.error;
}

/* ------------------------------------------------------------ */

fileno(fp)
FILE *fp;
{
    return fp->fd;
}

/* ------------------------------------------------------------ */

long tell(fd)
   int fd;
{
   extern int errno;
   long ftell();
   if ((fd < 0) || (fd >= MAXFILES) || (_iob[fd] == NULL))
      { errno = EBADF; return -1; }
   return ftell(_iob[fd]);
}

/* ------------------------------------------------------------ */

int fgetpos(fp, pos)
   FILE *fp;
   long *pos;
{
   long ftell(), position;
   position = ftell(fp);
   if (position == -1) return -1;
   *pos = position;
   return 0;
}

/* ------------------------------------------------------------ */

int fsetpos(fp,pos)
   FILE *fp;
   long *pos;
{
    int fseek();
    return fseek(fp, *pos, 0);
}

/* ------------------------------------------------------------ */

int setmode(fd, mode)
   int fd;
   int mode;
{
   FILE *fp;
   int oldmode;
   extern int errno;
   if ((fd < 0) || (fd >= MAXFILES) || (_iob[fd] == NULL))
      { errno = EBADF; return -1; }
   fp = _iob[fd];
   oldmode = fp->file.flags;
   if (mode == O_TEXT) fp->file.flags = oldmode | fdfilter;
   else if (mode == O_BINARY) fp->file.flags = oldmode & (~fdfilter);
   else { errno = EINVAL; return -1; }
   if (oldmode & fdfilter) return O_TEXT; else return O_BINARY;
}

/* ------------------------------------------------------------ */

int getw(fp)
   FILE *fp;
{
   struct twobyte {
      unsigned char lower;
      unsigned char upper;
      };
   union {
      int word;
      struct twobyte bytes;
      } value;
   int c;
   if ((c = fgetc(fp)) == EOF) return EOF;
   value.bytes.lower = c;
   if ((c = fgetc(fp)) == EOF) return EOF;
   value.bytes.upper = c;
   return value.word;
}

/* ------------------------------------------------------------ */

int putw(binint,fp)
   int binint;
   FILE *fp;
{
   struct twobyte {
      unsigned char lower;
      unsigned char upper;
      };
   union {
      int word;
      struct twobyte bytes;
      } value;
   value.word = binint;
   if (fputc(value.bytes.lower,fp) == EOF) return EOF;
   if (fputc(value.bytes.upper,fp) == EOF) return EOF;
   return binint;
}

