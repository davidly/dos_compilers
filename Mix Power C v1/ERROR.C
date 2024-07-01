/*  Low level error processing functions. */
/*   Copyright (c) Mix Software 1988    */

extern  int _ferror0();
int     (*_fileerr)() = _ferror0;   /* set to _ferror1 for full error msg */

int _ferror0(syserror,fp)     /* error detected during file operation */
   int syserror;              /* set error codes and terminate or     */
   FILE *fp;                  /* continue (depending on $$IOTERM)     */
{
   extern char $$IOTERM;
   extern FILE *$$LIOERR;
   extern int errno;
   void $_FATAL();
   if (syserror) {
      fp->file.error = syserror;
      errno = FILEERR;
      $$LIOERR = fp;
      if ($$IOTERM) $_FATAL(errno);
      }
   return syserror;
   }

int _ferror1(syserror,fp)     /* error detected during file operation */
   int syserror;              /* set error codes and terminate with   */
   FILE *fp;                  /* full message.                        */
{
   extern int errno;
   extern char $$IOTERM;
   extern FILE *$$LIOERR;
   extern char *sys_errlist[];
   extern int sys_nerr;
   void _exit();
   if (syserror) {
      fp->file.error = syserror;
      errno = FILEERR;
      $$LIOERR = fp;
      if ($$IOTERM) {
         _errmsg("File IO error\r\l");
         if (syserror <= sys_nerr) _errmsg(sys_errlist[syserror]);
         _exit(errno);
         }
      }
   return syserror;
   }

_errmsg(s)
   char *s;
{
   int ss;
    _sysabcd(0x4000,2,strlen(s),s,&ss);
   }

