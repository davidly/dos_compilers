#include <slist.hpp>

typedef void (* PFC)(int,char *);
extern void default_error(int,char *);
PFC slist_handler = default_error;

slist::slist(ent a)
{
    if ((last = new slink(a)) == NULL) {
        slist_handler(ENOMEM,"slist - out of memory");
        return;         // standard error handling approach
    }   
    last->next = last;
}

int slist::insert(ent a)
{
    slink* t = new slink(a);
    if (!t) return(-1); // insert failed
    if (last) {         // list already exists
        t->next = last->next;
        last->next = t; // a becomes new head of list
    } else {
        last = t;       // new first item
        last->next = last;
    }
    return(0);
}

int slist::append(ent a)
{
    slink* t = new slink(a);
    if (!t) return(-1);
    if (last) {
        t->next = last->next; // put a at head of list
        last = last->next = t;// then move tail pointer
    } else {
        last = t;       // new first item
        last->next = last;
    }
    return(0);
}

ent slist::get()
{
    if (last == NULL) {
        slist_handler(EEMPTY,"slist - attempted get from empty list");
        return NULL;
    }
    slink* f = last->next;
    ent r = f->e;
#if LPTR
    if ((long) f == (long) last)
#else
    if (f == last)
#endif
        last = NULL;
    else
        last->next = f->next;
    delete f;
    return r;
}

void slist::clear(int all)
{
    slink* l = last;
    if (!l)
        return;
    do {
        slink* ll = l;
        l = l->next;
        if (all) 
            delete ll->e;   // node as well
        delete ll;
    } while (l != last);
    last = NULL;            // put back in initial state
}

ent slist_iterator::operator()()
{
    if (!cs->last)
        return(NULL);
    slink* ll;
    if (!ce) {
        ce = cs->last->next;
        return ce->e;
    } else if
#if LPTR
            ((long) ce == (long) cs->last) {
#else
            (ce == cs->last) {
#endif
        ce = NULL;
        return(NULL);
    } else {
        ce = ce->next;
        return ce->e;
    }
}

PFC set_slist_handler(PFC handler)
{
    PFC local = slist_handler;
    slist_handler = handler;
    return local;
}
