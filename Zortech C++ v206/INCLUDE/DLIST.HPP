#ifndef DLISTHPP
#define DLISTHPP
#include <stdio.h>
#include <generic.hpp>
#include <stddef.h>
#include "errn.hpp"

extern int _allocerr;

class dnode {
    friend class dlist;
    dnode *next, *prev;     // pointers to next and previous items in list
    void *body;             // points to whatever is associated with this node
};

class dlist {
    dnode *root;            // root->next is head of list *root is tail
    dnode *current;         // remembers current context
    long count;             // how many items in the list
    long lpos;              // where are we now
    int heapobj;            // delete objects as well as nodes?
public:
    int linkin(void*);      // put new item in list before current
    void* linkout(void);    // remove and return pointer to current item
    void fwd(void) { if (lpos < count) { current = current->next; ++lpos;} }
    void bkwd(void) { if (lpos > 1L) { current = current->prev; --lpos;} }
    void start(void) { current = root->next; lpos = 1; }
    void end(void) { current = root; lpos = count; }
    void* get(void);
    void update(void*);
    long size(void) { return count; }
    void cleanup();
    dlist(void)
    { root = NULL; current = NULL; lpos = count = 0L; heapobj = 0; }
    dlist(void* a, int = 0);
    void setdel(int n) { heapobj = n; }
    ~dlist() { cleanup(); }
};

#define gdlist(type) name2(type,gdlist)

#define gdlistdeclare(type)                                         \
struct gdlist(type) : public dlist {                                \
    gdlist(type)(void) {}                                           \
    gdlist(type)(type a) : (a) {}                                   \
    void operator+=(int n) { while (n--) dlist::fwd(); }            \
    void operator-=(int n) { while (n--) dlist::bkwd(); }           \
    void operator++(void) { dlist::fwd(); }                         \
    void operator--(void) { dlist::bkwd(); }                        \
    void operator=(type a) {dlist::update(a); }                     \
    type operator*(void) { return (type) dlist::linkout(); }        \
    type operator()(void) { return (type) dlist::get(); }           \
    void setflush(int n) { dlist::setdel(n); }                      \
}

#endif
