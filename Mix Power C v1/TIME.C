/* Time and date functions */
/*   Copyright (c) Mix Software 1988    */

char *ctime(time)
long time;
{
   char *asctime();
   struct tm *localtime();
   return asctime(localtime(time));
} /* ctime */

size_t strftime(s, maxsize, format, timeptr)
   char *s;              /* buffer for result */
   size_t maxsize;       /* maximum size of s */
   char *format;         /* format string */
   struct tm *timeptr;   /* time to convert */
{  /* formatted time */
   static char *shortday[7] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
   static char *longday[7] = {"Sunday","Monday","Tuesday","Wednesday",
                              "Thursday","Friday","Saturday"};
   static char *shortmonth[12] = {"Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"};
   static char *longmonth[12] = {"January","February","March","April",
                          "May","June","July","August","September",
                          "October","November","December"};
   static char *am_pm[2] = {"AM","PM"};
   static int _strput(int, char *, int);
   char *asctime();
   extern char *tzname[2];
   #define put(ch) {if (--length) *s++ = ch; else return 0;}
   char ch, *p;
   char str[20];
   int length = maxsize;
   int value;
   while (*format != '\0') {
      if (*format != '%') put(*format++)
      else {
         p = str;
         memset(p,0,sizeof(str));
         switch (*++format) {
            case 'a' :
               p = shortday[timeptr->tm_wday];
               break;
            case 'A' :
               p = longday[timeptr->tm_wday];
               break;
            case 'b' :
               p = shortmonth[timeptr->tm_mon];
               break;
            case 'B' :
               p = longmonth[timeptr->tm_mon];
               break;
            case 'c' :
               p = asctime(timeptr);
               break;
            case 'd' :
               _asct2dig(timeptr->tm_mday,p);
               break;
            case 'H' :
               _asct2dig(timeptr->tm_hour,p);
               break;
            case 'I' :
               value = timeptr->tm_hour;
               if (value > 12) value -= 12;
               _asct2dig(value,p);
               break;
            case 'j' :
            case 'J' :
               _asct3dig(timeptr->tm_yday,p);
               break;
            case 'm' :
               _asct2dig(timeptr->tm_mon+1,p);
               break;
            case 'M' :
               _asct2dig(timeptr->tm_min,p);
               break;
            case 'p' :
               p = am_pm[timeptr->tm_hour / 12];
               break;
            case 'S' :
               _asct2dig(timeptr->tm_sec,p);
               break;
            case 'U' :
               value = timeptr->tm_wday - (timeptr->tm_yday % 7);
               if (value < 0) value += 7;  /* week day of Jan 1 */
               value = (timeptr->tm_yday + value - 1) / 7;
               _asct2dig(value,p);
               break;
            case 'w' :
               *p = timeptr->tm_wday + '0';
               break;
            case 'W' :
               value = timeptr->tm_wday - (timeptr->tm_yday % 7);
               if (value < 0) value += 7;  /* week day of Jan 1 */
               value = (timeptr->tm_yday + value) / 7;
               _asct2dig(value,p);
               break;
            case 'x' :
               _asct2dig(timeptr->tm_mon+1,str);
               _asct2dig(timeptr->tm_mday,&str[3]);
               _asct2dig(timeptr->tm_year % 100,&str[6]);
               str[2] = '/';
               str[5] = '/';
               break;
            case 'X' :
               _asct2dig(timeptr->tm_hour,str);
               _asct2dig(timeptr->tm_min,&str[3]);
               _asct2dig(timeptr->tm_sec % 100,&str[6]);
               str[2] = ':';
               str[5] = ':';
               break;
            case 'y' :
               _asct2dig(timeptr->tm_year % 100,p);
               break;
            case 'Y' :
               _asct2dig(timeptr->tm_year / 100,str);
               _asct2dig(timeptr->tm_year % 100,&str[2]);
               break;
            case 'Z' :
               if (timeptr->tm_isdst) p = tzname[1]; else p = tzname[0];
               if (p == NULL) p = str;
               break;
            case '%' :
               *p = '%';
               break;
            }  /* switch */
         while (*p != '\0') put(*p++)
         ++format;
         }  /* '%' */
      } /* while */
   *s = '\0';
   return maxsize - length;
   #undef put
} /* strftime */

