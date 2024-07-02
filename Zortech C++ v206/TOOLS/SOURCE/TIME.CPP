#include <time.hpp>

typedef void (* PFC)(int, char*);
extern void default_error(int,char*);
static PFC time_handler = default_error;

char *wdays[] = {
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
};

char *months[] = {
    "January",
    "Febuary",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
};

time_info::time_info()
{
    dbuf = new char[28];
    if (!dbuf)
        goto allerr1;
    tbuf = new char[9];
    if (!tbuf) {
allerr1:
        time_handler(ENOMEM,"timeinfo - not enough memory");
        return;
    }
    now();
}

time_info::time_info(time_info& other)
{
    dbuf = new char[28];
    if (!dbuf)
        goto allerr2;
    tbuf = new char[9];
    if (!tbuf) {
allerr2:
        time_handler(ENOMEM,"timeinfo - not enough memory");
        return;
    }
    ts = other.ts;
    last = other.last;
    memmove(dbuf,other.dbuf,28);
    memmove(tbuf,other.tbuf,9);
}

time_info::time_info(int h, int m, int s)
{
    dbuf = new char[28];
    if (!dbuf)
        goto allerr3;
    tbuf = new char[9];
    if (!tbuf) {
allerr3:
        time_handler(ENOMEM,"timeinfo - not enough memory");
        return;
    }
    now();
    ts.tm_sec = s;
    ts.tm_min = m;
    ts.tm_hour = h;
}

time_info::time_info(char *ds, int h, int m, int s)
{
    char any;
    dbuf = new char[28];
    if (!dbuf)
        goto allerr4;
    tbuf = new char[9];
    if (!tbuf) {
allerr4:
        time_handler(ENOMEM,"timeinfo - not enough memory");
        return;
    }
    if (_usdate)
        sscanf(ds,"%d%c%d%c%d",&ts.tm_mon,&any,&ts.tm_mday,&any,&ts.tm_year);
    else 
        sscanf(ds,"%d%c%d%c%d",&ts.tm_mday,&any,&ts.tm_mon,&any,&ts.tm_year);
    --ts.tm_mon;
    ts.tm_sec = s;
    ts.tm_min = m;
    ts.tm_hour = h;
    last = mktime(&ts);
    ts = *localtime(&last);
}

char *time_info::tod(int show_secs) {
    sprintf(tbuf,show_secs? "%02d:%02d:%02d": "%02d:%02d",
                                ts.tm_hour,ts.tm_min,ts.tm_sec);
    return tbuf;
}

char *time_info::wday() { return wdays[ts.tm_wday]; }

char *time_info::dldate() {
    sprintf(dbuf,"%s %d %s %d",
                wday(),ts.tm_mday, months[ts.tm_mon],ts.tm_year+1900);
    return dbuf;
}

char *time_info::ldate() {
    sprintf(dbuf,"%s %d %d",months[ts.tm_mon],ts.tm_mday,ts.tm_year+1900);
    return dbuf;
}

char *time_info::date() {
    if (_usdate)
        sprintf(dbuf,"%2d/%02d/%02d",ts.tm_mon+1,ts.tm_mday,ts.tm_year);
    else
        sprintf(dbuf,"%2d/%02d/%02d",ts.tm_mday,ts.tm_mon+1,ts.tm_year);
    return dbuf;
}

time_t time_info::set(int y, int m, int d, int h, int mt, int s)
{
    if (y > -1) ts.tm_year = y;
    if (m > -1) ts.tm_mon = m-1;
    if (d > -1) ts.tm_mday = d;
    if (h > -1) ts.tm_hour = h;
    if (mt > -1) ts.tm_min = mt;
    if (s > -1) ts.tm_sec = s;
    last = mktime(&ts);
    ts = *localtime(&last);  // update other fields
    return last;
}

unsigned time_info::operator+=(unsigned days)
{
    last += SECSPERDAY*days;
    ts = *localtime(&last);
    return dayno();
}

unsigned time_info::operator-=(unsigned days)
{
    last -= SECSPERDAY*days;
    ts = *localtime(&last);
    return dayno();
}

time_info& time_info::operator=(time_info& other)
{
    ts = other.ts;
    last = other.last;
    memmove(dbuf,other.dbuf,28);
    memmove(tbuf,other.tbuf,9);
}

PFC set_time_handler(PFC handler)
{
    PFC loc = time_handler;
    time_handler = handler;
    return loc;
}

