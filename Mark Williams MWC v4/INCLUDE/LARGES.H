/*
 *	Let's C Version 4.0.C.
 *	Copyright (c) 1982-1987 by Mark Williams Company, Chicago.
 *	All rights reserved. May not be copied or disclosed without permission.
 */

/* larges.h */
/* Model-dependent definitions for i8086 assembler sources. */

#ifndef	LARGES_H
#define	LARGES_H

#if	LARGE
#define	LARGECODE 1
#define LARGEDATA 1
#endif

#if	LARGECODE
/* LARGE code: calls, jumps and returns are far, code pointer is 4 bytes. */
#define	Gcall	xcall
#define Gicall	xicall
#define Gijmp	xijmp
#define	Gjmp	xjmp
#define Gptr	.dword
#define	Gret	xret
#define	CPL	4
#else
/* SMALL code: calls, jumps and returns are near, code pointer is 2 bytes. */
#define	Gcall	call
#define Gicall	icall
#define Gijmp	ijmp
#define Gjmp	jmp
#define Gptr	.word
#define	Gret	ret
#define	CPL	2
#endif

#if	LARGEDATA
/* LARGE data: segment registers must be loaded to map data, escapes required. */
/* Data pointer is 4 bytes. */
#define Gdptr	.dword
#define	Lds	lds
#define	Les	les
#define	Map(sreg, temp, val)	mov	temp, val;	mov	sreg, temp
#define	Pes	es:
#define	Pss	ss:
#define	DPL	4
#else
/* SMALL data: DS==ES==SS, no escapes required. */
/* Data pointer is 2 bytes. */
#define Gdptr	.word
#define	Lds	mov
#define Les	mov
#define	Map(sreg, temp, val)
#define	Pes
#define	Pss
#define	DPL	2
#endif

/* Function entry and exit: preserve C register variables, initialize BP. */
/* No automatics allocated. */
#define Enter(x)	.globl x; x: push si; push di; push bp; mov bp, sp
#define Leave 		pop bp; pop di; pop si; Gret
#define LEFTARG	CPL+6

#define	RASIZE	CPL
#define	PTRSIZE	DPL

#endif
