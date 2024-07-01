/* Turbo C - (C) Copyright 1987 by Borland International */

#pragma inline

void far movescreenmem(char far *source, char far *dest, unsigned len,
 int snowcheck)
/* Moves screen memory, doing snow control if necessary. */
{
 unsigned char right;

 asm push ds
 asm push es
 right = ((unsigned long)source < (unsigned long)dest);
 asm mov bh,snowcheck
 asm lds si,source
 asm les di,dest
 asm mov cx,len
 asm cmp cx,0
 asm je j9
 asm mov al,right
 asm cmp al,1
 asm je j1
 asm cld
 asm jmp short j4
j1:
 asm cmp bh,1
 asm je j2
 asm add si,cx
 asm sub si,2
 asm add di,cx
 asm sub di,2
 asm jmp short j3
j2:
 asm add si,cx
 asm dec si
 asm add di,cx
 asm dec di
j3:
 asm std
j4:
 asm cmp bh,1
 asm jne j7
 asm mov dx,3DAh
j5:
 asm in al,dx
 asm rcr al,1
 asm jb j5
 asm cli
j6:
 asm in al,dx
 asm rcr al,1
 asm jnb j6
 asm movsb
 asm sti
 asm loop j5
 asm jmp short j9
j7:
 asm shr cx,1
j8:
 asm movsw
 asm loop j8
j9:
 asm pop es
 asm pop ds
}
