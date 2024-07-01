/*   Copyright (c) Mix Software 1988    */

int _chmod(filename, func, attrib)
   char *filename;
   int func;
   int attrib;
{
   extern int errno, _doserrno;
   int status;
   if (_sysacdc(0x4300+(func & 0x0001),attrib,filename,&status) == 0)
      return status;
   errno = _doserrno;
   return -1;
   }

int getcbrk()
{
   int dxval;
   _sys_add(0x3300,0,&dxval);
   return dxval & 0x00ff;
   }

int setcbrk(value)
   int value;
{
   int dxval;
   _sys_add(0x3301,value,&dxval);
   return value;
   }

getcurdir(drive, direc)       /* get default directory */
   int drive;     /* drive (0=default, 1=a, 2=b, etc) */
   char *direc;   /* buffer for result */
{
   int status;
   if (_sysdxsi(0x4700,drive,direc,&status) == 0) return 0;
   return -1;
   }

void getdfree(drive, dfreep)
   int drive;
   struct dfree *dfreep;
{
   union REGS r;
   r.h.ah = 0x36;
   r.x.dx = drive;
   intdos(&r,&r);
   dfreep->df_avail = r.x.bx;
   dfreep->df_total = r.x.dx;
   dfreep->df_bsec = r.x.cx;
   dfreep->df_sclus = r.x.ax;
   }

int getdisk()
{
   return _sys_al(0x1900);
   }

int setdisk(drive)
   int drive;
{
   int result;
   _sys_ad(0x0e00,drive,&result);
   return result & 0x00ff;
   }

int getftime(handle, ftimep)
   int handle;
   struct ftime *ftimep;
{
   extern int errno;
   struct {
      int time;
      int date;
      } *cvt;
   union REGS r;
   r.x.ax = 0x5700;
   r.x.bx = handle;
   intdos(&r,&r);
   if (r.x.cflag != 0) {
      errno = r.x.ax;
      return -1;
      }
   cvt = ftimep;
   cvt->time = r.x.cx;
   cvt->date = r.x.dx;
   return 0;
   }

int setftime(handle, ftimep)
   int handle;
   struct ftime *ftimep;
{
   extern int errno;
   struct {
      int time;
      int date;
      } *cvt;
   union REGS r;
   r.x.ax = 0x5701;
   r.x.bx = handle;
   cvt = ftimep;
   r.x.cx = cvt->time;
   r.x.dx = cvt->date;
   intdos(&r,&r);
   if (r.x.cflag != 0) {
      errno = r.x.ax;
      return -1;
      }
   return 0;
   }

unsigned getpsp()
{
   union REGS r;
   r.x.ax = 0x6200;
   intdos(&r,&r);
   return r.x.bx;
   }

int getverify()
{
   return _sys_al(0x5400);
   }

void setverify(value)
   int value;
{
   _sys_ad(0x2e00+(value & 0x0001),0);
   }

int ioctl(handle,cmd,argdx,argcx)
   int handle;
   int cmd;
   int *argdx;
   int argcx;
{
   extern int errno, _doserrno;
   union REGS r;
   r.h.ah = 0x44;
   r.h.al = cmd;
   r.x.bx = handle;
   r.x.cx = argcx;
   r.x.dx = *argdx;
   if (cmd == 1) r.h.dh = 0;
   intdos(&r,&r);
   if (r.x.cflag) { errno = _doserrno; return -1; }
   if (cmd < 2) return r.x.dx;
   return r.x.ax;
   }

void keep(status,size)   /* terminate and stay resident */
   int status;  /* status code to return to caller */
   int size;    /* total size of memory to retain (in paragraphs) */
{
   int st;
   _sys_ad(0x3100+(status & 0x00ff),size,&st);
   }

struct  fcb     {
   char fcb_drive;      /* drive number */
   char fcb_name[8];    /* file name */
   char fcb_ext[3];     /* file extension */
   int fcb_curblk;      /* block number */
   int fcb_recsize;     /* logical record size */
   long fcb_filsize;    /* file size */
   int fcb_date;        /* Date file was last written */
   char fcb_resv[10];   /* Reserved for DOS */
   char fcb_currec;     /* record in block */
   long fcb_random;     /* random record number */
   };
char *parsfnm(cmdline, fcbptr, option)
   char *cmdline;
   struct fcb *fcbptr;
   int option;
{
   union REGS r;
   struct SREGS s;
   void segread();
   r.h.ah = 0x29;
   r.h.al = option;
   r.x.si = cmdline;
   r.x.di = fcbptr;
   segread(&s);
   s.es = s.ds;
   intdosx(&r,&r,&s);
   if (r.h.al != 0) return 0;
   return r.x.si;
   }

int randbrd(fcbptr, reccnt)
   struct fcb *fcbptr;
   int reccnt;
{     /* random block read */
   int status;
   _sys_acd(0x2700,reccnt,fcbptr,&status);
   return status&0xff;
   }

int randbwr(fcbptr, reccnt)
   struct fcb *fcbptr;
   int reccnt;
{     /* random block read */
   int status;
   _sys_acd(0x2800,reccnt,fcbptr,&status);
   return status&0xff;
   }

struct country {
   int co_date;      /* date format 0=mdy, 1=dmy, 2=ymd */
   char co_curr[5];  /* currency symbol */
   char co_thsep[2]; /* thousands separator character */
   char co_desep[2]; /* decimal separator character */
   char co_dtsep[2]; /* date separator character */
   char co_tmsep[2]; /* time separator character */
   char co_curstyle; /* currency format */
   char co_digits;   /* number of significant digits in currency */
   char co_timestyle; /* time format, 0=12 hour, 1=24 hour clock */
   int (far *co_case)();   /* case conversion function */
   char co_fill[10];  /* fill to 34 bytes */
   }

struct country *country(countrycode, countryp)
   int countrycode;
   struct country *countryp;
{
   int opcode = 0x3800;
   int bx = 0;
   if (countrycode > 254) {
      opcode = 0x38ff;
      bx = countrycode;
      }
   else opcode |= countrycode;
   _sysabcd(opcode,bx,0,countryp,&bx);
   return countryp;
   }

