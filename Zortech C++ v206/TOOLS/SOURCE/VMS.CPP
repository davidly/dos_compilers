#include <io.h>
#include <vms.hpp>

typedef void (* PFC)(int, char*);
extern void default_error(int, char*);  // modifiable error handler
PFC vms_handler = default_error;

vms::vms(long max, unsigned ri, unsigned iw,
              char *fname, int create, void (*ei)(void*), unsigned elemsize)
{
    char filen[13];
    elem_init = ei;
    table = new pindex[iw];         // allocate memory for index chain pointers
    if (!table) {
allerr:
        vms_handler(ENOMEM,"gvms - not enough memory");
        return;
    }
    memset(table,'\0',iw*sizeof(void*));    // and initiaize them to NULL
    tabsize = iw;
    es = elemsize;
    empty = new char[es];
    if (!empty) goto allerr;        // allocate a copy of an initialized
    elem_init(empty);               // element
    rp = new residence_ptr[ri];     // make array of pointers to resident
    if (!rp) goto allerr;           // blocks
    for (int i = 0; i < ri; ++i) {  // for each resident item
        rp[i] = (residence *) new char[sizeof(residence)+elemsize-1];
        rp[i]->flags = 0;            // set the flags - not in use
    }
    freeblocks = ri-1;              // note how may free block there are
    ritems = ri;
    fn = new char[strlen(fname)+1]; // allocate store for file system name
    if (!fn) goto allerr;
    strcpy(fn,fname);               // and copy the name in
    nmax = max;
    if (create) {                   // file needs creating
        strcpy(filen,fn);
        strcat(filen,".dta");
        if ((fp = fopen(filen,"w+b")) == NULL) {
err1:
            vms_handler(ENOCREAT,"gvms - could not create file");
            return;
        }
        ccount = 0L;                // initialize file item count
    } else {                        // filesystem exists - read the index
        strcpy(filen,fn);           // construct an appropriate filename
        strcat(filen,".idx");
        if ((fp = fopen(filen,"rb")) == NULL) {  // get index into memory
            vms_handler(ENOTOPENI,"gvms - failed to open index file");
            return;
        }                           // open the index file
        ccount = 0L;
        for (;;) {                  // for each chain
            unsigned n,i;
            pindex p;
            if (fread(&n,sizeof(unsigned),1,fp) != 1)
                break;              // get the number of items in the chain
            ccount += n;            // count entries in file system
            for (i = n; i--;) {     // then read and fill in each of them
                p = new indexitem;
                if (!p) goto allerr;
                if (fread(&p->logical,sizeof(long),2,fp) != 2) {
                    vms_handler(EBADREADI,"gvms - index bad read");
                    return;
                }
                insert(p);
            }
        }
        fclose(fp);                 // done with index file
        strcpy(filen,fn);           // make the data file name
        strcat(filen,".dta");
        if ((fp = fopen(filen,"r+b")) == NULL) {
            vms_handler(ENOTOPEN,"gvms - failed to open data file");
            return;                 // and open it for business
        }
    }
}

// Insert puts an entry into the index.  An index chain is chosen simply by
// taking the modulus of the index number, and the entry is added to the
// corresponding list.

void vms::insert(pindex p)
{
    unsigned hv;
    pindex np;
    hv = p->logical%tabsize;        // select the required chain
    if (table[hv]) {                // anything in it?
        np = table[hv];
        for (;;) {
            if (p->logical == np->logical)
                return;             // it is already there
            if (!np->next)
                break;              // at end of chain
            np = np->next;          // otherwise step on to next
        }
        np->next = p;               // fill in the new entry
        p->next = NULL;             // and mark as end of chain
    } else {
        table[hv] = p;              // first item in this chain
        p->next = NULL;             // mark as end
    }
    return;
}

pindex vms::lookup(long t)
{
    unsigned hv;
    pindex np;    

    hv = t%tabsize;                 // select the required chain
    np = table[hv];
    for (; np; np = np->next) {
        if (np->logical == t)       // step along until found or end of chain
            return(np);             // found - return a pointer to it
    }
    return(NULL);                   // end of chain - item not present
}

void vms::cleanup()
{
    int i;
    pindex p, q;

    for (i = 0; i < tabsize; ++i) {
        p = table[i];
        for (p = table[i]; p; p = q) {
            q = p->next;            // eat up each chain
            delete p;
        }
    }
    delete table;                   // then delete the chain pointers
}

