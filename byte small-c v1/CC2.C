/*
** Small-C Compiler Part 2
*/
#include <stdio.h>
#include "cc.def"

extern char
#ifdef DYNAMIC
 *symtab,
 *stage,
 *macn,
 *macq,
 *pline,
 *mline,
#else
  symtab[SYMTBSZ],
  stage[STAGESIZE],
  macn[MACNSIZE],
  macq[MACQSIZE],
  pline[LINESIZE],
  mline[LINESIZE],
#endif
#ifdef OPTIMIZE
  optimize,
#endif
  alarm, *glbptr, *line, *lptr, *cptr, *cptr2,  *cptr3,
 *locptr, msname[NAMESIZE],  pause,  quote[2],
 *stagelast, *stagenext;
extern int
#ifdef DYNAMIC
  *wq,
#else
  wq[WQTABSZ],
#endif
  ccode,  cch,  csp,  eof,  errflag,  iflevel,
  input,  input2,  listfp,  macptr,  nch,
  nxtlab,  op[16],  opindex,  opsize,  output,  pptr,
  skiplevel,  *wqptr;

#include "cc21.c"
#include "cc22.c"

