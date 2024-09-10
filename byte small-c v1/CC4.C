/*
** Small-C Compiler Part 4
*/
#include <stdio.h>
#include "cc.def"

extern char
 *macn,
 *cptr, *symtab,
#ifdef OPTIMIZE
 optimize,
#endif
 *stagenext, ssname[NAMESIZE];
extern int
 beglab,  csp, output, swused;

#include "cc41.c"
#include "cc42.c"
