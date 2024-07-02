#ifndef HASHHPP
#define HASHHPP
#include <string.h>
#include "generic.hpp"
#include "errn.hpp"

class hashitem {
    friend class hash;
    friend void hash_report(hash&);
    hashitem *next;
    void *body;
    char name[1];   //actual length unknown
};

typedef hashitem *HIPT;
unsigned default_hash(char *, int);
typedef unsigned (* HASHFUNC)(char *, int);
//HASHFUNC v107temp = default_hash;

class hash {
    HIPT *table;
    int tabsize;
    HASHFUNC hashfunc;
public:
    hash(int, HASHFUNC foo = &default_hash);
    void* insert(char*, void*);
    int remove(char*);
    void* lookup(char*);
    void cleanup(void);
    ~hash() { cleanup(); }
    friend void hash_report(hash&);
};

#define ghsearch(type) name2(type,ghsearch)

#define ghsearchdeclare(type)                           \
struct ghsearch(type) : hash {                          \
    ghsearch(type)(int s, HASHFUNC f = &default_hash) :  \
        (s,f) {}                                        \
    type insert(char *a, type b)                        \
        { return hash::insert(a,b); }                   \
    int remove(char * p)                                \
        { return hash::remove(p); }                     \
    type lookup(char *p)                                \
        { return hash::lookup(p); }                     \
}
#endif
