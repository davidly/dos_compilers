/*_ stack.c	06-Jan-85   Modified by : Walter Bright	*/
/* Copyright (C) 1985-1989 by Walter Bright */
/* All rights reserved */
/* Written by Walter Bright */
/* default stack size	*/
#ifdef __OS2__
int _stack = 0x4000;
#else
int _stack = 0x2000;
#endif

