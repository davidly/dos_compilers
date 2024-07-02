/*_ mem.c   Fri Jan 26 1990   Modified by: Walter Bright */
/* Memory management package				*/

#include	<stdio.h>

#if __ZTC__
#include	<stdlib.h>
#include	<io.h>
#else
extern void *malloc();
extern void *calloc();
extern void *realloc();
#endif

#ifndef MEM_H
#include	"mem.h"
#endif

#ifndef assert
#include	<assert.h>
#endif

#if MSC
#include	<dos.h>
#endif

#ifndef VAX11C
#ifdef BSDUNIX
#include <strings.h>
#else
#include <string.h>
#endif
#else
extern char *strcpy(),*memcpy();
extern int strlen();
#endif  /* VAX11C */

int mem_inited = 0;		/* != 0 if initialized			*/

static int mem_behavior = MEM_ABORTMSG;
static int (*fp) P((void)) = NULL;	/* out-of-memory handler	*/
static int mem_count;		/* # of allocs that haven't been free'd	*/
static int mem_scount;		/* # of sallocs that haven't been free'd */

/* Determine where to send error messages	*/
#if MSDOS
#define ferr	stdout	/* stderr can't be redirected with MS-DOS	*/
#else
#define ferr	stderr
#endif

/*******************************/

void mem_setexception(flag,handler_fp)
#if __ZTC__ && __cplusplus
enum MEM_E flag;
#else
int flag;
#endif
int (*handler_fp) P((void));
{
    mem_behavior = flag;
    fp = (mem_behavior == MEM_CALLFP) ? handler_fp : 0;
#if MEM_DEBUG
    assert(0 <= flag && flag <= MEM_RETRY);
#endif
}

/*************************
 * This is called when we're out of memory.
 * Returns:
 *	1:	try again to allocate the memory
 *	0:	give up and return NULL
 */

static int near mem_exception()
{   int behavior;

    behavior = mem_behavior;
    while (1)
    {
	switch (behavior)
	{
	    case MEM_ABORTMSG:
#if MSDOS || __OS2__
		/* Avoid linking in buffered I/O */
	    {	static char msg[] = "Fatal error: out of memory\r\n";

		write(1,msg,sizeof(msg) - 1);
	    }
#else
		fputs("Fatal error: out of memory\n",ferr);
#endif
		/* FALL-THROUGH */
	    case MEM_ABORT:
		exit(EXIT_FAILURE);
		/* NOTREACHED */
	    case MEM_CALLFP:
		assert(fp);
		behavior = (*fp)();
		break;
	    case MEM_RETNULL:
		return 0;
	    case MEM_RETRY:
		return 1;
	    default:
		assert(0);
	}
    }
}

/****************************/

#if MEM_DEBUG

#undef mem_strdup

#if PROTOTYPING
char *mem_strdup(const char *s)
#else
char *mem_strdup(s)
const char *s;
#endif
{
	return mem_strdup_debug(s,__FILE__,__LINE__);
}

char *mem_strdup_debug(s,file,line)
char *file;
const char *s;
int line;
{
	char *p;

	p = s
	    ? (char *) mem_malloc_debug((unsigned) strlen(s) + 1,file,line)
	    : NULL;
	return p ? strcpy(p,s) : p;
}
#else
#if PROTOTYPING
char *mem_strdup(const char *s)
#else
char *mem_strdup(s)
const char *s;
#endif
{
	char *p;

	p = s ? (char *) mem_malloc((unsigned) strlen(s) + 1) : NULL;
	return p ? strcpy(p,s) : p;
}

#endif /* MEM_DEBUG */

#ifdef MEM_DEBUG

static long mem_maxalloc;	/* max # of bytes allocated		*/
static long mem_numalloc;	/* current # of bytes allocated		*/

#define BEFOREVAL	0x12345678	/* value to detect underrun	*/
#define AFTERVAL	0x87654321	/* value to detect overrun	*/

#if SUN || SUN386
static long afterval = AFTERVAL;	/* so we can do &afterval	*/
#endif

/* The following should be selected to give maximum probability that	*/
/* pointers loaded with these values will cause an obvious crash. On	*/
/* Unix machines, a large value will cause a segment fault.		*/
/* MALLOCVAL is the value to set malloc'd data to.			*/

#if MSDOS || __OS2__
#define BADVAL		0xFF
#define MALLOCVAL	0xEE
#else
#define BADVAL		0x7A
#define MALLOCVAL	0xEE
#endif

