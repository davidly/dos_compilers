/*   Copyright (c) Mix Software 1988    */

int allocmem(size, seg)
   unsigned size;       /* size of block requested (in paragraphs) */
   unsigned *seg;       /* segment address of result */
{
   union REGS r;
   r.h.ah = 0x48;
   r.x.bx = size;
   intdos(&r,&r);
   if (r.x.cflag) return r.x.bx;
   *seg = r.x.ax;
   return -1;
   }

int freemem(seg)
   unsigned seg;        /* segment address of previously allocated block */
{
   extern int errno;
   union REGS r;
   struct SREGS sr;
   r.h.ah = 0x49;
   sr.es = seg;
   intdosx(&r,&r,&sr);
   if (r.x.cflag == 0) return 0;
   errno = ENOMEM;
   return -1;
   }

int setblock(seg,newsize)
   unsigned seg;        /* segment address of previously allocated block */
   unsigned newsize;    /* new size (in paragraphs) */
{
   extern int errno;
   extern int _doserrno;
   union REGS r;
   struct SREGS sr;
   r.h.ah = 0x4a;
   r.x.bx = newsize;
   sr.es = seg;
   intdosx(&r,&r,&sr);
   if (r.x.cflag == 0) return -1;
   _doserrno = r.x.ax;
   errno = ENOMEM;
   return r.x.bx;
   }

