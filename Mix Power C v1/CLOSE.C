
/* Close files */
/*   Copyright (c) Mix Software 1988    */

fcloseall() {
   int fd;
   int count = 0;
   for (fd = 5; fd < MAXFILES; fd++) {
      if (_iob[fd] != NULL) {
         if (close(fd) == 0) count++;
         }
      }
   return count;
}

/* ------------------------------------------------------------ */

fclose(fp)
   FILE *fp;
{
   int fd;
   int x;
   extern int _dupcnt_;
   if (fp == NULL) return EOF;
   fd = fp->fd;
   if (_dupcnt_ != 0) {
      for (x = fd+1; x < MAXFILES; x++) {
         if (_iob[x] == fp) fd = x;
         }
      }
   return close(fd);
}

/* ------------------------------------------------------------ */

close(fd)
   int fd;
{
   int _fflush(), _sys_ab(), _sysabcd();
   int status = 0;
   int i;
   FILE *fp;
   extern int (*_fileerr)();
   extern int errno;
   extern int _dupcnt_;
   extern FILE _STDFL1, _STDFL5;
   fp = _iob[fd];
   if (fp == NULL) {
      if (_sys_ab(0x3e00,fd,&status) == 0) return 0;
      errno = EBADF;
      return -1;
      }

   if (fp->file.dirty & fdwrite) status = _fflush(fp);
   if (fp->file.flags & fdctlz) {
       if (fp->file.mode == O_WRONLY) {
         if (status==0) {
           if (_sysabcd(0x4000,fp->file.handle,1,"\032",&status)==0)
             status = 0;
           }
         }
       }
   if (fp->file.device == 0) {
      if (_sys_ab(0x3e00,fd,&status)==0) status = 0;
      }
   if (status) {
      (*_fileerr)(status,fp);
      return -1;
      }

   _iob[fd] = NULL;
   if (_dupcnt_ != 0) {
      for (i = MAXFILES-1; i > 4; i--) {
         if (_iob[i] == fp) {
            fp = NULL;
            i = 0;
            --_dupcnt_;
            }
         }
      }
   if (fp->file.flag2 & fd2temp) _sys_ad(0x4100,fp->file.pathnm,&status);
   if (fp != NULL) {
      if ((fp > &_STDFL1) || (fp < &_STDFL5)) {
         if ((fp->file.flags & fdsetbuf) == 0) free(fp->file.bufr);
         free(fp->file.pathnm);
         free(fp);
         }
      }
   return 0;
}

/* ------------------------------------------------------------ */

_stdclose(fp)
FILE    *fp;
{
   return 0;
}

int     _dupcnt_ = 0;

