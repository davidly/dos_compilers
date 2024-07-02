/*_ vbuf.c   Tue Sep 12 1989   Modified by: Walter Bright */
/* Copyright (C) 1987-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Virtual buffered memory				*/

#include	<stdio.h>
#include	<string.h>
#ifdef __ZTC__
#include	<stdlib.h>
#include	<io.h>
#else
extern char* getenv();
#endif
#include	"vbuf.h"
#include	"mem.h"

#ifndef assert
#include	<assert.h>

/*****************************
 * Define a local assert function.
 */

#undef assert
#define assert(e)	((e) || local_assert(__LINE__))
static void near local_assert(line)
int line;
{
    _assert("",__FILE__,line);
}

#endif

#define VFinmemory	1	/* 1 if buffer exists in memory	*/
#define VFondisk	2	/* 1 if buffer exists on disk	*/
#define VFdirty		4	/* 1 if disk buffer is obsolete	*/

#define vbuf_inmemory(vb_h)	((vb_h)->flags & VFinmemory)

int vbuf_inited = 0;		/* != 0 if initialized			*/

static struct VBUF_S freehead =	 /* head of list of available buffers	*/
{	&freehead,&freehead,
};
static struct VBUF_S inusehead = /* list of in use buffers		*/
{	&inusehead,&inusehead,
};

static char* vm_tmp;
static int vm_fd = -1;			/* file descriptor for vm.tmp	*/
static unsigned long vm_size = 0L;	/* size of vm file		*/

#define vblist_append(dl,v) \
	((v)->next = (dl)->next), \
	((v)->prev = (dl)), \
	((dl)->next = (v)), \
	((v)->next->prev = (v))

#define vblist_prepend(dl,v) \
	((v)->next = (dl)), \
	((v)->prev = (dl)->prev), \
	((dl)->prev = (v)), \
	((v)->prev->next = (v))

#define vblist_remove(v) \
	(((v)->prev->next = (v)->next), \
	((v)->next->prev = (v)->prev))

/************************* LOCAL FUNCTIONS ***********************/

/****************************
 * Open vm.
 */

static void vm_open()
{
	vm_fd = creat(vm_tmp,0600);
	if (vm_fd == -1)		/* open failure			*/
	{
		printf("Error: can't open %s\n",vm_tmp);
		exit(EXIT_FAILURE);
	}
	else
		printf("Opening %s\n",vm_tmp);
}

/*****************************
 * Allocate a disk buffer for the vb_h.
 */

static void getdiskbuffer(vb_h)
vbuf_handle_t vb_h;
{
    if (freehead.next != &freehead)	/* if available disk buffer	*/
    {	vbuf_handle_t v = freehead.next;

	vb_h->fd = v->fd;
	vb_h->offset = v->offset;
	vblist_remove(v);
	mem_free(v);	    
    }
    else				/* extend VM.TMP file		*/
    {
	if (vm_fd == -1)
	    vm_open();			/* create VM.TMP		*/
	vb_h->fd = vm_fd;
	vb_h->offset = vm_size;
	vm_size += VBUF_SIZE;
    }
    vb_h->flags |= VFondisk | VFdirty;
}

/**************************
 * Boot this vb out of memory, and free up the memory buffer.
 */

static void bootout(vb_h)
vbuf_handle_t vb_h;
{   int result;

    if (vb_h->flags & VFdirty)
    {
	if (!(vb_h->flags & VFondisk))
	    getdiskbuffer(vb_h);
	if (lseek(vb_h->fd,vb_h->offset,0) == -1L)
	{
	    perror(vm_tmp);
	    vbuf_term();
	    exit(EXIT_FAILURE);
	}
	/*printf("write: fd = %d, offset = x%lx\n",vb_h->fd,vb_h->offset);*/
	result = write(vb_h->fd,vb_h->memory,VBUF_SIZE);
	if (result != VBUF_SIZE)
	{   if (result < 0)
		perror(vm_tmp);
	    else
		fprintf(stderr,"%s: drive is full\n",vm_tmp);
	    vbuf_term();
	    exit(EXIT_FAILURE);
	}
	vb_h->flags &= ~VFdirty;
    }
    mem_free(vb_h->memory);		/* free memory buffer		*/
    vb_h->memory = NULL;
    vb_h->flags &= ~VFinmemory;		/* no longer in memory		*/
}

/*************************
 * Read buffer back from disk.
 */

static void readback(vb_h)
vbuf_handle_t vb_h;
{
    vb_h->memory = mem_malloc(VBUF_SIZE);
    vb_h->flags |= VFinmemory;
    if (lseek(vb_h->fd,vb_h->offset,0) == -1L)
    {
	perror(vm_tmp);
	vbuf_term();
	exit(EXIT_FAILURE);
    }
    /*printf("read : fd = %d, offset = x%lx\n",vb_h->fd,vb_h->offset);*/
    if (read(vb_h->fd,vb_h->memory,VBUF_SIZE) == 0)
    {
	perror(vm_tmp);
	vbuf_term();
	exit(EXIT_FAILURE);
    }
}

/************************* PUBLIC FUNCTIONS ***********************/

/***********************
 * Initialize for virtual buffers.
 */

