/*_ page.h   Mon May  1 1989   Modified by: Walter Bright */

#ifndef __PAGE_H
#define __PAGE_H	1

#ifdef __cplusplus
extern "C" {
#endif


#if M_I386 || M_I486
#define __BF
#else
#define __BF far
#endif

#define PAGEOVERHEAD	10

/*****************************************
 * Allocate a block of data and clear it.
 * Use:
 *	unsigned page_calloc(void __BF *baseptr,unsigned size);
 * Returns:
 *	offset of allocated data else 0
 */

unsigned _cdecl page_calloc(void __BF *baseptr,unsigned size);

/*****************************************
 * Allocate a block of data.
 *	unsigned page_malloc(void __BF *baseptr,unsigned size);
 * Returns:
 *	offset of allocated data else 0
 */

unsigned _cdecl page_malloc(void __BF *baseptr,unsigned size);

/*****************************************
 * Reallocate memory that was allocated by page_malloc() or page_calloc().
 * Use:
 *	unsigned page_realloc(void __BF *baseptr,unsigned p, unsigned nbytes)
 * Returns:
 *	0 error
 *	else offset of reallocated memory
 */

unsigned _cdecl page_realloc(void __BF *baseptr,unsigned p, unsigned nbytes);

/*****************************************
 * Free memory that was allocated by page_malloc() or page_calloc().
 * Use:
 *	int page_free(void __BF *baseptr,unsigned p);
 * Returns:
 *	0	success
 *	-1	error (baseptr is bad, or memory is corrupted)
 */

int _cdecl page_free(void __BF *baseptr,unsigned p);

/*****************************************
 * Determine size of largest free block in page.
 *	unsigned page_maxfree(void __BF *baseptr);
 */

unsigned _cdecl page_maxfree(void __BF *baseptr);

/*****************************************
 * Initialize memory allocation system in a page.
 *	unsigned page_initialize(void __BF *baseptr,unsigned pagesize);
 * Returns:
 *	size of largest allocatable block
 */

unsigned _cdecl page_initialize(void __BF *baseptr,unsigned pagesize);

/*****************************************
 * Return number of bytes allocated for chunk of memory that was
 * allocated by page_malloc, page_calloc or page_realloc.
 */

/*unsigned _cdecl page_size(void __BF *baseptr,unsigned p);*/

#define page_size(baseptr,p) \
	(*(unsigned short __BF *)((char __BF *)(baseptr) + (p) - 2) - 2)

/****************************************
 * Convert pointer to page and offset into that page into a void * pointer.
 */

/*void __BF * near page_toptr(void __BF *baseptr,unsigned p);*/

#define page_toptr(baseptr,p)	(void __BF *)((char __BF *)(baseptr) + (p))

#ifdef __cplusplus
}
#endif

#endif /* __PAGE_H */
