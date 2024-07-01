/* Duplicate file handle */
/*   Copyright (c) Mix Software 1988    */

int dup(fd)
   int fd;
{  /* duplicate a file descriptor - both descriptors use the
      same file pointer. */
   extern int errno, _doserrno;
   extern int _dupcnt_;
   int handle;
   if (fd < 0 || fd > MAXFILES || _iob[fd] == NULL) {
      errno = EBADF;
      return -1;
      }
   if (_sys_ab(0x4500,_iob[fd]->file.handle,&handle) != 0) {
      errno = _doserrno;
      return -1;
      }
   if (_iob[handle] != NULL) {
      errno = EMFILE;
      return -1;
      }
   _iob[handle] = _iob[fd];
   _dupcnt_++;
   return handle;
} /* dup */

int dup2(fd1, fd2)
   int fd1, fd2;
{  /* duplicate a file descriptor - both descriptors use the
      same file pointer. */
   extern int errno, _doserrno;
   extern int _dupcnt_;
   int handle;
   if (fd1 < 0 || fd1 > MAXFILES || _iob[fd1] == NULL ||
       fd2 < 0 || fd2 > MAXFILES) {
      errno = EBADF;
      return -1;
      }
   if (_iob[fd2] != NULL) {
      if (close(fd2) != 0) { errno = EBADF; return -1; }
      }
   if (_sysabcd(0x4600,fd1,fd2,0,&handle) != 0) {
      errno = _doserrno;
      return -1;
      }
   _iob[fd2] = _iob[fd1];
   _dupcnt_++;
   return 0;
} /* dup2 */

