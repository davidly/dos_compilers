/*_ vector.c   Mon Jan 23 1989   Modified by: Walter Bright */
/* Copyright (C) 1988-1989 by Walter Bright */
/* All rights reserved */


#include	<stddef.h>

/****************************
 * Call constructor on an array of objects.
 * Input:
 *	Parray		pointer to array of objects
 *	Nelem		number of those objects
 *	Sizelem		size of each of those objects
 *	Ctor		constructor to call for each of those objects
 */

typedef void *(*ctor_t)(void *);

void *_vec_new(void *Parray,unsigned Nelem,unsigned Sizelem,void *(*Ctor)(void))
{   unsigned n;
	
    if (Parray == 0)
	Parray = new char[((size_t) Nelem) * Sizelem];
    if (Ctor != 0)
    {	for (n = 0; n < Nelem; n++)
	    (*(ctor_t)Ctor)((char *)Parray + n * Sizelem);
    }
    return Parray;
}

typedef void *(*dtor_t)(int,void *);

void _vec_delete(void *Parray,unsigned Nelem,unsigned Sizelem,
	int (*Dtor)(void),int Free)
{   unsigned int n;

    if (Parray)
    {
	if (Dtor != 0)
	{   for (n = Nelem; n--;)
		(*(dtor_t)Dtor)(2,(char *)Parray + n * Sizelem);
	}
	if (Free & 1)
	    delete Parray;
    }
}
