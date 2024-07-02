#ifndef INTVECTHPP
#define INTVECTHPP
#include <int.h>
#include "errn.hpp"

void default_error(int, char*);
typedef int (cdecl *ihandler)(struct INT_DATA *);
enum { IV_OK, IV_ALREADY, IV_NOTACTIVE, IV_NOCANDO, IV_FAILURE };
enum { INITED = 1, ACTIVE };

class intvector {
    unsigned char state;        // use bits 1 and 2 for inited and active
    unsigned char vector;       // only 255 vectors max
    unsigned stack;             // stack size needed by current server
    ihandler intserver;         // pointer to current server
public:
    intvector() { state = 0; }  // default do-nothing initialiser
    virtual int install(unsigned, ihandler, unsigned = 256);
                                // install with error checking
    intvector(unsigned v, ihandler fp, unsigned s = 256) {
        state = 0;
        if (install(v,fp,s))
            default_error(EINTVEC,"intvec - failed to install handler");
    }                           // install initialiser - abort on error
    int suspend(void);          // deactivate
    int reinstate(void);        // reactivate
    virtual int newhandler(ihandler, unsigned);
                                // specify new server
    unsigned operator()(void) { return vector; }    // who am I function
    unsigned status(void) { return state; }         // state access function
    ~intvector() { suspend(); }
};
#endif
