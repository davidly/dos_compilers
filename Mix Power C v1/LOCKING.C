/* Record locking */
/*   Copyright (c) Mix Software 1988    */

#include "locking.h"

int locking(fd, mode, nbyte)
   int fd;
   int mode;
   long nbyte;
{
   struct intlong {
      unsigned int lower;
      unsigned int upper;
      };
   union {
      long l;
      struct intlong words;
      } v;
   union REGS lock;
   union REGS time;
   union REGS answer;
   extern int errno;
   int status;
   int trycount, sec;
   lock.x.ax = 0x5c00;
   lock.x.bx = fd;
   v.l = nbyte;
   lock.x.si = v.words.upper;
   lock.x.di = v.words.lower;
   v.l = lseek(fd,0L,1);
   lock.x.cx = v.words.upper;
   lock.x.dx = v.words.lower;
   if (mode == LK_UNLCK) lock.h.al = 0x01;
   trycount = (mode == LK_LOCK || mode == LK_RLCK) ? 10 : 1;
   do {
      status = intdos(&lock,&answer);
      if (answer.x.cflag == 0) return 0;
      if (status != 0x21) { errno = status; return -1; }
      if (--trycount) {
         time.h.ah = 0x2c;
         intdos(&time,&answer);
         sec = answer.h.dh;
         do {
            intdos(&time,&answer);
            } while (sec == answer.h.dh);
         }
      } while (trycount);
   errno = (mode == LK_LOCK || mode == LK_RLCK) ? EDEADLOCK : EACCES;
   return -1;
} /* locking */

int lock(fd, offset, length)
   int fd;
   long offset;
   long length;
{
   union {
      long l;
      struct {
         unsigned int lower;
         unsigned int upper;
         } words;
      } v;
   union REGS lockfl, time, answer;
   extern int errno;
   int status;
   int trycount = 4;
   int sec;
   lockfl.x.ax = 0x5c00;
   lockfl.x.bx = fd;
   v.l = length;
   lockfl.x.si = v.words.upper;
   lockfl.x.di = v.words.lower;
   v.l = offset;
   lockfl.x.cx = v.words.upper;
   lockfl.x.dx = v.words.lower;
   while (--trycount) {
      status = intdos(&lockfl,&answer);
      if (answer.x.cflag == 0) return 0;
      if (status != 0x21) { errno = status; return -1; }
      time.h.ah = 0x2c;
      intdos(&time,&answer);
      sec = answer.h.dh;
      do {
         intdos(&time,&answer);
         } while (sec == answer.h.dh);
      }
   return -1;
} /* lock */

int unlock(fd, offset, length)
   int fd;
   long offset;
   long length;
{
   union {
      long l;
      struct {
         unsigned int lower;
         unsigned int upper;
         } words;
      } v;
   union REGS lockfl, answer;
   extern int errno;
   int status;
   lockfl.x.ax = 0x5c01;
   lockfl.x.bx = fd;
   v.l = length;
   lockfl.x.si = v.words.upper;
   lockfl.x.di = v.words.lower;
   v.l = offset;
   lockfl.x.cx = v.words.upper;
   lockfl.x.dx = v.words.lower;
   status = intdos(&lockfl,&answer);
   if (answer.x.cflag == 0) return 0;
   errno = status;
   return -1;
} /* unlock */
