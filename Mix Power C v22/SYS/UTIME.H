/*$no list*//*$no trace <<< utime.h >>> */
/*   Copyright (c) Mix Software 1988   */

#define time_t long

#if !Defined(struct utimbuf)
struct utimbuf {
    time_t actime;    /* access time       */
    time_t modtime;   /* modification time */
};
#endif

int utime(char *filename, struct utimbuf *times);

/*$list*//*$trace       <<< utime.h >>> */