/* Disable mapping macros	*/
#undef	mem_malloc
#undef	mem_calloc
#undef	mem_realloc
#undef	mem_free

/* Create a list of all alloc'ed pointers, retaining info about where	*/
/* each alloc came from. This is a real memory and speed hog, but who	*/
/* cares when you've got obscure pointer bugs.				*/

static struct mem_debug
{	struct mh
	{ struct mem_debug *Mnext;	/* next in list			*/
	  struct mem_debug *Mprev;	/* previous value in list	*/
	  char *Mfile;		/* filename of where allocated		*/
	  int Mline;		/* line number of where allocated	*/
	  unsigned Mnbytes;	/* size of the allocation		*/
	  long Mbeforeval;	/* detect underrun of data		*/
	} m;
	char data[1];		/* the data actually allocated		*/
} mem_alloclist =
{
   {	(struct mem_debug *) NULL,
	(struct mem_debug *) NULL,
	"noname",
	11111,
	0,
	BEFOREVAL
   },
   AFTERVAL
};

/* Convert from a void *to a mem_debug struct.	*/
#define mem_ptrtodl(p)	((struct mem_debug *) ((char *)p - sizeof(struct mh)))

/* Convert from a mem_debug struct to a mem_ptr.	*/
#define mem_dltoptr(dl)	((void *) &((dl)->data[0]))

#define next		m.Mnext
#define prev		m.Mprev
#define file		m.Mfile
#define line		m.Mline
#define nbytes		m.Mnbytes
#define beforeval	m.Mbeforeval

/*****************************
 * Set new value of file,line
 */

void mem_setnewfileline(ptr,fil,lin)
void *ptr;
char *fil;
int lin;
{
    struct mem_debug *dl;

    dl = mem_ptrtodl(ptr);
    dl->file = fil;
    dl->line = lin;
}

/****************************
 * Print out struct mem_debug.
 */

static void near mem_printdl(dl)
struct mem_debug *dl;
{
	fprintf(ferr,"alloc'd from file '%s' line %d nbytes %d ptr x%lx\n",
		dl->file,dl->line,dl->nbytes,(long)mem_dltoptr(dl));
}

/****************************
 * Print out file and line number.
 */

static void near mem_fillin(fil,lin)
char *fil;
int lin;
{
	fprintf(ferr,"File '%s' line %d\n",fil,lin);
	fflush(ferr);
}

/****************************
 * If MEM_DEBUG is not on for some modules, these routines will get
 * called.
 */

void *mem_calloc(u)
unsigned u;
{
     	return mem_calloc_debug(u,__FILE__,__LINE__);
}

void *mem_malloc(u)
unsigned u;
{
     	return mem_malloc_debug(u,__FILE__,__LINE__);
}

void *mem_realloc(p,u)
void *p;
unsigned u;
{
     	return mem_realloc_debug(p,u,__FILE__,__LINE__);
}

void mem_free(p)
void *p;
{
	mem_free_debug(p,__FILE__,__LINE__);
}    


/**************************/

void mem_freefp(p)
void *p;
{
	mem_free(p);
}

/***********************
 * Debug versions of mem_calloc(), mem_free() and mem_realloc().
 */

void *mem_malloc_debug(n,fil,lin)
unsigned n;
char *fil;
int lin;
{   void *p;

    p = mem_calloc_debug(n,fil,lin);
    if (p)
	memset(p,MALLOCVAL,n);
    return p;
}

void *mem_calloc_debug(n,fil,lin)
unsigned n;
char *fil;
int lin;
{
    struct mem_debug *dl;

    do
	dl = (struct mem_debug *)
	    calloc(sizeof(*dl) + n + sizeof(AFTERVAL) - 1,1);
    while (dl == NULL && mem_exception());
    if (dl == NULL)
    {
#if 0
	printf("Insufficient memory for alloc of %d at ",n);
	mem_fillin(fil,lin);
	printf("Max allocated was: %ld\n",mem_maxalloc);
#endif
	return NULL;
    }
    dl->file = fil;
    dl->line = lin;
    dl->nbytes = n;
    dl->beforeval = BEFOREVAL;
#if SUN || SUN386 /* bus error if we store a long at an odd address */
    memcpy(&(dl->data[n]),&afterval,sizeof(AFTERVAL));
#else
    *(long *) &(dl->data[n]) = AFTERVAL;
#endif

    /* Add dl to start of allocation list	*/
    dl->next = mem_alloclist.next;
    dl->prev = &mem_alloclist;
    mem_alloclist.next = dl;
    if (dl->next != NULL)
	dl->next->prev = dl;

    mem_count++;
    mem_numalloc += n;
    if (mem_numalloc > mem_maxalloc)
	mem_maxalloc = mem_numalloc;
    return mem_dltoptr(dl);
}

