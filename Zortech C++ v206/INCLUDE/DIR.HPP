#ifndef DIRHPP
#define DIRHPP
#include <dos.h>
#include <string.h>
#include "dlist.hpp"
#include "errn.hpp"

extern int _allocerr;

struct file_info {
    char attribute;
    unsigned time,date;
    unsigned long size;
    char name[13];
};

typedef file_info *pfinf;
declare(gdlist,pfinf);

class directory {
    gdlist(pfinf) d;
public:
    int count;
    directory(char *spec = "*.*", int attr = 0);
    pfinf first()
    {
        return count? (d.start(), d()): 0;
    }
    pfinf last()
    {
        return count? (d.end(), d()): 0;
    }
    pfinf next()
    {
        pfinf t, n;
        return count?
            (t = d(), d++, n = d(), t == n? 0: n): 0;
    }
    pfinf prev()
    {
        pfinf t, n;
        return count?
            (t = d(), d--, n = d(), t == n? 0: n): 0;
    }
};
#endif
