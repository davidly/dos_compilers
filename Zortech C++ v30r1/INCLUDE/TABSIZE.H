/*	tabsize.h
 *	controls the program wide tab size, which is used by
 *	all routines that need to print tabs.
 *
 *	written by: G. Eric Engstrom
 */

#ifndef __TABSIZE_H
#define __TABSIZE_H

#ifdef __cplusplus
extern "C"
  {
#endif

          void _cdecl tab_sizeset(unsigned short newtabsize);
          void _cdecl tab_sizeputenv(unsigned short newtabsize);
unsigned short _cdecl tab_sizeget(void);
unsigned short _cdecl tab_sizegetenv(void);

extern unsigned short _tab_size;

#ifdef __cplusplus
  }
#endif

#endif