void mem_free_debug(ptr,fil,lin)
void *ptr;
char *fil;
int lin;
{
	struct mem_debug *dl;

	if (ptr == NULL)
		return;
	if (mem_count <= 0)
	{	fprintf(ferr,"More frees than allocs at ");
		goto err;
	}
	dl = mem_ptrtodl(ptr);
	if (dl->beforeval != BEFOREVAL)
	{
		fprintf(ferr,"Pointer x%lx underrun\n",(long)ptr);
		goto err2;
	}
#if SUN || SUN386 /* Bus error if we read a long from an odd address	*/
	if (memcmp(&dl->data[dl->nbytes],&afterval,sizeof(AFTERVAL)) != 0)
#else
	if (*(long *) &dl->data[dl->nbytes] != AFTERVAL)
#endif
	{
		fprintf(ferr,"Pointer x%lx overrun\n",(long)ptr);
		goto err2;
	}
	mem_numalloc -= dl->nbytes;
	if (mem_numalloc < 0)
	{	fprintf(ferr,"error: mem_numalloc = %ld, dl->nbytes = %d\n",
			mem_numalloc,dl->nbytes);
		goto err2;
	}

	/* Remove dl from linked list	*/
	if (dl->prev)
		dl->prev->next = dl->next;
	if (dl->next)
		dl->next->prev = dl->prev;

	/* Stomp on the freed storage to help detect references	*/
	/* after the storage was freed.				*/
	memset((void *) dl,BADVAL,sizeof(*dl) + dl->nbytes);
	mem_count--;

	/* Some compilers can detect errors in the heap.	*/
#if DLC
	{	int i;
		i = free(dl);
		assert(i == 0);
	}
#else
	free((void *) dl);
#endif
	return;

err2:
	mem_printdl(dl);
err:
	fprintf(ferr,"free'd from ");
	mem_fillin(fil,lin);
	assert(0);
	/* NOTREACHED */
}

/*******************
 * Debug version of mem_realloc().
 */

void *mem_realloc_debug(oldp,n,fil,lin)
void *oldp;
unsigned n;
char *fil;
int lin;
{   void *p;
    struct mem_debug *dl;

    if (n == 0)
    {	mem_free_debug(oldp,fil,lin);
	p = NULL;
    }
    else if (oldp == NULL)
	p = mem_malloc_debug(n,fil,lin);
    else
    {
	p = mem_malloc_debug(n,fil,lin);
	if (p != NULL)
	{
	    dl = mem_ptrtodl(oldp);
	    if (dl->nbytes < n)
		n = dl->nbytes;
	    memcpy(p,oldp,n);
	    mem_free_debug(oldp,fil,lin);
	}
    }
    return p;
}

/***************************/

void mem_check()
{   register struct mem_debug *dl;

    for (dl = mem_alloclist.next; dl != NULL; dl = dl->next)
	mem_checkptr(mem_dltoptr(dl));
}

/***************************/

void mem_checkptr(p)
register void *p;
{   register struct mem_debug *dl;

    for (dl = mem_alloclist.next; dl != NULL; dl = dl->next)
    {
	if (p >= (void *) &(dl->data[0]) &&
	    p < (void *)((char *)dl + sizeof(struct mem_debug)-1 + dl->nbytes))
	    goto L1;
    }
    assert(0);

L1:
    dl = mem_ptrtodl(p);
    if (dl->beforeval != BEFOREVAL)
    {
	    fprintf(ferr,"Pointer x%lx underrun\n",(long)p);
	    goto err2;
    }
#if SUN || SUN386 /* Bus error if we read a long from an odd address	*/
    if (memcmp(&dl->data[dl->nbytes],&afterval,sizeof(AFTERVAL)) != 0)
#else
    if (*(long *) &dl->data[dl->nbytes] != AFTERVAL)
#endif
    {
	    fprintf(ferr,"Pointer x%lx overrun\n",(long)p);
	    goto err2;
    }
    return;

err2:
    mem_printdl(dl);
    assert(0);
}

#else

/***************************/

