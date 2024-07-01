
/* Open/Create files */
/*   Copyright (c) Mix Software 1988    */

/* ------------------------------------------------------------ */

FILE *fdopen(fd, type)
int  fd;
char *type;
{
   FILE *fp;
   int  c;
   int  mode;
   if (fd < 0 || fd > MAXFILES) return NULL;
   fp = _iob[fd];
   if (fp == NULL) return NULL;
   c = *type;
   if (c == 'r') mode = O_RDONLY; else mode = O_WRONLY;
   if (*++type == '+') mode = O_RDWR;
   if (c == 'a') {
      if ((fp->file.flags & fdappend) == 0) return NULL;
      }
   if (fp->file.mode == mode) return fp;
   return NULL;
}

/* ------------------------------------------------------------ */

FILE *freopen(filename, type, old_fp)
char *filename, *type;
FILE *old_fp;
{
   FILE *new_fp;
   int old_fd, new_fd;
   FILE *fopen();
   old_fd = fileno(old_fp);
   if (fclose(old_fp)) return NULL;
   if ((new_fp = fopen(filename, type)) == NULL) return NULL;
   new_fd = fileno(new_fp);
   if (new_fd != old_fd) { /* keep same file number */
      _iob[new_fd] = _iob[old_fd];
      _iob[old_fd] = new_fp;
      new_fp->fd = old_fd;
      if (_iob[new_fd] != NULL) _iob[new_fd]->fd = new_fd;
      }
}

/* ------------------------------------------------------------ */

FILE *fopen(name,modes)
char *name, *modes;
{
   char ch;
   int  fd, mode, rw;
   ch = tolower(*modes);
   mode = 0;
   if (ch == 'r') rw = O_RDONLY;
   else if (ch == 'w') {rw = O_WRONLY; mode = O_CREAT|O_TRUNC;}
   else if (ch == 'a') {rw = O_RDWR; mode = O_CREAT|O_APPEND;}
   else return NULL;
   if (*++modes == '+') {
      rw = O_RDWR;
      ++modes;
      }
   ch = tolower(*modes);
   if (ch == 'b') mode |= O_BINARY;
   else if (ch == 't') mode |= O_TEXT;
   fd = _open(name,mode|rw,S_IREAD|S_IWRITE);
   if (fd < 0) return NULL;
   return _iob[fd];
}

/* ------------------------------------------------------------ */

creat(name, pmode)
char *name;
int pmode;
{
    return _open(name,O_CREAT|O_WRONLY|O_TRUNC,pmode);
    }

/* ------------------------------------------------------------ */

creatnew(name, attrib)
char *name;
int attrib;
{
   int fd, status;
   fd = _open(name,O_CREAT|O_RDWR|O_TRUNC|O_EXCL|O_BINARY,S_IREAD|S_IWRITE);
   if (fd != -1) _sys_acd(0x4300,attrib,name,&status);
   return fd;
   }

/* ------------------------------------------------------------ */

_creat(name, attrib)
char *name;
int attrib;
{
   int fd, status;
   fd = _open(name,O_CREAT|O_RDWR|O_TRUNC|O_BINARY,S_IREAD|S_IWRITE);
   if (fd != -1) _sys_acd(0x4300,attrib,name,&status);
   return fd;
   }

/* ------------------------------------------------------------ */

sopen(name, oflag, shflag, pmode)
   char *name;
   int oflag;
   int shflag;
   int pmode;
{
   return _open(name,oflag|shflag,pmode);
}

/* ------------------------------------------------------------ */

open(name, mode, pmode)
   char *name;
   int mode;
   int pmode;
{
   return _open(name,mode,pmode);
}

/* ------------------------------------------------------------ */

