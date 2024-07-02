/*_ INT.H   Wed Jun 28 1989   Modified by: Walter Bright */
/* Copyright (C) 1985-1989 by Northwest Software	*/
/* All rights reserved					*/
/* Written by Walter Bright				*/

/* Header for int package	*/

#ifndef INT_H
#define INT_H	1

#if __cplusplus
extern "C" {
#endif

#ifndef DOS_H
#include	<dos.h>
#endif

/* Structure passed to interrupt service routine (see int_xxx())	*/
struct INT_DATA
{
    unsigned	prevvec_off,prevvec_seg;	/* previous interrupt vector */
    unsigned	stacksize;			/* size of ISR stack	*/
    unsigned	newstack_off,newstack_seg;	/* ptr to ISR stack	*/
    unsigned	oldstack_off,oldstack_seg;	/* ptr to interrupted stack */
#if LPTR
    unsigned	staticseg;			/* value for DS		*/
#endif
    int		(cdecl *funcptr)();
    union REGS regs;	/* passed/returned register and flag values	*/
			/* (the _cflag member is garbage and is ignored) */
    struct SREGS sregs;	/* passed/returned segment register values	*/
};

void cdecl int_getvector(unsigned,unsigned *,unsigned *);
void cdecl int_setvector(unsigned,unsigned,unsigned);
int cdecl int_intercept(unsigned,int (cdecl *funcptr)(struct INT_DATA *),unsigned);
int cdecl int_restore(unsigned);
void cdecl int_off(void);
void cdecl int_on(void);

#if __cplusplus
}
#endif

#endif /* INT_H */
