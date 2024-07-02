#include <string.h>
#include "dynarr.hpp"

typedef void (* PFC)(int,char *);
extern void default_error(int,char *);
PFC dynarr_handler = default_error;     // set handler to default

int dynarr::resize(unsigned newsize)    // change the size of the storage block
{                                       // this will always be an increase
    char *p = new char[newsize*es];
    if (!p)
        return -1;                      // signal failure
    memset(p,'\0',newsize*es);          // set all to zero
    memmove(p,body,elems*es);           // then copy in existing elements
    delete body;                        // zap the old storage
    body = p;                           // and point to new
    elems = newsize;                    // adjust the element count
    return 0;
}

dynarr::dynarr(unsigned n,unsigned elemsize)
{
    elems = n;
    es = elemsize;
    dummy = new char[es];       // used on allocation error
    if (!dummy)
        goto err1;
    body = new char[es*elems];  // allocate requested storage (default one)
    if (!body) {
err1:
        dynarr_handler(ENOMEM,"dynarr - not enough memory");
        return;                 // call whatever error handler is installed
    }
    memset(body,'\0',es*elems); // initialize storage to zero
}

char *dynarr::access(unsigned i)
{
    if (i >= elems) {           // requested index outside current storage
        if (resize(i+1)) {      // elems is 1 > index
            dynarr_handler(ENOMEM,"dynarr - not enough memory");
            return dummy;       // give access to something safe
        }
    }
    return body+i*es;           // pointer to appropriate block
}

PFC set_dynarr_handler(PFC handler)
{                               // function to set error handling
    PFC local = dynarr_handler;
    dynarr_handler = handler;
    return local;
}