void *mem_malloc(numbytes)
unsigned numbytes;
{	void *p;

	if (numbytes == 0)
		return NULL;
	while (1)
	{
		p = malloc(numbytes);
		if (p == NULL)
		{	if (mem_exception())
				continue;
		}
		else
			mem_count++;
		break;
	}
	/*printf("malloc(%d) = x%lx\n",numbytes,p);*/
	return p;
}

/***************************/

void *mem_calloc(numbytes)
unsigned numbytes;
{	void *p;

	if (numbytes == 0)
		return NULL;
	while (1)
	{
		p = calloc(numbytes,1);
		if (p == NULL)
		{	if (mem_exception())
				continue;
		}
		else
			mem_count++;
		break;
	}
	/*printf("calloc(%d) = x%lx\n",numbytes,p);*/
	return p;
}

/***************************/

void *mem_realloc(oldmem_ptr,newnumbytes)
void *oldmem_ptr;
unsigned newnumbytes;
{   void *p;

    if (oldmem_ptr == NULL)
	p = mem_malloc(newnumbytes);
    else if (newnumbytes == 0)
    {	mem_free(oldmem_ptr);
	p = NULL;
    }
    else
    {
	do
	    p = realloc(oldmem_ptr,newnumbytes);
	while (p == NULL && mem_exception());
    }
    /*printf("realloc(x%lx,%d) = x%lx\n",oldmem_ptr,newnumbytes,p);*/
    return p;
}

/***************************/

void mem_free(ptr)
void *ptr;
{
    /*printf("free(x%lx)\n",ptr);*/
    if (ptr != NULL)
    {	assert(mem_count != 0);
	mem_count--;
#if DLC
	{	int i;

		i = free(ptr);
		assert(i == 0);
	}
#else
	free(ptr);
#endif
    }
}

#if __ZTC__

/* Minimum size of a free block	*/
#define MINBLKSIZE	(sizeof(size_t) + sizeof(void *))
/* Boundary that allocations are aligned on	*/
#define ALIGNSIZE	(sizeof(size_t))

/*****************************/

void *mem_scalloc(numbytes)
size_t numbytes;
{   size_t *p;

    if (numbytes == 0)
	return NULL;
    if (numbytes < MINBLKSIZE)
	numbytes = MINBLKSIZE;
    else
	numbytes = (numbytes + (ALIGNSIZE - 1)) & ~(ALIGNSIZE - 1);
    p = (size_t *) mem_calloc(numbytes - sizeof(size_t));
    if (p)
    {
	p--;
	*p = 0;
	mem_count--;
	mem_scount++;
    }
    return p;
}

/*****************************/

void mem_sfree(ptr,numbytes)
void *ptr;
size_t numbytes;
{
    if (ptr != NULL)
    {	assert(mem_scount > 0);
	mem_scount--;
	if (numbytes < MINBLKSIZE)
	    numbytes = MINBLKSIZE;
	else
	    numbytes = (numbytes + (ALIGNSIZE - 1)) & ~(ALIGNSIZE - 1);
	*((size_t *)ptr)++ = numbytes;	/* store size of free block	*/
	free(ptr);
    }
}

#endif /* __ZTC__ */

#endif

/***************************/

void mem_init()
{
	if (mem_inited == 0)
	{	mem_count = 0;
#if MEM_DEBUG
		mem_numalloc = 0;
		mem_maxalloc = 0;
		mem_alloclist.next = NULL;
#endif
#if __ZTC__
		/* Necessary if mem_sfree() calls free() before any	*/
		/* calls to malloc().					*/
		free(malloc(1));	/* initialize storage allocator	*/
#endif
		mem_inited++;
	}
}

/***************************/

void mem_term()
{

	if (mem_inited)
	{
#if MEM_DEBUG
		register struct mem_debug *dl;

		for (dl = mem_alloclist.next; dl; dl = dl->next)
		{	fprintf(ferr,"Unfreed pointer: ");
			mem_printdl(dl);
		}
#if 0
		fprintf(ferr,"Max amount ever allocated == %ld bytes\n",
			mem_maxalloc);
#endif
#else
		if (mem_count)
			fprintf(ferr,"%d unfreed items\n",mem_count);
		if (mem_scount)
			fprintf(ferr,"%d unfreed s items\n",mem_scount);
#endif /* MEM_DEBUG */
		assert(mem_count == 0 && mem_scount == 0);
		mem_inited = 0;
	}
}

#undef next
#undef prev
#undef file
#undef line
#undef nbytes
#undef beforeval

