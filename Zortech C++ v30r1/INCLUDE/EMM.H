/*_ emm.h   Thu Dec  6 1990 */
/* Expanded (LIM EMS) Memory Interface	*/

/* References:
 *	Lotus/Intel/Microsoft
 *	Expanded Memory Specification
 *	Version 4.0
 *	Available from Intel at 800-538-3373
 */

#ifndef __EMM_H
#define __EMM_H	1

#ifdef __cplusplus
	extern "C" {
#endif    

#define EMM_PAGESIZE	0x4000	/* 16K page size			*/

extern int _cdecl emm_inited;	/* != 0 if emm handler is initialized	*/

/********************************
 * Initialize EMM handler.
 * Returns:
 *	0	EMS installed and operating
 *	!=0	No EMS detected, or it isn't functioning properly
 */

int _cdecl emm_init(void);

/************************************
 * Get number of unallocated pages.
 * Use this function to determine how many pages available before
 * you attempt to allocate them with emm_allocpages().
 */

unsigned _cdecl emm_getunalloc(void);

/************************************
 * Get total number of pages in EMM system.
 */

unsigned _cdecl emm_gettotal(void);

/**********************************
 * Allocate pages.
 * It is a fatal error if there are no emm handles available.
 * Input:
 *	n	number of pages to allocate, 0 < n <= emm_getunalloc()
 * Returns:
 *	handle that refers to these pages
 */

int _cdecl emm_allocpages(unsigned);

/****************************
 * Map page from logical page to physical page.
 */

void _cdecl emm_maphandle(int handle,unsigned logical,unsigned physical);

/*****************************
 * Save the state of the page mapping registers associated with
 * the handle. The state is restored by emm_restorepagemap().
 * You cannot nest emm_savepagemap()/emm_restorepagemap() calls for
 * a single handle.
 * There is a limited number of handles that can be saved with this
 * function, fixed by the particular EMM handler. The application should
 * strive to never require more than 1. This function will abort the
 * program if there is no more handle space.
 */

void _cdecl emm_savepagemap(int handle);

void _cdecl emm_restorepagemap(int handle);

/********************************
 * Get physical page address of EMM frame page.
 * Input:
 *	pagenum		EMM page number (0..3)
 * Returns:
 *	pointer to base of that page
 *	NULL if error
 */

void far * _cdecl emm_physpage(int);

/********************************
 * Terminate use of EMM handler.
 */

void _cdecl emm_term(void);

/*******************************
 * Get all handles pages.
 * Input:
 *	*p	points to array to be filled in. The number of entries
 *		needed is returned by emm_gethandlecount();
 * Output:
 *	*p	data filled in
 * Returns:
 *	0	success
 *	!=0	error code
 */

struct emm_handle_s
{   int handle;		/* active handle				*/
    int pages;		/* number of pages alloc'd to that handle	*/
};

int _cdecl emm_gethandlespages(struct emm_handle_s *p);

/*******************************
 * Get number of active emm handles.
 * Returns:
 *	number of active handles
 */

int _cdecl emm_gethandlecount(void);

/****************************
 * Deallocate pages allocated for a handle by emm_allocpages().
 * The program needs to deallocate its handles before exiting the program,
 * else the pages will remain allocated and unavailable for use
 * by other programs.
 */

void _cdecl emm_deallocpages(int handle);

/****************************
 * Return version number of EMM.
 * Returns 0 if not initialized.
 * The number is in the form of 2 hex digits, the most significant
 * being the major version and the least the minor.
 * For example, 0x32 means version 3.2.
 */

int _cdecl emm_getversion(void);

/************************************
 * The following four functions allow a program to save and restore
 * the state of the EMM mapping registers. These are used in place
 * of emm_savepagemap() and emm_restorepagemap() when you don't
 * want to use a handle.
 */

/************************************
 * Get and return size in bytes of buffer needed by the functions
 * emm_getpagemap(), emm_setpagemap() and emm_getsetpagemap().
 */

unsigned _cdecl emm_getpagemapsize(void);

/*******************************
 * Write state of mapping registers into *dst.
 */

void _cdecl emm_getpagemap(void *dst);

/*******************************
 * Set state of mapping registers from values previously saved by
 * emm_getpagemap() into *src.
 */

void _cdecl emm_setpagemap(void *src);

/**********************************
 * Equivalent to:
 *	emm_getpagemap(dst);
 *	emm_setpagemap(src);
 */

void _cdecl emm_getsetpagemap(void *dst,void *src);

#ifdef __cplusplus
	}
#endif    

#endif /* __EMM_H	*/
