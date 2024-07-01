/* File status functions */
/*   Copyright (c) Mix Software 1988    */

int fstat(fd, buffer)
   int fd;
   struct statstr *buffer;
{
   union REGS r;
   extern errno;
   int stat();
   if ((fd < 0) || (fd >= MAXFILES) || (_iob[fd] ==  NULL))
      { errno = EBADF; return -1; }
   r.x.ax = 0x4400;
   r.x.bx = fd;
   r.x.cx = 0;
   r.x.dx = 0;
   intdos(&r,&r);
   if (r.x.cflag != 0) {errno = EBADF; return -1;}
   if (r.x.ax & 0x80) { /* character device */
      buffer->st_mode = S_IFCHR;
      buffer->st_nlink = 1;
      buffer->st_dev = fd;
      buffer->st_rdev = fd;
      return 0;
      }
   if (stat(_iob[fd]->file.pathnm,buffer) == -1) return -1;
   buffer->st_size = filelength(fd);
   return 0;
}

int stat(pathname, buffer)
   char *pathname;
   struct statstr *buffer;
{
   struct statstru {
      char res[21];
      char attr;
      unsigned time;
      unsigned date;
      long size;
      char name[13];
      } statbufr;
   int status;
   unsigned flag;
   char *p;
   long time;
   extern int errno, _doserrno;
   extern int daylight;
   long _timesec();
   _sys_ad(0x1a00,&statbufr,&status);
   if (_sys_acd(0x4e00,0x0016,pathname,&status) != 0)
      { errno = _doserrno; return -1; }
   buffer->st_size = statbufr.size;
   if ((p = strchr(pathname,':')) != NULL)
      buffer->st_dev = tolower(*--p) - 'a';
   else buffer->st_dev = _sys_al(0x1900);
   buffer->st_rdev = buffer->st_dev;
   time = _timesec(((statbufr.date >> 9) & 0x7f) + 1980,
         (statbufr.date >> 5) & 0x0f, statbufr.date & 0x1f,
         (statbufr.time >> 11) & 0x1f, (statbufr.time >> 5) & 0x3f,
         statbufr.time & 0x1f);
   if (daylight) time += 3600l;
   buffer->st_atime = time;
   buffer->st_mtime = time;
   buffer->st_ctime = time;
   _sysacdc(0x4300,0,pathname,&status);
   if (status & 0x0010) flag = S_IFDIR; else flag = S_IFREG;
   flag |= S_IREAD;
   if ((status & 0x0001) == 0) flag |= S_IWRITE;
   if ((stristr(pathname,".EXE") != NULL) ||
      (stristr(pathname,".COM") != NULL)) flag |= S_IEXEC;
   flag |= 0x36;
   buffer->st_mode = flag;
   buffer->st_ino = 0;
   buffer->st_uid = 0;
   buffer->st_gid = 0;
   buffer->st_nlink = 1;
   return 0;
}

