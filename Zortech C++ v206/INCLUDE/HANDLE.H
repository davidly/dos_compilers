/*_ handle.h   Thu May  4 1989   Modified by: Walter Bright */

#ifndef __HANDLE_H
#define __HANDLE_H	1

#if __cplusplus
extern "C" {
#endif

/* Values above this are handles, below this are far pointers	*/
#define HANDLE_BASE	0xFE000000

/* Maximum number of handles possible	*/
#define HANDLE_MAX	((int)(0x10000 - (HANDLE_BASE >> 16)))

/* Size of pages (for EMM implementations, must match EMM_PAGESIZE)	*/
#define HANDLE_PAGESIZE		(16*1024)

/*********************************
 * Determine if handle is a real handle or a far pointer.
 * Returns:
 *	!=0 if handle
 *	0   if far pointer
 */

int handle_ishandle(void __handle *h);

#define handle_ishandle(h) ((int)(((unsigned long) (h) >= HANDLE_BASE) != 0))

void __handle * cdecl handle_malloc(unsigned);
void __handle * cdecl handle_calloc(unsigned);
void __handle * cdecl handle_realloc(void __handle *,unsigned);
char __handle * cdecl handle_strdup(char __handle *);
void cdecl handle_free(void __handle *);

/* Enable these to lock out using handle memory	*/
#if NO_HANDLE
#define handle
#define handle_malloc(n)	malloc(n)
#define handle_calloc(n)	calloc((n),1)
#define handle_realloc(h,n)	realloc((h),(n))
#define handle_free(h)		free(h)
#define handle_strdup(h)	strdup(h)
#endif

#if __cplusplus
}
#endif

#endif /* __HANDLE_H */