char *asctime(time)
struct tm *time;
{     /* convert time to a character string */
   static char *monthname[13] = {"Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"};
   static char *dayname[7] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
   static char timebuf[26];
   int yy;
   strcpy(timebuf,"www mmm dd hh:mm:ss yyyy\n");
   memcpy(timebuf,dayname[time->tm_wday],3);
   memcpy(&timebuf[4],monthname[time->tm_mon],3);
   _asct2dig(time->tm_mday,&timebuf[8]);
   _asct2dig(time->tm_hour,&timebuf[11]);
   _asct2dig(time->tm_min,&timebuf[14]);
   _asct2dig(time->tm_sec,&timebuf[17]);
   yy = time->tm_year < 100 ? 19 : 20;
   _asct2dig(yy,&timebuf[20]);
   _asct2dig(time->tm_year % 100,&timebuf[22]);
   return timebuf;

} /* asctime */

_asct2dig(n, p)
   int n;
   char *p;
{
   *p++ = (n / 10) + '0';
   *p = (n % 10) + '0';
}

_asct3dig(n, p)
   int n;
   char *p;
{
   *p++ = (n / 100) + '0';
   n = n % 100;
   *p++ = (n / 10) + '0';
   *p = (n % 10) + '0';
}

time_t mktime(timeptr)
   struct tm *timeptr;
{
   long _timesec(int, int, int, int, int, int);
   struct tm *localtime();
   struct tm *_timecvt(time_t);
   time_t t;
   t = _timesec(timeptr->tm_year+1900, timeptr->tm_mon+1, timeptr->tm_mday,
         timeptr->tm_hour, timeptr->tm_min, timeptr->tm_sec);
   *timeptr = *localtime(&t);
   return t;
   }

int stime(tp)     /* set time */
   long *tp;
{
   struct tm *t;
   union REGS time, date;
   t = localtime(tp);
   time.h.ah = 0x2d;
   time.h.ch = t->tm_hour;
   time.h.cl = t->tm_min;
   time.h.dh = t->tm_sec;
   time.h.dl = 0;
   date.h.ah = 0x2b;
   date.x.cx = t->tm_year+1900;
   date.h.dh = t->tm_mon+1;
   date.h.dl = t->tm_mday;
   intdos(&date,&date);
   intdos(&time,&time);
   return 0;
   }

struct utimbuf {
    time_t actime;    /* access time       */
    time_t modtime;   /* modification time */
};

int utime(filename, times)
   char *filename;
   struct utimbuf *times;
{
   extern int _doserrno, errno;
   union REGS r;
   struct tm *localtime(time_t *), *tptr;
   union {
      struct ftime time;
      struct {
         int time;
         int date;
         } i;
      } filetime;
   time_t t, time();
   int handle;
   int status;
   if (times == NULL) t = time(NULL); else t = times->modtime;
   tptr = localtime(&t);
   if (_sys_ad(0x3d00,filename,&handle) != 0)
      { errno = _doserrno; return -1; }
   if (tptr->tm_year < 80) filetime.time.ft_year = 0;
   else filetime.time.ft_year = tptr->tm_year-80;
   filetime.time.ft_month = tptr->tm_mon+1;
   filetime.time.ft_day = tptr->tm_mday;
   if (tptr->tm_hour < 0) filetime.time.ft_hour = 0;
   else filetime.time.ft_hour = tptr->tm_hour;
   filetime.time.ft_min = tptr->tm_min;
   filetime.time.ft_tsec = tptr->tm_sec >> 1;
   r.x.ax = 0x5701;
   r.x.bx = handle;
   if (_sysabcd(0x5701,handle,filetime.i.time,filetime.i.date,&status) != 0) {
      errno = _doserrno;
      _sys_ab(0x3e00,handle,&handle);
      return -1;
      }
   _sys_ab(0x3e00,handle,&handle);
   return 0;
}

struct tm *gmtime(time)
long *time;
{
   struct tm *_timecvt();
   return _timecvt(*time);
} /* gmtime */

struct tm *localtime(time)
long *time;
{
   extern long timezone;
   extern int daylight;
   void tzset();
   struct tm *_timecvt();
   static tzdone = 0;
   if (tzdone == 0) {tzset(); tzdone = 1; }
   if (daylight) return _timecvt(*time-timezone+3600);
   return _timecvt(*time-timezone);
} /* localtime */

