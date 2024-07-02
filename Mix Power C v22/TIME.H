/*$no list*//*$no trace <<< time.h >>> */
/*   Copyright (c) Mix Software 1988   */

#define CLK_TCK 100
#define time_t  long
#define clock_t long
#if !defined(NULL)
   #define     NULL        ((void *)0)
#endif

#if !Defined(size_t)
typedef unsigned size_t;
#endif

#if !Defined(struct tm)
struct tm {
    int tm_sec;
    int tm_min;
    int tm_hour;
    int tm_mday;
    int tm_mon;
    int tm_year;
    int tm_wday;
    int tm_yday;
    int tm_isdst;
};
#endif

char      *asctime(struct tm *timeptr);
clock_t    clock(void);
char      *ctime(time_t *timer);
double     difftime(time_t time2, time_t time1);
struct tm *gmtime(time_t *timer);
struct tm *localtime(time_t *timer);
time_t     mktime(struct tm *timeptr);
size_t     strftime(char *buffer, size_t bufsize, char *format,
                    struct tm *timeptr);
time_t     time(time_t *timer);

#if !defined(ANSI)
extern int   daylight;  /* non-zero if daylight savings time is used */
extern long  timezone;  /* difference in seconds between GMT and local time */
extern char *tzname[2]; /* standard/daylight savings time zone names */

#if !Defined(struct timeb)
struct timeb {
    time_t         time;
    unsigned short millitm;
    short          timezone;
    short          dstflag;
};
#endif

#if !Defined(struct date)
struct date {
    int da_year;
    char da_day;
    char da_mon;
};
#endif

#if !Defined(struct time)
struct time {
    unsigned char ti_min;
    unsigned char ti_hour;
    unsigned char ti_hund;
    unsigned char ti_sec;
};
#endif

void ftime(struct timeb *timeptr);
void getdate(struct date *datebuf);
void gettime(struct time *timebuf);
void setdate(struct date *datebuf);
void settime(struct time *timebuf);
int  stime(time_t *timer);
void tzset(void);
#endif /* ANSI */

/*$list*//*$trace       <<< time.h >>> */
