#include <criterr.hpp>

#if LPTR
#define NULLF 0L
#else
#define NULLF 0
#endif

static int (*useptr)(int,int) = NULLF;

static int cdecl errhdlr(struct INT_DATA *pd)
{
    int drive = (pd->regs.h.ah & 0x80)? 0: pd->regs.h.al+'A';
    pd->regs.h.al = (*useptr)(drive, pd->regs.x.di);
                    // call user handler with error codes
    return 1;       // immediate RETI
}

ce_handler::ce_handler(int (* user_handler)(int, int))
{
    if (!useptr)
        int_intercept(0x24,errhdlr,256);
    predecessor = useptr;
    useptr = user_handler;
}

void ce_handler::previous()
{
    if (predecessor)
        useptr = predecessor;
    else {
        useptr = NULLF;
        int_restore(0x24);
    }
}
