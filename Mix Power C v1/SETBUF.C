
/* File buffer functions */
/*   Copyright (c) Mix Software 1988    */

setbufsiz(size)
int size;
{
    extern int $$BUFSIZ;
    int oldsize = $$BUFSIZ;
    $$BUFSIZ = size;
    return oldsize;
}

/* ------------------------------------------------------------ */

setbuf(fp, bufptr)
FILE *fp;
char *bufptr;
{
   extern int (*_fclose)();
   int fclose();
   if (fp) {
      _fclose = fclose;
      fflush(fp);
      if ((fp->file.flags & fdsetbuf) == 0) free(fp->file.bufr);
      if (bufptr == 0) {
         fp->file.flags |= fdunbufr;
         fp->file.bufr = NULL;
         fp->file.ptr = NULL;
         fp->file.count = 0;
         return;
         }
      fp->file.bufr = fp->file.ptr = bufptr;
      fp->file.count = 0;
      fp->file.flags &= ~fdunbufr;
      fp->file.flags |= fdsetbuf;
      }
}

/* ------------------------------------------------------------ */

setvbuf(fp, buf, type, size)
   FILE *fp;
   char *buf;
   int type;
   int size;
{
   extern int (*_fclose)();
   int fclose();
   if (fp) {
      _fclose = fclose;
      if (type != _IONBF && type != _IOFBF && type != _IOLBF) return -1;
      if (size < 0) return -1;
      fflush(fp);
      if ((fp->file.flags & fdsetbuf) == 0) free(fp->file.bufr);
      if (type == _IONBF) {
         fp->file.flags |= fdunbufr;
         fp->file.bufr = NULL;
         fp->file.ptr = NULL;
         fp->file.count = 0;
         return 0;
         }
      if (buf == NULL) buf = malloc(size);
      if (buf == NULL) return -1;
      fp->file.bufr = fp->file.ptr = buf;
      fp->file.count = 0;
      fp->file.bufsize = size;
      fp->file.flags &= ~fdunbufr;
      fp->file.flags |= fdsetbuf;
      return 0;
      }
   else return -1;
}

