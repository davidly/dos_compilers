
/* Copyright (c) 1987,88 by Borland International, Inc.

   This module demonstrates how to write Turbo C routines that
   can be linked into a Turbo Pascal program. Routines in this
   module call Turbo Pascal routines in CPASDEMO.PAS.

   See the instructions in the file CPASDEMO.PAS on running
   this demonstration program */

typedef unsigned int word;
typedef unsigned char byte;
typedef unsigned long longword;

extern void setcolor(byte newcolor);  /* procedure defined in
                                         Turbo Pascal program */
extern word factor;    /* variable declared in Turbo Pascal program */

word sqr(int i)
{
  setcolor(1);
  return(i * i);
} /* sqr */

word hibits(word w)
{
  setcolor(2);
  return(w >> 8);
} /* hibits */

byte suc(byte b)
{
  setcolor(3);
  return(++b);
} /* suc */

byte upr(byte c)
{
  setcolor(4);
  return((c >= 'a') && (c <= 'z') ? c - 32 : c);
} /* upr */

char prd(char s)
{
  setcolor(5);
  return(--s);
} /* prd */

long lobits(long l)
{
  setcolor(6);
  return((longword)l & 65535L);
} /* lobits */

void strupr(char *s)
{
  int counter;

  for (counter = 1; counter <= s[0]; counter++)  /* Note that the routine */
    s[counter] = upr(s[counter]);                /* skips Turbo Pascal's  */
  setcolor(7);                                   /* length byte           */
} /* strupr */

byte boolnot(byte b)
{
  setcolor(8);
  return(b == 0 ? 1 : 0);
} /* boolnot */

word multbyfactor(word w)
{
  setcolor(9);        /* note that this function accesses the Turbo Pascal */
  return(w * factor); /* declared variable factor */
} /* multbyfactor */
