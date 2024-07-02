/*$no list*//*$no trace <<< io.h >>> */
/*  Copyright (c) Mix Software 1988  */

#define ISCTRL  0x4000
#define ISDEV   0x0080
#define ISNEOF  0x0040
#define ISBIN   0x0020
#define ISCLK   0x0008
#define ISNUL   0x0004
#define ISCOT   0x0002
#define ISCIN   0x0001

#define O_RDONLY    0x0000
#define O_WRONLY    0x0001
#define O_RDWR      0x0002
#define O_APPEND    0x0008
#define O_CREAT     0x0100
#define O_TRUNC     0x0200
#define O_EXCL      0x0400
#define O_TEXT      0x4000
#define O_BINARY    0x8000

#define O_DENYALL   0x0010
#define O_DENYNONE  0x0040
#define O_DENYREAD  0x0030
#define O_DENYWRITE 0x0020
#define O_NOINHERIT 0x0080

#define S_IREAD 0x0100
#define S_IWRITE 0x0080

int     access(char *filename, int mode);
int     chmod(char *filename, int permission);
int     chsize(int fd, long size);
int     close(int fd);
int     creat(char *filename, int mode);
int     dup(int fd);
int     dup2(int fd1, int fd2);
int     eof(int fd);
long    filelength(int fd);
int     getftime(int fd, struct ftime *date);
int     ioctl(int fd, int operation, ... /* void *dx, int cx */);
int     locking(int fd, int mode, long size);
long    lseek(int fd, long offset, int origin);
char   *mktemp(char *template);
int     open(char *filename, int access, ... /* int mode */);
int     read(int fd, char *buffer, unsigned number);
int     remove(char *filename);
int     rename(char *oldname, char *newname);
int     setftime(int fd, struct ftime *date);
int     setmode(int fd, int mode);
int     sopen(char *filename, int access, int shared, ... /* int mode */);
long    tell(int fd);
int     umask(int mode);
int     unlink(char *filename);
int     write(int fd, char *buffer, int number);

/*$list*//*$trace       <<< io.h >>> */
