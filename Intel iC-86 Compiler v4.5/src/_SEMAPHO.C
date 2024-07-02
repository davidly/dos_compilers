/*
 * This file contains four routines:
 *     _semaphore_init()   - initialize semaphore
 *     _semaphore_delete() - delete a semaphore
 *     _semaphore_wait()   - wait for the event to occur 
 *     _semaphore_signal() - clear the event
 *
 * If the user application is being executed in a multi-threaded
 * environment, the user is responsible for designing and implementing
 * all four routines.  CLIB-n86 uses these routines to protect its
 * data structures from simultaneous update errors.
 *
 * For the single-threaded DOS environment, these routines perform NO
 * operations:  they are just stubs to resolve the references in the body
 * of the C-Library code.
 * 
 * $Version: 1.8 $
 * Copyright (c) 1988 Intel Corporation, ALL RIGHTS RESERVED.
 */

#define DEBUG	0

#include <reent.h>
#if DEBUG
#include <conio.h>
#endif


static void	**top	= 0;

void (_semaphore_init)(void **sema)
{
#if DEBUG
	*sema = sema;
#endif
}

void (_semaphore_delete)(void **sema)
{
#if DEBUG
	*sema = sema;
#endif
}

void (_semaphore_wait)(void **sema)
{
#if DEBUG
	if (*sema != sema)
	{
		cprintf("_semaphore_wait: ERROR: %p != %p\n", *sema, sema);
	}
	if (top != 0)
	{
		cprintf("_semaphore_wait: WARNING: %p != NULL\n", top);
	}
	*sema = top;
	top = sema;
#endif
}

void (_semaphore_signal)(void **sema)
{
#if DEBUG
	if (sema != top)
	{
		cprintf("_semaphore_signal: ERROR: %p != %p\n", sema, top);
	}
	top = *sema;
	*sema = sema;
#endif
}
