/*  matherr

    Turbo-C Run Time Library

    Copyright (c) 1987 by Borland International.  All rights reserved.
*/

#include <stdio.h>
#include <math.h>
#include <errno.h>


/*
  When exceptions are detected in the maths library then a call is
  made to _matherr() with all the available information.

  That function does very little, except to map the exception "why"
  into either ERANGE or EDOMAIN in errno.  Its main purpose is to
  act as a focal point for changes in error handling.

  For example, if you were writing a spreadsheet you might replace
  this function with one which pops up an error window explaining
  something like:

      "log (-2.0) caused domain error, in cell J7"

  and then longjmp() to a reset state in the spreadsheet and await
  the next command from the user.

  The important thing is that we don't know what error handling
  you want, but you are assured that all errors will arrive at
  matherr() with all the information you need to design a custom
  format.

  We do not ship as standard the function named matherr() which may
  be familiar to UNIX users, since the ANSI x3j11 draft specifies
  an incompatible style.  This version is as close as we could
  get without breaking the ANSI rules.	You can, however, convert
  this version to the UNIX style if you prefer.  The necessary
  code is included but switched off.
*/


#ifdef	UNIX_matherr
char *whyS [] =
{
    "argument domain error",
    "argument singularity ",
    "overflow range error ",
    "underflow range error",
    "total loss of significance",
    "partial loss of significance"
};

int matherr (struct exception *e)
/*
    The default version of matherr() traditionally explains what has
    gone wrong and then kills the program.
*/
{
    fprintf (stderr,
	"%s (%8g,%8g): %s\n", e->name, e->arg1, e->arg2, whyS [e->type - 1]);

    exit (1);
}
#else

int matherr (struct exception *e)
{
    return (0);
}
#endif
