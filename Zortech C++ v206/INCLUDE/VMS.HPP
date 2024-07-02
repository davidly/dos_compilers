#ifndef VMSHPP
#define VMSHPP
#include <stdio.h>
#include <string.h>
#include <generic.hpp>
#include "errn.hpp"

#define VM_DIRTY 1
#define VM_INUSE 2

class indexitem {
    friend class vms;
    indexitem *next;
    long logical,actual;
    unsigned slot;
public:
    indexitem(long l = 0L, long a = 0L, unsigned s = -1)
        { logical = l; actual = a; slot = s; }
};

typedef indexitem* pindex;

class residence {
    friend class vms;
    unsigned asu;           // accesses since used
    unsigned flags;         // VM_INUSE & VM_DIRTY
    long ind;               // logical index number of this block
    char it;                // placemarker for data
};

typedef residence *residence_ptr;

class vms {
    FILE *fp;               // data file pointer
    char *fn;               // file name
    long nmax;              // largest permissible index
    unsigned ritems;        // no of items resident in memory
    unsigned es;            // element size
    char *empty;            // points at copy of initialized element
    long ccount;            // number in file
    int freeblocks;         // blocks not yet used
    residence_ptr *rp;      // pointer to resident block pointer array
    pindex *table;          // pointer to list of indexitem chains
    unsigned tabsize;       // no of chains
    void insert(pindex);    // put item in index
    pindex lookup(long);    // check index for item
    void cleanup(void);     // purge the index
    void reindex(void);     // rebuild index file
    void file_get(int, indexitem *);      // read a block
    void file_put(int, indexitem *);      // write a block
    void age(int);          // update the asu fields
    void (* elem_init)(void *);  // function to initialize an element
public:
    vms(long, unsigned, unsigned, char *, int, void (*)(void*), unsigned);
    char *access(long, int);   // general purpose access function
    long nelems(void) { return ccount; }
    void flush(void);       // flush everything to file
    ~vms() { flush(); fclose(fp);
                    cleanup(); delete fn; delete rp; }
};

#define gvms(type) name2(type,gvms)

#define gvmsdeclare(type)                                         \
struct gvms(type): vms {                                          \
    gvms(type)(long me,unsigned ri,unsigned iw,char *fn,int cf,   \
        void (*ei)(void*)) : (me,ri,iw,fn,cf,ei,sizeof(type)) {}  \
    void flush() { vms::flush(); }                                \
    type& operator[](long i)                                      \
        { return *((type *) vms::access(i,1)); }                  \
    type operator()(long i)                                       \
        { return *((type *) vms::access(i,0)); }                  \
    long nelems(void) { return vms::nelems(); }                   \
}
#endif
