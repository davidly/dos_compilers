/*_ mem.h   Fri May 26 1989   Modified by: Walter Bright */
/* Copyright 1986-1991 by Walter Bright		*/
/* All Rights Reserved				*/
/* Written by Walter Bright			*/

#ifndef MEM_H
#define MEM_H	1

#ifndef P
#include	"toolkit.h"
#endif

/*
 * Memory management routines.
 *
 * Compiling:
 *
 *	#define MEM_DEBUG 1 when compiling to enable extended debugging
 *	features.
 *
 * Features always enabled:
 *
 *	o mem_init() is called at startup, and mem_term() at
 *	  close, which checks to see that the number of alloc's is
 *	  the same as the number of free's.
 *	o Behavior on out-of-memory conditions can be controlled
 *	  via mem_setexception().
 *
 * Extended debugging features:
 *
 *	o Enabled by #define MEM_DEBUG 1 when compiling.
 *	o Check values are inserted before and after the alloc'ed data
 *	  to detect pointer underruns and overruns.
 *	o Free'd pointers are checked against alloc'ed pointers.
 *	o Free'd storage is cleared to smoke out references to free'd data.
 *	o Realloc'd pointers are always changed, and the previous storage
 *	  is cleared, to detect erroneous dependencies on the previous
 *	  pointer.
 *	o The routine mem_checkptr() is provided to check an alloc'ed
 *	  pointer.
 */

/********************* GLOBAL VARIABLES *************************/

extern int mem_inited;		/* != 0 if mem package is initialized.	*/
				/* Test this if you have other packages	*/
				/* that depend on mem being initialized	*/

/********************* PUBLIC FUNCTIONS *************************/

/***********************************
 * Set behavior when mem runs out of memory.
 * Input:
 *	flag =	MEM_ABORTMSG:	Abort the program with the message
 *				'Fatal error: out of memory' sent
 *				to stdout. This is the default behavior.
 *		MEM_ABORT:	Abort the program with no message.
 *		MEM_RETNULL:	Return NULL back to caller.
 *		MEM_CALLFP:	Call application-specified function.
 *				fp must be supplied.
 *	fp			Optional function pointer. Supplied if
 *				(flag == MEM_CALLFP). This function returns
 *				MEM_XXXXX, indicating what mem should do next.
 *				The function could do things like swap
 *				data out to disk to free up more memory.
 *	fp could also return:
 *		MEM_RETRY:	Try again to allocate the space. Be
 *				careful not to go into an infinite loop.
 */

#if __ZTC__
enum MEM_E { MEM_ABORTMSG, MEM_ABORT, MEM_RETNULL, MEM_CALLFP, MEM_RETRY };
void mem_setexception P((enum MEM_E,...));
#else
#define MEM_ABORTMSG	0
#define MEM_ABORT	1
#define MEM_RETNULL	2
#define MEM_CALLFP	3
#define MEM_RETRY	4
void mem_setexception P((int,...));
#endif


/****************************
 * Allocate space for string, copy string into it, and
 * return pointer to the new string.
 * This routine doesn't really belong here, but it is used so often
 * that I gave up and put it here.
 * Use:
 *	char *mem_strdup(const char *s);
 * Returns:
 *	pointer to copied string if succussful.
 *	else returns NULL (if MEM_RETNULL)
 */

char *mem_strdup P((const char *));

/**************************
 * Function so we can have a pointer to function mem_free().
 * This is needed since mem_free is sometimes defined as a macro,
 * and then the preprocessor screws up.
 * The pointer to mem_free() is used frequently with the list package.
 * Use:
 *	void mem_freefp(void *p);
 */

/***************************
 * Check for errors. This routine does a consistency check on the
 * storage allocator, looking for corrupted data. It should be called
 * when the application has CPU cycles to burn.
 * Use:
 *	void mem_check(void);
 */

void mem_check P((void ));

/***************************
 * Check ptr to see if it is in the range of allocated data.
 * Cause assertion failure if it isn't.
 */

void mem_checkptr P((void *ptr));

/***************************
 * Allocate and return a pointer to numbytes of storage.
 * Use:
 *	void *mem_malloc(unsigned numbytes);
 *	void *mem_calloc(unsigned numbytes); allocated memory is cleared
 * Input:
 *	numbytes	Number of bytes to allocate
 * Returns:
 *	if (numbytes > 0)
 *		pointer to allocated data, NULL if out of memory
 *	else
 *		return NULL
 */

void *mem_malloc P((unsigned));
void *mem_calloc P((unsigned));

/*****************************
 * Reallocate memory.
 * Use:
 *	void *mem_realloc(void *ptr,unsigned numbytes);
 */

void *mem_realloc P((void *,unsigned));

/*****************************
 * Free memory allocated by mem_malloc(), mem_calloc() or mem_realloc().
 * Use:
 *	void mem_free(void *ptr);
 */

void mem_free P((void *));

/***************************
 * Initialize memory handler.
 * Use:
 *	void mem_init(void);
 * Output:
 *	mem_inited = 1
 */

void mem_init P((void ));

/***************************
 * Terminate memory handler. Useful for checking for errors.
 * Use:
 *	void mem_term(void);
 * Output:
 *	mem_inited = 0
 */

void mem_term P((void ));

/*******************************
 * Allocate memory and clear it.
 * This routine is special in that no overhead is kept for what
 * the size of the allocated block is. Thus, the application needs
 * too keep track of that. Free only with mem_sfree().
 */

#if MEM_DEBUG || !__ZTC__
#define mem_scalloc mem_calloc
#else
void *mem_scalloc P((size_t numbytes));
#endif

/*******************************
 * Free memory allocated with mem_scalloc().
 * Input:
 *	ptr	value returned by mem_scalloc().
 *	numbytes	size (must be same value as passed to mem_scalloc())
 */

#if MEM_DEBUG || !__ZTC__
#define mem_sfree(ptr,size) mem_free(ptr)
#else
void mem_sfree P((void *ptr, size_t numbytes));
#endif

/* The following stuff forms the implementation rather than the
 * definition, so ignore it.
 */

#if MEM_DEBUG		/* if creating debug version	*/
#define mem_strdup(p)	mem_strdup_debug((p),__FILE__,__LINE__)
#define mem_malloc(u)	mem_malloc_debug((u),__FILE__,__LINE__)
#define mem_calloc(u)	mem_calloc_debug((u),__FILE__,__LINE__)
#define mem_realloc(p,u)	mem_realloc_debug((p),(u),__FILE__,__LINE__)
#define mem_free(p)	mem_free_debug((p),__FILE__,__LINE__)

char *mem_strdup_debug	P((const char *,char *,int));
void *mem_calloc_debug	P((unsigned,char *,int));
void *mem_malloc_debug	P((unsigned,char *,int));
void *mem_realloc_debug P((void *,unsigned,char *,int));
void  mem_free_debug	P((void *,char *,int));
void  mem_freefp	P((void *));

void mem_setnewfileline P((void *,char *,int));

#else

#define mem_freefp	mem_free
#define mem_check()
#define mem_checkptr(p)

#endif /* MEM_DEBUG */

#endif /* MEM_H */
