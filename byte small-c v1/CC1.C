/*
** Small-C Compiler Part 1
*/
#include <stdio.h>
#include "notice.h"
#include "cc.def"

/*
** miscellaneous storage
*/
char
#ifdef OPTIMIZE
  optimize,	/* optimize output of staging buffer */
#endif
  alarm,	/* audible alarm on errors? */
  monitor,	/* monitor function headers? */
  pause,	/* pause for operator on errors? */
#ifdef DYNAMIC
 *stage,	/* output staging buffer */
 *symtab,	/* symbol table */
 *litq,		/* literal pool */
 *macn,		/* macro name buffer */
 *macq,		/* macro string buffer */
 *pline,	/* parsing buffer */
 *mline,	/* macro buffer */
#else
  stage[STAGESIZE],
  symtab[SYMTBSZ],
  litq[LITABSZ],
  macn[MACNSIZE],
  macq[MACQSIZE],
  pline[LINESIZE],
  mline[LINESIZE],
  swq[SWTABSZ],
#endif
 *line,		/* points to pline or mline */
 *lptr,		/* ptr to either */
 *glbptr,	/* ptrs to next entries */
 *locptr,	/* ptr to next local symbol */
 *stagenext,	/* next addr in stage */
 *stagelast,	/* last addr in stage */
  quote[2],	/* literal string for '"' */
 *cptr,		/* work ptrs to any char buffer */
 *cptr2,
 *cptr3,
  msname[NAMESIZE],	/* macro symbol name array */
  ssname[NAMESIZE];	/* static symbol name array */
int
#ifdef STGOTO
  nogo,		/* > 0 disables goto statements */
  noloc,	/* > 0 disables block locals */
#endif
  op[16],	/* function addresses of binary operators */
  op2[16],	/* same for unsigned operators */
  opindex,	/* index to matched operator */
  opsize,	/* size of operator in bytes */
  swactive,	/* true inside a switch */
  swdefault,	/* default label #, else 0 */
 *swnext,	/* address of next entry */
 *swend,	/* address of last table entry */
#ifdef DYNAMIC
 *wq,		/* while queue */
#else
  wq[WQTABSZ],
#endif
  argcs,	/* static argc */
 *argvs,	/* static argv */
 *wqptr,	/* ptr to next entry */
  litptr,	/* ptr to next entry */
  macptr,	/* macro buffer index */
  pptr,		/* ptr to parsing buffer */
  oper,		/* address of binary operator function */
  cch,		/* current character of line being scanned */
  nch,		/* next character of line being scanned */
  declared,	/* # of local bytes declared, else -1 when done */
  iflevel,	/* #if... nest level */
  skiplevel,	/* level at which #if... skipping started */
  func1,	/* true for first function */
  nxtlab,	/* next avail label # */
  litlab,	/* label # assigned to literal pool */
  beglab,	/* beginning label -- first function */
  csp,		/* compiler relative stk ptr */
  argstk,	/* function arg sp */
  argtop,
  ncmp,		/* # open compound statements */
  errflag,	/* non-zero after 1st error in statement */
  eof,		/* set non-zero on final input eof */
  input,	/* fd # for input file */
  input2,	/* fd # for "include" file */
  output,	/* fd # for output file */
  files,	/* non-zero if file list specified on cmd line */
  filearg,	/* cur file arg index */
  glbflag,	/* non-zero if internal globals */
  ctext,	/* non-zero to intermix c-source */
  ccode,	/* non-zero while parsing c-code */
		/* zero when passing assembly code */
  listfp,	/* file pointer to list device */
  lastst,	/* last executed statement type */

  swused,       /* 1=switch statement used, else 0 -- RG */

 *iptr;		/* work ptr to any int buffer */

#include "cc11.c"
#include "cc12.c"
#include "cc13.c"

#ifndef SEPARATE
#include "cc21.c"
#include "cc22.c"
#include "cc31.c"
#include "cc32.c"
#include "cc33.c"
#include "cc41.c"
#include "cc42.c"
#endif
