#ifndef VMAHPP
#define VMAHPP
#include <generic.hpp>
#include <string.h>
#include "errn.hpp"

class mem_block_data {      // in memory block admin information
    friend class vma;  
    long first_element;     // element no of first element this block
    unsigned asu;           // accesses since used
    unsigned flags;         // indicating block in use and write required
};

class vma {
    char *fn;               // file name
    int fd;                 // associated file descriptor
    long nelems;            // total no of elements
    unsigned perblock;      // no of items read or written at a time
    int rblocks;            // no of blocks resident in memory
    unsigned blocksize;     // bytes per block
    unsigned es;            // element size
    mem_block_data *mbd;    // pointer to memory block data list
    char **bl;              // pointer to memory block pointer list
    int file_get(int, long);      // read a block
    void file_put(int, long);     // write a block
    void age(int);          // update the asu fields
    void (* elem_init)(void *);  // function to initialize an element
public:
    vma(long, unsigned, unsigned, char *, int, void (*)(void*),
                unsigned elemsize);
    char *access(long, int);   // general purpose access function
    void flush(void);       // flush everything to file
    ~vma() { flush(); close(fd); delete fn; delete mbd; delete bl; }
};

#define gvma(type) name2(type,gvma)

#define gvmadeclare(type)                                         \
struct gvma(type): vma {                                          \
    gvma(type)(long te,unsigned pb,unsigned bs,char *fn,int cf,   \
        void (*ei)(void*)) : (te,pb,bs,fn,cf,ei,sizeof(type)) {}  \
    type& operator[](long i)                                      \
        { return *((type *) vma::access(i,1)); }                  \
    type operator()(long i)                                       \
        { return *((type *) vma::access(i,0)); }                  \
}
#endif
