#define NOCCARGC  /* no argument count passing */
#include clib.def
extern int Ustatus[];
/*
** Item-stream write to fd.
** Entry: buf = address of source buffer
**         sz = size of items in bytes
**          n = number of items to write
**         fd = file descriptor
** Returns a count of the items actually written or
** zero if an error occurred.
** May use ferror(), as always, to detect errors.
*/
fwrite(buf, sz, n, fd) char *buf; int sz, n, fd; {
  if(write(fd, buf, n*sz) == -1) return (0);
  return (n);
  }

/*
** Binary-stream write to fd.
** Entry:  fd = file descriptor
**        buf = address of source buffer
**          n = number of bytes to write
** Returns a count of the bytes actually written or
** -1 if an error occurred.
** May use ferror(), as always, to detect errors.
*/
write(fd, buf, n) int fd, n; char *buf; {
  return(Uwrite(buf,fd,n));
  }