void vms::reindex()
{
    char filen[13];
    FILE *f;
    unsigned off;
    pindex p;
    strcpy(filen,fn);           // make the index filename
    strcat(filen,".idx");
    if ((f = fopen(filen,"w")) == NULL) {
        vms_handler(ENOTOPENI,"gvms - could not open index file");
        return;                 // create a new file for index
    }
    for (unsigned n, j, i = 0; i < tabsize; ++i) {  // for each chain
        for (n = 0, p = table[i]; p; p = p->next)
            ++n;                // count the items in the chain
        if (fwrite(&n,sizeof(unsigned),1,f) != 1)
            goto err2;          // write the number of items
        for (p = table[i], j = n; j--; p = p->next) // hop along the chain
            if (fwrite(&p->logical,sizeof(long),2,f) != 2)
                goto err2;      // writing each item
    }
    if (fclose(f)) {      // close index file
err2:
        vms_handler(EWINDEX,"gvms - error writing index file");
    }
}

char *vms::access(long idx, int must_update)
{
    int free;
    if (idx < 0L || idx >= nmax) {  // requested index in range?
        vms_handler(EOUTBOUND,"gvms - index out of bounds");
        return NULL;
    }
    pindex p;
    if ((p = lookup(idx)) != NULL) {  // if found element != to initial value
        if (p->slot != -1) {    // if pslot > -1 it is in memory
            age(p->slot);       // age everything else
            if (must_update)    // mark dirty if its a reference access
                rp[p->slot]->flags |= VM_DIRTY;
            return &rp[p->slot]->it;    // return a pointer to the data
        }
    } else if (!must_update)    // value only required, and this element
        return empty;           // in initial state
    // element has never been modified so
    // one way or the other we now need a resident block to fill in from
    // the data file or initialize
    if (freeblocks < 0) {      // there is no unused block
        for (int j = 0, i = 0; i < ritems; ++i) 
            if (rp[i]->asu > j) {
                j = rp[i]->asu;  // find least recently used block
                free = i;
            }
        pindex q;
    // anything which is in a memory slot should be in the index - check
        if ((q = lookup(rp[free]->ind)) == NULL) {
            vms_handler(EINCONST,"gvms - index inconsistent with data");
            return NULL;
        }
        q->slot = -1;           // mark it as no longer in memory
        if (rp[free]->flags & VM_DIRTY) // update file if neccessary
            file_put(free,q);   // if dirty write it to file
    } else 
        free = freeblocks--;    // another free block used up
    if (!p) {                   // the element has never been accessed
        (* elem_init)(&rp[free]->it);   // initialize the block
        rp[free]->ind = idx;    // and fill in
        pindex si;
        si = new indexitem(idx,ccount*(es+sizeof(long)),free);
        if (!si) {
            vms_handler(ENOMEM,"gvms - not enough memory");
            return NULL;
        }
        ++ccount;
        insert(si);
    } else {
        file_get(free,p);
        p->slot = free;
    }
    rp[free]->asu = 0;      // and make it most recently used
    rp[free]->flags = VM_INUSE + must_update; // fill in housekeeping info
    age(free);              // and age the rest
    return(&rp[free]->it);
}

void vms::file_get(int free, pindex p)
{
    if (fseek(fp,p->actual,SEEK_SET))
        goto err3;
    if (fread(&rp[free]->ind,sizeof(long)+es,1,fp) != 1) {
err3:
        vms_handler(EBADREAD,"gvms - file read failed");
    }
}

void vms::file_put(int old, pindex p)
{
    if (fseek(fp,p->actual,SEEK_SET))
        goto err4;
    if (fwrite(&rp[old]->ind,sizeof(long)+es,1,fp) != 1) 
err4:
        vms_handler(EBADWRITE,"gvms - file write failed");
}

void vms::flush()      // update file and make safe
{
    char filen[13];
    for (int i = 0; i < ritems; ++i)
        if (rp[i]->flags & VM_DIRTY) {
            pindex p = lookup(rp[i]->ind);
            if (!p) {
                vms_handler(EINCONST,"gvms - index inconsistent with data");
                return;
            }
            file_put(i,p); // write dirty blocks
            rp[i]->flags = VM_INUSE;            // now mark as clean
        }
    if (fflush(fp)) {
        vms_handler(EFLUSHERR,"gvms - failed to flush file");
        return;
    }
    reindex();
}

void vms::age(int n)
{
    for (int i = 0; i < ritems; ++i)
        if (i != n)
            ++rp[i]->asu;   // increment the age of everything except n
}

PFC set_vms_handler(PFC handler)
{
    PFC loc = vms_handler;
    vms_handler = handler;
    return loc;
}
