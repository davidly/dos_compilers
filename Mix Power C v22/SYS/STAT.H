/*$no list*//*$no trace <<< stat.h >>> */
/*   Copyright (c) Mix Software 1988   */

#define dev_t   short
#define ino_t   unsigned short
#define off_t   long
#define time_t  long

#define S_IFMT  0xf000      /* type mask */
#define S_IFDIR 0x4000
#define S_IFCHR 0x2000
#define S_IFREG 0x8000
#define S_IREAD 0x0100
#define S_IWRITE 0x0080
#define S_IEXEC 0x0040

#if !Defined(struct stat)
struct stat
{
    dev_t          st_dev;
    ino_t          st_ino;
    unsigned short st_mode;
    short          st_nlink;
    short          st_uid;
    short          st_gid;
    dev_t          st_rdev;
    off_t          st_size;
    time_t         st_atime;
    time_t         st_mtime;
    time_t         st_ctime;
};
#endif

int fstat(int fd, struct stat *buffer);
int stat(char *pathname, struct stat *buffer);

/*$list*//*$trace       <<< stat.h >>> */