_open(name, mode, pmode)
char *name;
int  mode;
int  pmode;
{
   int fd;
   FILE *fp;
   extern int $$BUFSIZ;
   extern char $$CCTLZ;
   extern int errno, _doserrno;
   extern char _fmode;
   extern int _umask_;
   extern int (*_fileerr)();
   extern int (*_fclose)();
   int fclose();
   int handle;
   int flmode;
   int crmode;
   int chmode = 0;
   _fclose = fclose;
   flmode = mode & O_MODEMASK;
   crmode = pmode & (~_umask_);
   crmode = ((crmode & S_IWRITE) == 0) ? 1 : 0;
   if (mode & O_TRUNC) {
      if ((mode & O_CREAT) == 0) {
         if (_sys_ad(0x3d00,name,&handle) != 0) goto doserror;
         _sys_ab(0x3e00,handle,&handle);
         }
      else {
         if (mode & O_EXCL) {
            if (_sys_ad(0x3d00,name,&handle) == 0) {
               _sys_ab(0x3e00,handle,&handle);
               errno = EEXIST;
               return -1;
               }
            }
         } /* create */
      if (_sys_acd(0x3c00,0,name,&handle) != 0) goto doserror;
      chmode = crmode;
      if (flmode != O_RDWR) {
         _sys_ab(0x3e00,handle,&handle);
         if (_sys_ad(0x3d00+flmode,name,&handle) != 0) goto doserror;
         }
      } /* trunc */
   else {
      if (_sys_ad(0x3d00+flmode,name,&handle) != 0) { /* not found */
         if (mode & O_CREAT) {
            if (_sys_acd(0x3c00,0,name,&handle) != 0) goto doserror;
            chmode = crmode;
            if (flmode != O_RDWR) {
               _sys_ab(0x3e00,handle,&handle);
               if (_sys_ad(0x3d00+flmode,name,&handle) != 0)
                  goto doserror;
               }
            } /* create */
         else goto doserror;
         } /* file does not exist */
      else {
         if (mode & O_CREAT) {
            if (mode & O_EXCL) {
               _sys_ab(0x3e00,handle,&handle);
               errno = EEXIST;
               return -1;
               }
            }
         } /* file exists */
      } /* not trunc */

   /* file is open and file handle is set */
   if (chmode != 0) {
      _sys_acd(0x4301,chmode,name,&chmode);
      }
   fp = malloc(sizeof(FILE));
   fd = handle;
   if (fd >= MAXFILES || _iob[fd] != NULL || fp == NULL) {
      _sys_ab(0x3e00,handle,&handle);
      errno = EMFILE;
      return -1;
      }
   _iob[fd] = fp;
   setmem(fp,sizeof(FILE),0);
   fp->fd = fd;
   fp->file.pathnm = strsave(name);
   fp->file.handle = fd;
   fp->file.init = 'C';
   fp->file.openflg = 1;
   fp->file.mode = flmode & 0x0003;
   if (mode & O_BINARY) fp->file.flags = fdbinary;
   else if (mode & O_TEXT) fp->file.flags = fdfilter;
   else {
      if (_fmode == 'b') fp->file.flags = fdbinary;
      else fp->file.flags = fdfilter;
      }
   if (fp->file.flags == fdfilter) {
      if ($$CCTLZ) fp->file.flags |= fdctlz;
      }
   if ($$BUFSIZ == 0) fp->file.flags |= fdunbufr;
   else {
      fp->file.ptr = fp->file.bufr = malloc($$BUFSIZ);
      if (fp->file.ptr == NULL) fp->file.flags |= fdunbufr;
      else fp->file.bufsize = $$BUFSIZ;
      }
   if (mode & O_APPEND) fp->file.flags |= fdappend;
   return fd;

doserror:
   errno = _doserrno;
   return -1;

}  /* _open */

char _fmode = 't';

/* ------------------------------------------------------------ */

int umask(pmode)
   int pmode;
{
   extern int _umask_;
   int old;
   old = _umask_;
   _umask_ = pmode;
   return old;
}

int _umask_ = 0;
