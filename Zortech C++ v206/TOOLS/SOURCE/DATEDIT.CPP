#include <string.h>
#include <datedit.hpp>

static int lmonth[] = {0,31,29,31,30,31,30,31,31,30,31,30,31};

int date_editor::filter(char c, char *s, int pos)
{
    int d,m,y,len;
    if (!isdigit(c))            // the overiding filter requirement
        return 0;
    if ((len = strlen(s)) == 6 && pos == len)
        return 0;               // probably belt and braces with sedit::edit
    memmove(loc,s,6);           // make a local copy of what we have
    loc[pos] = c;               // and add the hypothetical digit
    if (pos == len)
        ++len;                  // if at the end adjust the length
    m = month(); d = day(); y = year(); // figure out what the string means
    if (_usdate) switch (pos) { // depending where the cursor is
        case 0:
        case 1:                 // looking at the month
            if (len >= 2) {     // both month digits present
                if (m > 12 || m < 1)    // must be in [1 - 12]        
                    return 0;
                if (len >= 4) {     // got the days digits too
                    if (len == 6 && y%4 && m == 2 && d > 28)
                        return 0;   // check if we have year and leap violation
                    if (d <= lmonth[m])
                        return 1;   // day OK for month - accept it
                    return 0;       // otherwise no good
                }
            }
            return c < '2'? 1: 0;   // only one month digit
        case 2:
        case 3:                 // looking at day
            if (len >= 4) {     // have both day digits
                if (d < 1)
                    return 0;   // 0 is not a date
                if (len == 6 && y%4 && m == 2 && d > 28)
                    return 0;   // check if we have year and leap violation
                if (d <= lmonth[m])
                    return 1;   // day OK for month - accept it
                return 0;       // otherwise no good
            }
            return c < '4'? 1: 0;   // only one day digit
        case 4: 
            return 1;           // can not comment on this one
        case 5:
            if (y%4 && m == 2 && d > 28)
                return 0;       // check for leap year violation
            return 1;
    } else switch (pos) {
        case 0:
        case 1:
            if (len == 6) {
                if (y%4 && m == 2) {
                    if (d > 28 || d < 1)
                        return 0;
                }
            }
            if (len >= 4) {
                if (d <= lmonth[month()] && d > 0)
                    return 1;
                return 0;
            } else if (len >= 2) {
                if (d < 32 && d > 0)
                    return 1;
                return 0;
            } else
                return c < '4'? 1: 0;
        case 2:
        case 3:
            if (len >= 4) {
                if (m > 12 || m < 1)
                    return 0;
                if (len == 6 && y%4 && m == 2 && d > 28)
                    return 0;
                if (d <= lmonth[m])
                    return 1;
                return 0;
            }
            return c < '2'? 1: 0;
        case 4:
            return 1;
        case 5:
            if (y%4 && m == 2 && d > 28)
                return 0;
            return 1;
    }
}
