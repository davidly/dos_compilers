#include <stream.hpp>
#include <hash.hpp>

typedef void (* PFC)(int, char*);
extern void default_error(int,char*);
static PFC ghsearch_handler = default_error;

hash::hash(int sz, HASHFUNC foo)
{
    table = new HIPT[sz];
    if (!table) {
        ghsearch_handler(ENOMEM,"ghsearch - not enough memory");
        return;
    }
    memset(table,'\0',sz*sizeof(void*));
    tabsize = sz; hashfunc = foo;
}

void* hash::insert(char *item, void* data)
{
    unsigned hv;
    int len = strlen(item);
    HIPT np;    
    if (!item) {
        ghsearch_handler(EBADARG,"ghsearch - insert called with null pointer");
        return NULL;
    }
    hv = (*hashfunc)(item,tabsize);     // get hash #
    if (table[hv]) {
        np = table[hv];                 // chain exists
        for (;;) {
            if (!(strcmp(np->name,item)))
                return(np->body);
            if (!np->next)
                break;
            np = np->next;              // hop along chain
        }
        np->next = (HIPT) new char[sizeof(HIPT)+sizeof(void*)+len+1];
                                        // allocate new item
        if (!np->next)
            goto errcon;        // apologies to purists
        np = np->next;
        np->body = data;
        strcpy(np->name,item);          // fill it in
        np->next = 0;
    } else {                            // no chain
        table[hv] = (HIPT) new char[sizeof(HIPT)+sizeof(void*)+len+1];
                            // allocate first item of chain
        if (!table[hv])
            goto errcon;
        np = table[hv];;
        np->body = data;
        strcpy(np->name,item);
        np->next = 0;                   // copy in information
    }
    return NULL;
errcon:
    ghsearch_handler(ENOMEM,"ghsearch - not enough memory");
    return NULL;            // error function may return
}


int hash::remove(char *item)
{
    unsigned hv;
    HIPT np, last;    

    if (!item)
        ghsearch_handler(EBADARG,"ghsearch - remove called with null pointer");
    hv = (*hashfunc)(item,tabsize);
    np = table[hv];
    if (!np)                            // no such item
        return(-1);
    if (!np->next) {                    // only item on this chain
        delete np->body;
        delete np;
        table[hv] = NULL;
        return(0);
    } else                              // first item on chain matches
        if (!strcmp(item,np->name)) {
            delete np->body;
            table[hv] = np->next;
            delete np;
            return(0);
    } else {                            // must look along chain
        for (; np;) {
            last = np;
            np = np->next;
            if (!strcmp(item,np->name)) {   // match found
                delete np->body;
                last->next = np->next;      // link it out
                delete np;
                return(0);
            }
        }
        return(-1);
    }
}

void* hash::lookup(char *p)
{
    unsigned hv;
    HIPT np;    

    hv = (*hashfunc)(p,tabsize);
    np = table[hv];
    for (; np; np = np->next) {
        if (!(strcmp(np->name,p)))
            return(np->body);
    }
    return NULL;
}

void hash::cleanup()
{
    int i;
    HIPT p, q;

    for (i = 0; i < tabsize; ++i) {
        p = table[i];
        for (p = table[i]; p; p = q) {
            q = p->next;
            delete p->body;
            delete p;
        }
    }
    delete table;
}

void hash_report(hash& ht)
{
    int n,i, freq[22];
    HIPT np;

    memset(freq,'\0',sizeof(freq));
    for (i = 0; i < ht.tabsize; ++i) {
        if (!ht.table[i]) {
            freq[0]++;
        } else {
            np = ht.table[i];
            for (n = 0; np;) {
                ++n;
                np = np->next;
            }
            freq[n]++;
            if (n) {
                printf("%4d - ",i);
                np = ht.table[i];
                for (n = 0; np;) {
                    printf("%s ",np->name);
                    np = np->next;
                }
                printf("\n");
            }        
        }
    }
    for (i = 0; i < 21; ++i)
        printf("%4d %4d\n",i,freq[i]);
}

static unsigned rtab[] = {
    7092,
    5393,
    1741,
    4217,
    8537,
    3043,
    5931,
    9660,
    5143,
    1161,
    3498,
    1563,
    4308,
    6730,
    2102,
    1535,
    7973,
    3797,
    6688,
    2813,
    9165,
    3116,
    9907,
    1224,
    5662,
    2614
};

unsigned default_hash(char *w, int modulo)
{
    char *p,*q;
    unsigned x,y = 0;

    x = strlen(w)-1;
    for (p = w+x; p >= w; --p) {
        y += rtab[*p - 'a'];    // effect outcome as broadly as possible
        y += x*(*p);            // make it depend on order
        --x;
    }
    x = y & (modulo-1);
    return(x);
}

#if 0
unsigned default_hash(char *w, int modulo)
{
    unsigned x,y = 0;

    while (*w) y = y << 1 ^ *w++;
    y = y & (modulo-1);
    return(y);
}
#endif

PFC set_ghsearch_handler(PFC handler)
{
    PFC loc = ghsearch_handler;
    ghsearch_handler = handler;
    return loc;
}
