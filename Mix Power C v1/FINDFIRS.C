/* Directory searching functions */
/*   Copyright (c) Mix Software 1988    */

struct ffblk {
   char ff_reserved[21];   /* used by dos */
   char ff_attrib;         /* attributes of the file */
   int  ff_ftime;          /* time file last modified */
   int  ff_fdate;          /* date file last modified */
   long ff_fsize;          /* size of file */
   char ff_name[13];       /* name of file (xxxxxxxx.yyy) */
   };

int findfirst(pathname, ffblk, attrib)
   char *pathname;
   struct ffblk *ffblk;
   int attrib;
{
   extern int errno;
   extern int _doserrno;
   int stat;
   _sys_ad(0x1a00,ffblk,&stat);  /* set dma address */
   if (_sys_acd(0x4e00,attrib,pathname,&stat) == 0) return 0;
   errno = _doserrno;
   return -1;
   }

int findnext(ffblk)
   struct ffblk *ffblk;
{
   extern int errno;
   extern int _doserrno;
   int stat;
   _sys_ad(0x1a00,ffblk,&stat);  /* set dma address */
   if (_sys_ad(0x4f00,0,&stat) == 0) return 0;
   errno = _doserrno;
   return -1;
   }

