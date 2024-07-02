#ifndef SLISTHPP
#define SLISTHPP
#include <stddef.h>
#include <generic.hpp>
#include "errn.hpp"
#if LPTR
#define LCAST (long)
#else
#define LCAST
#endif

typedef void* ent;

class slink {
    friend class slist;             // Members must be accessible to slist
    friend class slist_iterator;    // and to the iterator
    slink* next;
    ent e;
    slink(ent a) {e = a; next = NULL; }
};

class slist {
    friend class slist_iterator;
    slink* last;                    // last->next is head of list
public:
    int insert(ent a);              // add at head of list
    int append(ent a);              // add at tail of list
    ent get(void);                  // return and remove head of list
    void clear(int = 0);            // remove all links

    slist(void) { last = NULL; }
    slist(ent a);
    ~slist() { clear(); }
};

class slist_iterator {
    slink* ce;
    slist* cs;
public:
    slist_iterator(slist& s) { cs = &s; ce = NULL; }
    ent operator()(void);
};

#define gslist(type) name2(type,gslist)
#define gslist_iterator(type) name2(type,gslist_iterator)

#define gslistdeclare(type)                                   \
struct gslist(type): slist {                                  \
    int insert(type a) { return slist::insert(a); }           \
    int append(type a) { return slist::append(a); }           \
    type get() { return (type) slist::get(); }                \
    void flush(int all = 0) { slist::clear(all); }            \
    gslist(type)(void) {}                                     \
    gslist(type)(type a) : ((void *) a) {}                    \
};                                                            \
                                                              \
struct gslist_iterator(type) : slist_iterator {               \
    gslist_iterator(type)(gslist(type)& s) : (s) {}           \
    type operator()()                                         \
        { return (type) slist_iterator::operator()(); }       \
}

#define gqueue(type) name2(type,gqueue)

#define gqueuedeclare(type)                                   \
struct gqueue(type): slist {                                  \
    int queue(type a) { return slist::append(a); }            \
    type dequeue() { return (type) slist::get(); }            \
    gqueue(type)() {}                                         \
    gqueue(type)(type a) : (a) {}                             \
}

#define gstack(type) name2(type,gstack)

#define gstackdeclare(type)                                   \
struct gstack(type): slist {                                  \
    int push(type a) { return slist::insert(a); }             \
    type pop() { return (type) slist::get(); }                \
    gstack(type)() {}                                         \
    gstack(type)(type a) : (a) {}                             \
}

class iqueue : slist {
    unsigned ic;
public:
    void queue(int a) { slist::append((ent) (LCAST a));  ++ic; }
    int dequeue() {  return ic? (--ic, (int) slist::get()): 0; }
    int any() { return ic; }
    iqueue(void) { ic = 0; }
    iqueue(int n) : ((ent) (LCAST n)) { ic = 0; }
};

class istack : slist {
    unsigned ic;
public:
    void push(int a) { slist::insert((ent) (LCAST a)); ++ic; }
    int pop() {  return ic? (--ic, (int) slist::get()): 0; }
    int any() { return ic; }
    istack(void) { ic = 0; }
    istack(int n) : ((ent) (LCAST n)) { ic = 0; }
};

#endif
