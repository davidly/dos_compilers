#ifndef BINTREEHPP
#define BINTREEHPP
#include <stddef.h>
#if LCODE
#define NULLF 0L
#else
#define NULLF 0
#endif
#include <generic.hpp>
#include "errn.hpp"

typedef int (*IPVPVP)(void*,void*); // kludges for version 1.06
typedef void (*VPVP)(void*);        // which does not always understand
                                    // void*
class node {
    friend class bintree;
    node *left, *right;
    void* body;
};

class bintree {
    node* root;
    int (* cf)(void*, void*);
    void (* visit)(void*);
public:
    bintree(int (* compare)(void*, void*) = NULLF,
                    void (* what_to_do)(void*) = NULLF)
        { root = NULL; cf = compare; visit = what_to_do; }
    void* insert(void *, int&);
    int remove(void *);
    void* seek(void*);
    void set_process(void (*v)(void*)) { visit = v; }
    void set_comp(int (* compare)(void*, void*)) { cf = compare; }
    void inorder(node* n = NULL, int first = 1);
    void cleanup(node* n = NULL, int first = 1);
    ~bintree(void) { cleanup(); }
};

#define gbsearch(type) name2(type,gbsearch)

#define gbsearchdeclare(type)                           \
struct gbsearch(type) : bintree {                       \
    gbsearch(type)(int (* compare)(type,type) = NULLF,  \
            void (*what_to_do)(type) = NULLF) :         \
             ((IPVPVP) compare, (VPVP) what_to_do) {}   \
    type insert(type a, int& result)                    \
        { return bintree::insert(a, result); }          \
    int remove(type a)                                  \
        { return bintree::remove(a); }                  \
    type seek(type a)                                   \
        { return bintree::seek(a); }                    \
    void set_process(void (*v)(void*))                  \
        { bintree::set_process((VPVP) v); }             \
    void set_comp(int (*c)(type, type))                 \
        { bintree::set_comp((IPVPVP) c); }              \
    void inorder(void) { bintree::inorder(); }          \
}

#endif
