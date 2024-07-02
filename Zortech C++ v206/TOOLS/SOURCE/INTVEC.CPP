#include <intvec.hpp>

int intvector::install(unsigned vect, ihandler funcptr,
                                unsigned stacksize)
{
    if (state & INITED)     // use newhandler to update
        return IV_ALREADY;
    state |= INITED;        // set initialised flag
    vector = vect; intserver = funcptr; stack = stacksize;
                            // and copy in parameters
    if (!int_intercept(vect,funcptr,stacksize)) {
        state |= ACTIVE;    // success - new server now in charge
        return IV_OK;
    } else
        return IV_FAILURE;
}

int intvector::suspend()
{
    if (!(state & ACTIVE))
        return IV_NOTACTIVE;
    if (!int_restore(vector)) {
        state &= ~ACTIVE;
        return IV_OK;
    } else
        return IV_FAILURE;
}

int intvector::reinstate()
{
    if (state != INITED)        // can only reinstate if inited and not active
        return (state & ACTIVE)? IV_ALREADY: IV_NOCANDO;
    if (!int_intercept(vector,intserver,stack)) {
        state |= ACTIVE;
        return IV_OK;
    } else
        return IV_FAILURE;
}

int intvector::newhandler(ihandler funcptr,
                                    unsigned stacksize)
{
    if (!(state & INITED))      // not initialised, so vector unknown
        return IV_NOCANDO;
    if (state & ACTIVE)         // active, so put original handler back first
        if (int_restore(vector))
            return IV_FAILURE;
    state &= ~ACTIVE;
    intserver = funcptr;
    if (!int_intercept(vector,intserver,stack)) {
        state |= ACTIVE;        // new handler
        return IV_OK;
    } else
        return IV_FAILURE;
}
