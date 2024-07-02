/*_ _new.c   Tue May 30 1989   Modified by: Walter Bright */
/* Copyright (C) 1988-1989 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#include	<stdlib.h>

/********************
 * _new_handler can be modified to point to a function in case
 * the allocation fails. _new_handler can attempt to repair things.
 */

void (*_new_handler)(void) = 0;

/*****************************
 * The standard C++ storage allocator.
 * Calls (*_new_handler)() if fails. If still fails, it returns NULL.
 */

void * operator new(size_t size)
{   void *p;

    while (1)
    {   
	p = malloc(size);
	if (p != NULL || _new_handler == NULL)
	    break;
	(*_new_handler)();
    }
    return p;
}
