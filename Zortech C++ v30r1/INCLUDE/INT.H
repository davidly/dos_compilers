/*_ int.h   Tue Apr 24 1990   Modified by: Walter Bright */
/* Copyright (C) 1985-1990 by Walter Bright	*/
/* All rights reserved				*/
/* Written by Walter Bright			*/

/* Header for int package	*/

#ifndef __INT_H
#define __INT_H	1

#if __cplusplus
extern "C" {
#endif

#ifndef __DOS_H
#include	<dos.h>
#endif

/* Structure passed to interrupt service routine (see int_xxx())	*/

#pragma ZTC align 1			/* no alignment for DOS structs	*/

struct INT_DATA
{
#if M_I386 || M_I486
    char		align;		/* dword align remainder	*/
#endif
    unsigned		prevvec_off;	/* previous interrupt vector	*/
    unsigned short	prevvec_seg;
#if M_I386 || M_I486
    unsigned short	prevvecr_off;	/* previous real interrupt vector */
    unsigned short	prevvecr_seg;
#endif
    unsigned		stacksize;	/* size of ISR stack		*/
    unsigned		newstack_off;	/* ptr to ISR stack		*/
    unsigned short	newstack_seg;
    unsigned		oldstack_off;	/* ptr to interrupted stack	*/
    unsigned short	oldstack_seg;
#if __COMPACT__ || __LARGE__ || __VCM__ /* sizeof(void *) > sizeof(int)	*/
    unsigned short	staticseg;	/* value for DS			*/
#endif
    int		(_cdecl *funcptr)();
    union REGS regs;	/* passed/returned register and flag values	*/
			/* (the _cflag member is garbage and is ignored) */
    struct SREGS sregs;	/* passed/returned segment register values	*/
};

#pragma ZTC align

#if M_I386 || M_I486
void _cdecl int_setvector(unsigned,unsigned,unsigned);
#else
void _cdecl int_getvector(unsigned,unsigned *,unsigned *);
void _cdecl int_setvector(unsigned,unsigned,unsigned);
#endif
int _cdecl int_intercept(unsigned,int (_cdecl *funcptr)(struct INT_DATA *),unsigned);
void _cdecl int_restore(unsigned);
void _cdecl int_off(void);
void _cdecl int_on(void);
long _cdecl int_prev(struct INT_DATA *);

/* Inline versions of interrupt functions	*/
#define int_on()	asm(0xFB)	/* STI	*/
#define int_off()	asm(0xFA)	/* CLI	*/
#define int_gen(i)	asm(0xCD,i)	/* INT i */

#if __cplusplus
}
#endif

#endif /* __INT_H */