void vbuf_init()
{
    char* sTmp;
    char* s;

    if (vbuf_inited == 0)
    {
	assert(mem_inited);
	/* Set handler to call when out of memory	*/
	mem_setexception(MEM_CALLFP,vbuf_needmemory);
	sTmp = getenv("TMP");
	if( sTmp == NULL )
	    sTmp = getenv("TEMP");
	if( sTmp == NULL )
	    sTmp = "";
	s = tempnam(sTmp,"ztc_");
	vm_tmp = mem_strdup(s ? s : "VM.TMP");
	free(s);

	vbuf_inited++;
    }
}

/***********************
 * Terminate vbuf handler.
 */

void vbuf_term()
{
    /*printf("vbuf_term()\n");*/
    if (vbuf_inited)
    {	vbuf_handle_t vb_h;

	if (vm_fd != -1)
	{	close(vm_fd);
		unlink(vm_tmp);
	}
#if TERMCODE
	mem_free( vm_tmp );
	while (freehead.next != &freehead)
	{	vb_h = freehead.next;
		freehead.next = vb_h->next;
		mem_free(vb_h);
	}
#endif
	vbuf_inited = 0;
    }
}

/****************************
 * Allocate a new vbuf, clear it, and return a pointer to it.
 * Returns 0 if can't allocate one.
 */

vbuf_handle_t vbuf_calloc()
{   vbuf_handle_t vb_h;

    assert(vbuf_inited);
    vb_h = (vbuf_handle_t) mem_calloc(sizeof(*vb_h));
    if (vb_h)
    {
	vb_h->memory = mem_calloc(VBUF_SIZE);
	if (vb_h->memory == NULL)
	{   mem_free(vb_h);
	    vb_h = NULL;
	}
	else
	{   vb_h->flags |= VFdirty | VFinmemory;
	    vblist_prepend(inusehead.next,vb_h);
	}
    }
    /*printf("vbuf_calloc = %p\n",vb_h);*/
    return vb_h;
}

/***************************/

vbuf_handle_t vbuf_filepage(fd,offset)
int fd;
unsigned long offset;
{   vbuf_handle_t vb_h;

    assert(vbuf_inited);
    vb_h = (vbuf_handle_t)mem_calloc(sizeof(struct VBUF_S));
    if (vb_h)
    {
	vb_h->flags |= VFondisk;
	vb_h->fd = fd;
	vb_h->offset = offset;
	vblist_prepend(inusehead.next,vb_h);
    }
    /*printf("vbuf_filepage(fd=%d, offset=x%lx) = %p\n",fd,offset,vb_h);*/
    return vb_h;
}

/***************************
 * Free up a vbuf.
 */

void vbuf_free(vb_h)
vbuf_handle_t vb_h;
{
    /*printf("vbuf_free(%p)\n",vb_h);*/
    if (vb_h->flags & VFinmemory)
    {	mem_free(vb_h->memory);
	vb_h->memory = NULL;
	vb_h->flags &= ~VFinmemory;
    }
    vblist_remove(vb_h);
    if (vb_h->flags & VFondisk && vb_h->fd == vm_fd)
	vblist_append(&freehead,vb_h);
    else
	mem_free(vb_h);
}

/****************************
 * Mark vbuf as being modified.
 */

#ifndef vbuf_dirty	/* if not already a macro	*/
void vbuf_dirty(vb_h)
vbuf_handle_t vb_h;
{
    vb_h->flags |= VFdirty;
}
#endif

/****************************
 * Return a pointer to real memory associated with the handle.
 * The pointer remains valid until the next call to vbuf_xxxx().
 */

vbuf_ptr_t pascal _vbuf_access(vb_h)
vbuf_handle_t vb_h;
{
    if (!(vb_h->flags & VFinmemory))
    {	readback(vb_h);
	assert(vbuf_inmemory(vb_h));
    }

    /* Move vb_h to front of inuse list	*/
    if (vb_h != inusehead.next)
    {	vblist_remove(vb_h);
	vblist_append(&inusehead,vb_h);
    }

    return vb_h->memory;
}

/****************************
 * Lock a vbuf in memory.
 */

void vbuf_lock(vb_h)
vbuf_handle_t vb_h;
{
    assert(vbuf_inmemory(vb_h) && vb_h->count >= 0);
    vb_h->count++;
}

/****************************
 * Unlock a vbuf from memory.
 */

void vbuf_unlock(vb_h)
vbuf_handle_t vb_h;
{
    assert(vbuf_inmemory(vb_h) && vb_h->count > 0);
    vb_h->count--;
    assert( vb_h->count >= 0 );
}

/*****************************
 * mem_xxxx() calls this when they run out of memory.
 */

int vbuf_needmemory()
{   static char inuse = 0;
    int result;
    vbuf_handle_t vb_h;

    assert(vbuf_inited);
    assert(inuse == 0);
    inuse++;			/* make sure that we don't double-fault	*/
    for (vb_h = inusehead.prev; vb_h != &inusehead; vb_h = vb_h->prev)
    {
	if (vb_h->flags & VFinmemory && !vb_h->count)
	{   bootout(vb_h);
	    result = MEM_RETRY;
	    goto ret;
	}
    }
    if (vm_fd != -1)			/* if VM.TMP file exists	*/
    {	close(vm_fd);
	unlink(vm_tmp);			/* delete it			*/
    }
    result = MEM_ABORTMSG;		/* out of memory, give up	*/

ret:
    inuse--;
    return result;
}
