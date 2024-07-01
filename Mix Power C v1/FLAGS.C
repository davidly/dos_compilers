/* Flag setting functions */
/*   Copyright (c) Mix Software 1988    */

conbuf(flag)
int flag;
{
    int oldflag;
    extern char $$UBCON;
    oldflag = $$UBCON;
    $$UBCON = flag;
    return oldflag;
}

mathtrap(flag)
int flag;
{
    int oldflag;
    extern char $$ARTERM;
    extern char _mathmsg;
    oldflag = $$ARTERM;
    $$ARTERM = flag;
    _mathmsg = flag;
    return oldflag;
}

char _mathmsg = 0;

filetrap(flag)
int flag;
{
    int oldflag;
    extern char $$IOTERM;
    oldflag = $$IOTERM;
    $$IOTERM = flag;
    return oldflag;
}

heaptrap(flag)
int flag;
{
    int oldflag;
    extern char $$HPTERM;
    oldflag = $$HPTERM;
    $$HPTERM = flag;
    return oldflag;
}

iofilter(linefeed, ctrlz)
int linefeed, ctrlz;
{
    extern char $$CLFEED;
    extern char $$CCTLZ;
    $$CLFEED = linefeed;
    $$CCTLZ = ctrlz;
}

exitmsg()
{
    extern void (*$$EXITPT)();
    void _exitmsg();
    extern void (*_exitptr)();
    if (_exitptr == NULL) {
       _exitptr = $$EXITPT;
       $$EXITPT = _exitmsg;
        }
    }

void _exitmsg()
{
    extern void (*_exitptr)();
    extern unsigned $$BOTTOM, $$MAXS, $$LIMIT, $$MAXH, $$HMAX, $$HMIN;
    static char msg[]
           = "xxxxx bytes of heap space used, xxxxx bytes free\r\l$";
    static char stk[]
           = "xxxxx bytes of stack used, xxxxx bytes free\r\l$";
    char *stkptr;
    int x;
    stkptr = (char *) $$LIMIT;
    while (*stkptr == 0) ++stkptr;
    _utoa($$BOTTOM - (unsigned) stkptr,&stk[0]);
    _utoa((unsigned) stkptr - $$LIMIT,&stk[27]);
    _sys_ad(0x0900,stk,&x);
    _utoa($$MAXH,&msg[0]);
    _utoa($$HMAX-$$HMIN-$$MAXH,&msg[32]);
    _sys_ad(0x0900,msg,&x);
    (*_exitptr)();
    }

void    (*_exitptr)() = NULL;


_utoa(n, s)     /* convert unsigned int to fixed size string */
unsigned n;     /* result is 5 characters, right justified   */
char    *s;     /* with leading zeros suppressed */
{
    char *ptr;
    setmem(s,5,' ');
    ptr = s+4;
    do {
       *(ptr--) = n % 10 + 0x30;
    } while ((n /= 10) > 0);
    return s;
}