void unixtodos(utime, dateptr, timeptr)
   long utime;
   struct date *dateptr;
   struct time *timeptr;
{
   extern struct tm *_timecvt();
   extern long timezone;
   extern int daylight;
   struct tm *t;
   long localtime;
   localtime = utime - timezone;
   if (daylight) localtime += 3600l;
   t = _timecvt(localtime);
   dateptr->da_year = t->tm_year + 1900;
   dateptr->da_mon = t->tm_mon+1;
   dateptr->da_day = t->tm_mday;
   timeptr->ti_hour = t->tm_hour;
   timeptr->ti_min = t->tm_min;
   timeptr->ti_sec = t->tm_sec;
   timeptr->ti_hund = 0;
   }

struct tm *_timecvt(time)
long time;
{     /* convert binary time to greenwich mean time */
   static struct tm gm;
   static int daypermonth[12] = {31, 28, 31, 30, 31, 30,
                                 31, 31, 30, 31, 30, 31};
   extern int daylight;
   long secs, days;
   int years, leaps, dayofyear;
   int month = 0;
   int *mptr = daypermonth;
   days = time / 86400;
   years = days/365;
   leaps = (years+1) / 4;
   dayofyear = days - (long)years * 365 - (long)leaps;
   if (dayofyear < 0) {
      years--;
      dayofyear += 365;
      }
   gm.tm_yday = dayofyear;
   gm.tm_year = years+70;
   if ((years % 4) == 2) daypermonth[1] = 29; else daypermonth[1] = 28;
   while (dayofyear > *mptr) {
      ++month;
      dayofyear -= *mptr++;
      }
   gm.tm_mon = month;
   gm.tm_mday = dayofyear+1;
   gm.tm_wday = (days + 4) % 7;
   secs = time - days*86400;
   gm.tm_hour = secs / 3600;
   secs -= (gm.tm_hour * 3600L);
   gm.tm_min = secs / 60;
   gm.tm_sec = secs - (gm.tm_min * 60);
   gm.tm_isdst = daylight;
   return &gm;
} /* _timecvt */

void ftime(timeptr)
struct timeb *timeptr;
{
   long _timesec();
   void tzset();
   extern long timezone;
   extern int  daylight;
   union REGS timecall, datecall;
   union REGS time, date1, date2;
   tzset();
   timecall.h.ah = 0x2c;
   datecall.h.ah = 0x2a;
   intdos(&datecall,&date1);
   intdos(&timecall,&time);
   intdos(&datecall,&date2);
   if (date2.x.dx != date1.x.dx) {  /* date change at midnight */
      if (time.h.ch != 23) {  /* date already changed when time read */
         date1.x.cx = date2.x.cx;
         date1.x.dx = date2.x.dx;
         }
      }
   timeptr->time = _timesec(date1.x.cx, date1.h.dh, date1.h.dl,
      time.h.ch, time.h.cl, time.h.dh);
   timeptr->millitm = time.h.dl*10;
   timeptr->timezone = timezone/60;
   timeptr->dstflag = daylight;
   }  /* ftime */

unsigned sleep(seconds)
   unsigned seconds;
{  /* suspend execution */
   long time();
   long start, now;
   start = time(NULL);
   do {
      now = time(NULL);
      } while ((now-start) < seconds);
   }

long time(timeptr)
long *timeptr;
{
   long _timesec();
   long curtime;
   union REGS timecall, datecall;
   union REGS time, date1, date2;
   timecall.h.ah = 0x2c;
   datecall.h.ah = 0x2a;
   intdos(&datecall,&date1);
   intdos(&timecall,&time);
   intdos(&datecall,&date2);
   if (date2.x.dx != date1.x.dx) {  /* date change at midnight */
      if (time.h.ch != 23) {  /* date already changed when time read */
         date1.x.cx = date2.x.cx;
         date1.x.dx = date2.x.dx;
         }
      }
   curtime = _timesec(date1.x.cx, date1.h.dh, date1.h.dl,
      time.h.ch, time.h.cl, time.h.dh);
   if (timeptr != NULL) *timeptr = curtime;
   return curtime;
   }  /* time */

