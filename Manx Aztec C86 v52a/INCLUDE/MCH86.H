/* Copyright 1992 Manx Software Systems, Inc. All rights reserved */

#ifndef __MCH86_H
#define	__MCH86_H

far void *		abstoptr(long _addr);
int 			farcall(void (*_func)(void), 
					struct regs *_inregs, struct regs *_outregs);
int 			inportb(int _port);
int 			inportw(int _port);
void 			outportb(int _port, int _val);
void 			outportw(int _port, int _val);
far void *		_ptradd(far void *_lptr, long _val);
long 			_ptrdiff(far void *_lptr1, far void *_lptr2);
void 			pokeb(far char *_addr, int);
void 			pokew(far int *_addr, int);
unsigned char 	peekb(far char *_addr);	
unsigned int 	peekw(far int *_addr);
void 			segread(unsigned *_ptr);
int 			sysint(int _sint, struct regs *_inregs, struct regs *_outregs);


#endif	/* __MCH86_H */
