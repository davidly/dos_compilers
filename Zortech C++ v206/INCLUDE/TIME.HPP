#ifndef TIMEHPP
#define TIMEHPP
#include <time.h>
#include <stdio.h>
#include <string.h>
#include "errn.hpp"

#define SECSPERDAY (60L*60*24)
extern char *wdays[];
extern char *months[];
extern int _usdate, _allocerr;

class time_info {
    struct tm ts;
    time_t last;
    char *dbuf;
    char *tbuf;
public:
    time_t now(void) {
        time(&last);
        ts = *localtime(&last);
        return last;
    }
    time_info(void);                // set all from system
    time_info(time_info&);          // copy constructor
    time_info(int, int, int = 0);   // set time - date from system
    time_info(char *, int=0, int=0, int=0);
                                    // set all from arguments
    int sec(void) { return ts.tm_sec; }
    int min(void) { return ts.tm_min; }
    int hour(void) {return ts.tm_hour; }
    int day(void) { return ts.tm_mday; }
    int mon(void) { return ts.tm_mon; }
    int year(void) { return ts.tm_year; }
    int yday(void) { return ts.tm_yday; }
    int dayw(void) { return ts.tm_wday; }
    unsigned dayno(void) { return last/SECSPERDAY; }
    char *tod(int = 0);
    char *wday(void);
    char *dldate(void);
    char *ldate(void);
    char *date(void);
    time_t set(int, int , int , int = 0, int = 0, int = 0);
    unsigned operator+=(unsigned);
    unsigned operator-=(unsigned);
    time_info& operator=(time_info&);
    ~time_info(void) { delete dbuf; delete tbuf; }
};
#endif