long dostounix(dateptr, timeptr)
   struct date *dateptr;
   struct time *timeptr;
{
   long _timesec();
   return _timesec(dateptr->da_year,dateptr->da_mon,dateptr->da_day,
           timeptr->ti_hour, timeptr->ti_min, timeptr->ti_sec);
   }

clock_t clock(void)
{
   extern struct {
      unsigned int year;
      unsigned char day;
      unsigned char month;
      unsigned char hour;
      unsigned char minute;
      unsigned char hour;
      unsigned char hundredth;
      unsigned char second;
      } $$CLOCK;              /* time when process started */
   long time;
   union REGS t, d;
   t.h.ah = 0x2c;
   d.h.ah = 0x2a;
   intdos(&d,&d);
   intdos(&t,&t);
   time = _timesec(d.x.cx,d.h.dh,d.h.dl,t.h.cl,t.h.ch,t.h.dh);
   time = time - _timesec($$CLOCK.year,$$CLOCK.month,$$CLOCK.day,
          $$CLOCK.hour,$$CLOCK.minute,$$CLOCK.second);
   return time*100+t.h.dl-$$CLOCK.hundredth;
   }

long _timesec(year, month, day, hour, min, sec)
   int year, month, day, hour, min, sec;
{  /* convert time to seconds since Jan 1 1970 */
   extern long timezone;
   extern int  daylight;
   static int daypermonth[13] = {0, 0, 31, 28+31,
                                 31+59, 30+31+59, 31+30+31+59,
                                 30+151, 31+30+151, 31+31+30+151,
                                 30+243, 31+30+243, 30+31+30+243};
   int years, leaps;
   long days, secs;
   years = year - 1970;
   leaps = (years + 1) / 4;
   if (((years % 4) == 2) && (month > 2)) ++leaps;
   days = (long)years*365 + (long)leaps + (long)daypermonth[month]
          + (long)(day-1);
   secs = days*86400 + (long)hour*3600 + (long)min*60 + (long)sec + timezone;
   if (daylight) return (secs-3600);
   return secs;
}  /* _timesec */

void tzset()
{
   extern int daylight;
   extern long timezone;
   extern char *tzname[2];
   char *tz;
   int  onehour = 3600;
   tz = getenv("TZ=");
   if (tz != NULL) {
      strncpy(tzname[0],tz,3);
      if (strlen(tz) > 3) {
         tz += 3;
         if (*tz == '-') {
            onehour = -onehour;
            ++tz;
            }
         timezone = 0;
         while (isdigit(*tz)) {
            timezone = timezone*10 + (long)onehour*(long)(*tz - '0');
            ++tz;
            }
         if (*tz) daylight = 1; else daylight = 0;
         strncpy(tzname[1],tz,3);
         }
      else {
         timezone = 0;
         daylight = 0;
         *tzname[1] = '\0';
         }
      }
}  /* tzset */

double difftime(time2,time1)
   time_t time1, time2;
{
   return time2-time1;
   }

int daylight = 1;
long timezone = 28800;
char *tzname[2] = {"PST", "PDT"};

void getdate(dateblk)
   struct date *dateblk;
{
   union REGS r;
   r.h.ah = 0x2a;
   intdos(&r,&r);
   dateblk->da_year = r.x.cx;
   dateblk->da_mon = r.h.dh;
   dateblk->da_day = r.h.dl;
   }

void gettime(timep)
   struct time *timep;
{
   union REGS r;
   r.h.ah = 0x2c;
   intdos(&r,&r);
   timep->ti_min = r.h.cl;
   timep->ti_hour = r.h.ch;
   timep->ti_hund = r.h.dl;
   timep->ti_sec = r.h.dh;
   }

void setdate(dateblk)
   struct date *dateblk;
{
   union REGS r;
   r.x.cx = dateblk->da_year;
   r.h.dh = dateblk->da_mon;
   r.h.dl = dateblk->da_day;
   r.h.ah = 0x2b;
   intdos(&r,&r);
   }

void settime(timep)
   struct time *timep;
{
   union REGS r;
   r.h.cl = timep->ti_min;
   r.h.ch = timep->ti_hour;
   r.h.dl = timep->ti_hund;
   r.h.dh = timep->ti_sec;
   r.h.ah = 0x2d;
   intdos(&r,&r);
   }

