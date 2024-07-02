#ifndef DYNARRHPP
#define DYNARRHPP
#include <generic.hpp>
#include "errn.hpp"

class dynarr {
    char *dummy;
    unsigned elems;
    unsigned es;
    char *body;
    int resize(unsigned);
public:
    dynarr(unsigned n = 1, unsigned elemsize = 1);
    ~dynarr(void) { delete body; }
    char *access(unsigned);
    char *address(void) { return body; }
    unsigned size(void) { return elems; }
};

#define gdynarr(type) name2(type,gdynarr)

#define gdynarrdeclare(type)                                    \
struct gdynarr(type): dynarr {                                  \
    gdynarr(type)(unsigned n = 1) : (n, sizeof(type)) {}        \
    type& operator[](unsigned i)                                \
        { return *((type *) dynarr::access(i)); }               \
    type *operator&(void) { return (type *) dynarr::address(); }\
    unsigned size(void) { return dynarr::size(); }              \
}
#endif
