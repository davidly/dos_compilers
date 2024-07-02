#include <dlist.hpp>

typedef void (* PFC)(int,char *);
extern void default_error(int,char *);
PFC dlist_handler = default_error;

dlist::dlist(void* a, int ho)
{
    root = current = NULL; lpos = count = 0L;
    heapobj = ho;
    if (linkin(a) == -1)
        dlist_handler(ENOMEM,"dlist - not enough memory");
}

int dlist::linkin(void* ent)
{
    dnode *t;
    if (!root) {                // nothing there yet
        root = new dnode;       // allocate a node
        if (!root)
            return(-1);          // signal no memory available
        root->prev = root;      // a circular list of one item see fig 5.1
        root->next = root;      // prev and next point to itself
        root->body = ent;       // associate the data item
        current = root;         // current == only
        lpos = 1L;
    } else {
        t = new dnode;
        if(!t)
            return(-1);
#if LPTR
        if ((long) current == (long) root)
#else
        if (current == root)
#endif
            root = t;           // adjust root if inserting at tail
        current->next->prev = t;
        t->next = current->next;
        current->next = t;
        t->prev = current;      // link in new node after current
        t->body = ent;          // see fig 2.2
        ++lpos;
        current = t;            // adjust currency to new item
    }
    count++;
    return(0);
}

void* dlist::linkout()
{
    dnode *t;
    void *r;

    if (!root) {
        dlist_handler(EEMPTY,"dlist - attempted linkout from empty list");
        return NULL;
    }
#if LPTR
    if ((long) current == (long) root) {
#else
    if (current == root) {
#endif
        if (count == 1L) {              // only item
            r = root->body;
            delete root;
            root = current = NULL;      // revert to initial state
            lpos = count = 0L;
        } else {                        // deleting tail
            current = root->prev;
            root->next->prev = current;
            current->next = root->next;
            r = root->body;
            delete root;
            root = current;             // root must be adjusted to new tail
            --count;
            --lpos;
        }
    } else {
        t = current->next;              // currency moves to next item
        current->prev->next = t;        // preserving head of list position
        t->prev = current->prev;        // if originally there
        r = current->body;
        delete current;
        current = t;
        --count;                        // lpos not affected
    }
    return r;
}
            
void dlist::cleanup()
{
    dnode *t;
    if (!root)
        return;
    for (; count > 1; --count) {
        t = root->next;
        if (heapobj)
            delete root->body;
        delete root;
        root = t;
    }
    if (heapobj)
        delete root->body;
    delete root;
}

void *dlist::get()
{
    if (!root) {
        dlist_handler(EEMPTY,"dlist - attempted get from empty list");
        return NULL;
    }
    return current->body;
}

void dlist:: update(void *p)
{
    if (!root) {
        dlist_handler(EEMPTY,"dlist - attempted update of empty list");
        return;
    }
    if (heapobj)
        delete current->body;
    current->body = p;
}

PFC set_dlist_handler(PFC handler)
{
    PFC local = dlist_handler;
    dlist_handler = handler;
    return local;
}
