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

void __handle * _cdecl handle_malloc(unsigned);
void __handle * _cdecl handle_calloc(unsigned);
void __handle * _cdecl handle_realloc(void __handle *,unsigned);
char __handle * _cdecl handle_strdup(char __handle *);
void _cdecl handle_free(void __handle *);
int _cdecl handle_usingemm(void);
void _cdecl handle_remap(void);

/* Enable these to lock out using handle memory	*/
#if NO_HANDLE || DOS16RM || M_I386 || M_I486 || __OS2__
#define __handle
#define handle_malloc(n)	malloc(n)
#define handle_calloc(n)	calloc((n),1)
#define handle_realloc(h,n)	realloc((h),(n))
#define handle_free(h)		free(h)
#define handle_strdup(h)	strdup(h)
#define handle_usingemm()	0
#define handle_remap()

#undef handle_ishandle
#define handle_ishandle(h)	0

#ifndef __STDLIB_H
#include	<stdlib.h>	/* get definitions of malloc, etc.	*/
#endif
char *	_cdecl strdup(const char *);
#endif

#if __cplusplus
}
#endif

#endif /* __HANDLE_H */
