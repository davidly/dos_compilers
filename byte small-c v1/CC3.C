/*
** Small-C Compiler Part 3
*/
#include <stdio.h>
#include "cc.def"

extern char
#ifdef DYNAMIC
 *stage,
 *litq,
#else
  stage[STAGESIZE],
  litq[LITABSZ],
#endif
 *glbptr, *lptr,  ssname[NAMESIZE],  quote[2], *stagenext;
extern int
  cch,  csp,  litlab,  litptr,  nch,  op[16],  op2[16],
  oper,  opindex,  opsize;

#include "cc31.c"
#include "cc32.c"
#include "cc33.c"

