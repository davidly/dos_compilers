/*$no list*//*$no trace <<< timeb.h >>> */
/*   Copyright (c) Mix Software 1988    */

#define time_t long

#if !Defined(struct timeb)
struct timeb {
    time_t         time;
    unsigned short millitm;
    short          timezone;
    short          dstflag;
};
#endif

void ftime(struct timeb *timeptr);

/*$list*//*$trace       <<< timeb.h >>> */
