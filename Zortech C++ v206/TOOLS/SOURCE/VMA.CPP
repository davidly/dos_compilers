#include <io.h>
#include <vma.hpp>

#define VM_DIRTY 1                      // miscellaneous flag bits
#define VM_INUSE 2

typedef char* cptr;
typedef void (* PFC)(int, char*);
extern void default_error(int, char*);  // modifiable error handler
PFC vma_handler = default_error;

vma::vma(long ne, unsigned pb, unsigned rb,
           char *fname, int create, void (*ei)(void *), unsigned elemsize)
{
    mbd = new mem_block_data[rb];   // make list of housekeeping structures
                                    // one for each resident block
    if (!mbd) {
allerr:
        vma_handler(ENOMEM,"gvma - not enough memory");
        return;                     // default handler will exit not return
    }
    for (int i = 0; i < rb; ++i)    // mark all blocks as not in use
        mbd[i].flags = 0;
    rblocks = rb;
    bl = new cptr[rb];              // allocate an array of data block pointers
    if (!bl) goto allerr;           // check we got them
    for (i = 0; i < rb; ++i) {      // then allocate the actual data blocks
        bl[i] = new  char[elemsize*pb]; // and fill in pointers to them
        if (!bl[i]) goto allerr;    // checking the result as we go
    }
    fn = new char[strlen(fname)+1]; // allocate space for a copy of filename
    if (!fn) goto allerr;
    strcpy(fn,fname);               // remember the name for flush
    perblock = pb;
    es = elemsize;
    blocksize = perblock*es;        // work it out once, needed often
    nelems = ne;
    long nblocks = nelems/perblock+2;   //round up and allow for a tail mark
    if (create) {                   // new data file required
        char status = '\0';
        if ((fd = creat(fname,0)) == -1) {  
            vma_handler(ENOCREAT,"gvma - failed to create file");
            return;
        }
        for (long nb = 0; nb < nblocks; ++nb) {
            lseek(fd,nb*(blocksize+1),0);   // just write status marks
            if (write(fd,&status,1) != 1) { // a zero byte before each block
                vma_handler(EBADWRITE,"gvma - file write error");
                return;
            }
        }
        if (close(fd) == -1) {  // close the file, then reopen
            vma_handler(EFLUSHERR,"gvma - failed to flush file");
            return;
        }
        fd = open(fname,2); // to secure the file in its initialized state
    } else                  // otherwise just open it
        if ((fd = open(fname,2)) == -1) {
            vma_handler(ENOTOPEN,"gvma - failed to open file");
            return;
        }
    elem_init = ei;         // note the initialisation function
}

char *vma::access(long idx, int must_update)
{
    int free, i, t, oldest;
    for (free = -1, i = 0, t = 0; i < rblocks; ++i) { // scan resident blocks
        if (mbd[i].asu > t) {
            t = mbd[i].asu; // find least recently used block
            oldest = i;
        }
        if (!(mbd[i].flags & VM_INUSE)) {
            free = i;       // keep a note of an available block
            continue;
        }
        if (mbd[i].first_element <= idx  && idx < mbd[i].first_element+perblock)
            break;          // target element is in this block
    }
    if (i < rblocks) {      // element is already in memory
        age(i);             // age everything else
        if (must_update)    // will return a reference so may be altered
            mbd[i].flags |= VM_DIRTY;
        return bl[i]+es*(idx-mbd[i].first_element); // char* return value
    }
// required block is not in memory - need to read it from the disc
    if (free == -1) {       // there is no unused block
        free = oldest;
        if (mbd[free].flags & VM_DIRTY) // update file if it may be altered
            file_put(free,mbd[free].first_element);
    }
    if (!file_get(free,idx)) {  // now get the block we need - if file_get
        char *p;                // returns 0 then block has never been used
        for (p = bl[free], i = perblock; i--; p += es)
            (* elem_init)(p);   // do whatever specified to initialize it
        mbd[free].flags = VM_INUSE | VM_DIRTY;  // needs writing now
    }
    mbd[free].asu = 0;          // make it most recently used
    mbd[free].first_element = (idx/perblock)*perblock;
    mbd[free].flags = VM_INUSE + must_update; // fill in housekeeping info
    age(free);                  // and age the rest
    return bl[free]+es*(idx-mbd[free].first_element); //char* return
}

int vma::file_get(int block, long idx)
{
    char status;
    long offset = (blocksize+1)*(idx/perblock); // take account of status marks
    lseek(fd,offset,0);
    if (read(fd,&status,1) != 1) {
err1:
        vma_handler(EBADREAD,"gvma - file read error");
        return 0;
    }
    if (!status)           // block has never been used
        return 0;
    if (read(fd,(char *) bl[block],blocksize) != blocksize)
        goto err1;         // otherwise we actually read it
    return 1;
}

void vma::file_put(int block, long idx)
{
    char status = '\1';
    long offset = (blocksize+1)*(idx/perblock);
    lseek(fd,offset,0);
    if (write(fd,&status,1) != 1) {
err2:
        vma_handler(EBADWRITE,"gvma - file write error");
        return;
    }
    if (write(fd,(char *) bl[block],blocksize) != blocksize)
        goto err2;
    mbd[block].flags &= VM_INUSE;   // block not dirty any more
}

void vma::flush()      // update file and make safe
{
    for (int i = 0; i < rblocks; ++i)           // scan resident blocks
        if (mbd[i].flags & VM_DIRTY) {
            file_put(i,mbd[i].first_element);   // write dirty blocks
            mbd[i].flags &= VM_INUSE;           // now mark as clean
        }
    if (close(fd) == -1) goto err3;
    if ((fd = open(fn,2)) == -1) {
err3:
        vma_handler(EFLUSHERR,"gvma - failed to flush file");
    }
}

void vma::age(int n)
{
    for (int i = 0; i < rblocks; ++i)   // scan housekeeping blocks
        if (i != n)
            ++mbd[i].asu;   // increment the age of everything except n
}

PFC set_vma_handler(PFC handler)
{
    PFC loc = vma_handler;
    vma_handler = handler;
    return loc;
}
