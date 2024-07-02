/* _dos.h - This file defines data structures for DOS access.
 * $Version: 1.2 $
 * Copyright (c) 1990,91 Intel Corporation, ALL RIGHTS RESERVED.
 */

#ifndef __dosh
#define __dosh
/*lint -library */

#pragma fixedparams("_dosf25", "_dosf35", "_dosf3f", "_dosf40",  "_dosf48")
#pragma fixedparams("_dosf49", "_dosf4a", "_dosf4e", "abstoptr", "ptrtoabs")

#ifndef _FAR
#define _FAR  far
#define _HUGE huge
#define _NEAR near
#endif

#ifndef OK
#define OK      0
#define ERROR  -1
#endif

#ifndef _mode_t
#define _mode_t
typedef unsigned long mode_t;
#endif

extern int _chbuf;
extern mode_t _umask;

#ifndef _find_t
/*
 * structure used by _dos_findfirst
 */
#pragma noalign (find_t)
struct find_t {
    char reserved[21];  		/* reserved for dos */
    char attrib; 			/* returned attribute */
    unsigned short wr_time;		/* time file last written */
    unsigned short wr_date;		/* date file last written */
    long  size;				/* size of file */
    char name[13];  			/* string containing the filename */
};
#define _find_t
#endif

/*
 * Function prototypes:
 */
int          _dosf25(int, void _FAR *);
void _FAR   *_dosf35(int);
int          _dosf3f(int, char *, unsigned int);
int          _dosf40(int, char *, unsigned int);
void        *_dosf48(unsigned int);
int          _dosf49(void _FAR *);
int          _dosf4a(unsigned int, unsigned int);
int          _dosf4e(const char *, struct find_t *, unsigned int);
void _FAR    *abstoptr(unsigned long);
unsigned long ptrtoabs(void _FAR *);

#define abstoptr(a) \
        (void _FAR *)((((unsigned long)a>>4)<<16)|(unsigned long)(a&0xF))

#endif /* __dosh */
