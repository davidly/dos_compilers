/*_ page.h   Mon May  1 1989   Modified by: Walter Bright */

#ifndef __PAGE_H
#define __PAGE_H	1

#define PAGEOVERHEAD	10

/*****************************************
 * Allocate a block of data and clear it.
 * Use:
 *	unsigned page_calloc(void far *baseptr,unsigned size);
 * Returns:
 *	offset of allocated data else 0
 */

unsigned cdecl page_calloc(void far *baseptr,unsigned size);

/*****************************************
 * Allocate a block of data.
 *	unsigned page_malloc(void far *baseptr,unsigned size);
 * Returns:
 *	offset of allocated data else 0
 */

unsigned cdecl page_malloc(void far *baseptr,unsigned size);

/*****************************************
 * Reallocate memory that was allocated by page_malloc() or page_calloc().
 * Use:
 *	unsigned page_realloc(void far *baseptr,unsigned p, unsigned nbytes)
 * Returns:
 *	0 error
 *	else offset of reallocated memory
 */

unsigned cdecl page_realloc(void far *baseptr,unsigned p, unsigned nbytes);

/*****************************************
 * Free memory that was allocated by page_malloc() or page_calloc().
 * Use:
 *	int page_free(void far *baseptr,unsigned p);
 * Returns:
 *	0	success
 *	-1	error (baseptr is bad, or memory is corrupted)
 */

int cdecl page_free(void far *baseptr,unsigned p);

/*****************************************
 * Determine size of largest free block in page.
 *	unsigned page_maxfree(void far *baseptr);
 */

unsigned cdecl page_maxfree(void far *baseptr);

/*****************************************
 * Initialize memory allocation system in a page.
 *	unsigned page_initialize(void far *baseptr,unsigned pagesize);
 * Returns:
 *	size of largest allocatable block
 */

unsigned cdecl page_initialize(void far *baseptr,unsigned pagesize);

/*****************************************
 * Return number of bytes allocated for chunk of memory that was
 * allocated by page_malloc, page_calloc or page_realloc.
 */

/*unsigned cdecl page_size(void far *baseptr,unsigned p);*/

#define page_size(baseptr,p) \
	(*(unsigned short far *)((char far *)(baseptr) + (p) - 2) - 2)

/****************************************
 * Convert pointer to page and offset into that page into a void * pointer.
 */

/*void far * near page_toptr(void far *baseptr,unsigned p);*/

#define page_toptr(baseptr,p)	(void far *)((char far *)(baseptr) + (p))

#endif /* __PAGE_H */
