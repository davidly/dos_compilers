/*_ vec.c   Wed Dec  9 1987   Modified by: Walter Bright */
/* $Header$ */
/* Copyright (C) 1986-1987 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Bit vector package					*/

#include	<stdio.h>
#ifndef	assert
#include	<assert.h>
#endif
#ifndef VEC_H
#include	"vec.h"
#endif

static int vec_count;		/* # of vectors allocated		*/
static int vec_initcount = 0;	/* # of times package is initialized	*/

/**************************
 * Initialize package.
 */

void vec_init()
{
    assert(sizeof(vec_base_t)==2&&VECSHIFT==4||sizeof(vec_base_t)==4&&VECSHIFT== 5);
    if (vec_initcount++ == 0)
	    vec_count = 0;
}

/**************************
 * Terminate package.
 */

void vec_term()
{
    if (--vec_initcount == 0)
    {
#ifdef DEBUG
	if (vec_count != 0)
	{
		printf("vec_count = %d\n",vec_count);
		assert(0);
	}
#else
	assert(vec_count == 0);
#endif
    }
}

/********************************
 * Allocate a vector given # of bits in it.
 * Clear the vector.
 */

vec_t vec_calloc(numbits)
register unsigned numbits;
{ vec_t v;
  int dim;

  if (numbits == 0)
	return (vec_t) NULL;
  vec_count++;
  dim = (numbits + (VECBITS - 1)) >> VECSHIFT;
  v = (vec_t) mem_calloc((dim + 2) * sizeof(vec_base_t)) + 2;
  if (v)
  {	vec_dim(v) = dim;
	vec_numbits(v) = numbits;
	/*printf("vec_calloc(%d): v = x%x vec_numbits = %d vec_dim = %d\n",
	    numbits,v,vec_numbits(v),vec_dim(v));*/
  }
  return v;
}

/**************************
 * Free a vector.
 */

void vec_free(v)
vec_t v;
{
    if (v)
    {	mem_free(v - 2);
	vec_count--;
    }
}

/**************************
 * Realloc a vector to have numbits bits in it.
 * Extra bits are set to 0.
 */

vec_t vec_realloc(v,numbits)
vec_t v;
unsigned numbits;
{	vec_t newv;

	newv = vec_calloc(numbits);
	if (v && newv)
	{   unsigned nbytes;

	    nbytes = (vec_dim(v) < vec_dim(newv)) ? vec_dim(v) : vec_dim(newv);
	    memcpy(newv,v,nbytes * sizeof(vec_base_t));
	    vec_clearextrabits(newv);
	}
	vec_free(v);
	return newv;
}

/**************************
 * Set bit b in vector v.
 */

void vec_setbit(b,v)
register unsigned b;
register vec_t v;
{
#ifdef DEBUG
  if (!(v && b < vec_numbits(v)))
	printf("vec_setbit(v = x%x,b = %d): numbits = %d dim = %d\n",
	    v,b,vec_numbits(v),vec_dim(v));
#endif
  assert(v && b < vec_numbits(v));
  *(v + (b >> VECSHIFT)) |= 1 << (b & VECMASK);
}

/**************************
 * Clear bit b in vector v.
 */

void vec_clearbit(b,v)
register unsigned b;
register vec_t v;
{
  assert(v && b < vec_numbits(v));
  *(v + (b >> VECSHIFT)) &= ~(1 << (b & VECMASK));
}

/**************************
 * Test bit b in vector v.
 */

int vec_testbit(b,v)
register unsigned b;
vec_t v;
{
  if (!v)
	return 0;
#ifdef DEBUG
  if (b >= vec_numbits(v))
	printf("vec_testbit(v = x%x,b = %d): numbits = %d dim = %d\n",
	    v,b,vec_numbits(v),vec_dim(v));
#endif
  assert(b < vec_numbits(v));
  return *(v + (b >> VECSHIFT)) & (1 << (b & VECMASK));
}

/********************************
 * Find first set bit starting from b in vector v.
 * If no bit is found, return vec_numbits(v).
 */

unsigned vec_index(b,vec)
register unsigned b;
vec_t vec;
{	register unsigned starv;
	register vec_t v,vtop;
	unsigned bit;

#if 1
    v = vec;
    assert(v);
    if (b < vec_numbits(v))
    {	vtop = &vec[vec_dim(v)];
	bit = b & VECMASK;
	if (bit != b)			/* if not starting in first word */
		v += b >> VECSHIFT;
	starv = *v >> bit;
	while (1)
	{
		while (1)
		{	if (starv & 1)
				return b;
			if (starv == 0)
				break;
			b++;
			starv >>= 1;
		}
		b = (b + VECBITS) & ~VECMASK;	/* round up to next word */
		if (++v >= vtop)
		    break;
		starv = *v;
	}
    }
    return vec_numbits(vec);
#else
#if 0
	numbits = vec_numbits(v);
	assert(v && b < numbits);
	vtop = &v[vec_dim(v)];
	v += b >> VECSHIFT;
	if (!*v)			/* if remainder of word is 0	*/
	{	b += VECBITS - (b & VECMASK);
		bit = 1;
		v++;			/* move up to next word in vector */
	}
	else
		bit = 1 << (b & VECMASK);
	for (; v < vtop; v++)
	{
		if (!*v)
		{	b += VECBITS;
			continue;	/* next word in vector		*/
		}
		while (bit)
		{
			if (b >= numbits)
				return numbits;
			if (*v & bit)
				return b;
			bit <<= 1;
			b++;
		}
		bit = 1;
	}
	return numbits;
#else
	assert(v && b < vec_numbits(v));
	for (; b < vec_numbits(v); b++)
		if (testbit(b,v))	/* if bit is set		*/
			break;
	return b;
#endif
#endif
}

/********************************
 * Compute v1 = v2 & v3.
 */

void vec_and(v1,v2,v3)
register vec_t v1,v2,v3;
{ register vec_t vtop;

  assert(v1 && v2 && v3);
  assert(vec_numbits(v1)==vec_numbits(v2) && vec_numbits(v1)==vec_numbits(v3));
  vtop = &v1[vec_dim(v1)];
  if (v1 == v2)				/* the usual case		*/
	for (; v1 < vtop; v1++,v3++)
		*v1 &= *v3;
  else
	for (; v1 < vtop; v1++,v2++,v3++)
		*v1 = *v2 & *v3;
}

/********************************
 * Compute v1 = v2 ^ v3.
 */

void vec_xor(v1,v2,v3)
register vec_t v1,v2,v3;
{ register vec_t vtop;

  assert(v1 && v2 && v3);
  assert(vec_numbits(v1)==vec_numbits(v2) && vec_numbits(v1)==vec_numbits(v3));
  vtop = &v1[vec_dim(v1)];
  if (v1 == v2)				/* the usual case		*/
	for (; v1 < vtop; v1++,v3++)
		*v1 ^= *v3;
  else
	for (; v1 < vtop; v1++,v2++,v3++)
		*v1 = *v2 ^ *v3;
}

/********************************
 * Compute v1 = v2 | v3.
 */

void vec_or(v1,v2,v3)
register vec_t v1,v2,v3;
{ register vec_t vtop;

  assert(v1 && v2 && v3);
  assert(vec_numbits(v1)==vec_numbits(v2) && vec_numbits(v1)==vec_numbits(v3));
  vtop = &v1[vec_dim(v1)];
  if (v1 == v2)				/* the usual case		*/
	for (; v1 < vtop; v1++,v3++)
		*v1 |= *v3;
  else
	for (; v1 < vtop; v1++,v2++,v3++)
		*v1 = *v2 | *v3;
}

/********************************
 * Compute v1 = v2 - v3.
 */

void vec_sub(v1,v2,v3)
vec_t v1,v2,v3;
{ register vec_t vtop;

  assert(v1 && v2 && v3);
  assert(vec_numbits(v1)==vec_numbits(v2) && vec_numbits(v1)==vec_numbits(v3));
  vtop = &v1[vec_dim(v1)];
  if (v1 == v2)				/* the usual case		*/
	for (; v1 < vtop; v1++,v3++)
		*v1 &= ~*v3;
  else
	for (; v1 < vtop; v1++,v2++,v3++)
		*v1 = *v2 & ~*v3;
}

/****************
 * Clear vector.
 */

void vec_clear(v)
vec_t v;
{
  assert(v);
  memset(v,0,sizeof(v[0]) * vec_dim(v));
}

/****************
 * Set vector.
 */

void vec_set(v)
register vec_t v;
{
  assert(v);
  memset(v,~0,sizeof(v[0]) * vec_dim(v));
  vec_clearextrabits(v);
}

/***************
 * Copy vector.
 */

void vec_copy(to,from)
vec_t to,from;
{
#ifdef DEBUG
  if (!(to && from && vec_numbits(to) == vec_numbits(from)))
	printf("to = x%lx, from = x%lx, numbits(to) = %d, numbits(from) = %d\n",
		(long)to,(long)from,vec_numbits(to),vec_numbits(from));
#endif
  assert(to && from && vec_numbits(to) == vec_numbits(from));
  memcpy(to,from,sizeof(to[0]) * vec_dim(to));
}

/****************
 * Return 1 if vectors are equal.
 */

int vec_equal(v1,v2)
vec_t v1,v2;
{
  assert(v1 && v2 && vec_numbits(v1) == vec_numbits(v2));
  return !memcmp(v1,v2,sizeof(v1[0]) * vec_dim(v1));
}

/*********************
 * Clear any extra bits in vector.
 */

void vec_clearextrabits(v)
vec_t v;
{
	assert(v);
#if MSC
	if ((vec_numbits(v) & VECMASK) != 0)
	{
		vec_base_t e = v[vec_dim(v) - 1];
		vec_base_t b = vec_numbits(v);

		e &= (1 << (b & VECMASK)) - 1;
		v[vec_dim(v) - 1] = e;
	}
#else
	if ((vec_numbits(v) & VECMASK) != 0)
		v[vec_dim(v) - 1] &= (1 << (vec_numbits(v) & VECMASK)) - 1;
#endif
}

/******************
 * Write out vector.
 */

void vec_print(v)
vec_t v;
{ register unsigned i;

#ifdef DEBUG
  printf(" Vec x%p, numbits %d dim %d",v,vec_numbits(v),vec_dim(v));
  if (v)
  {	fputc('\t',stdout);
	for (i = 0; i < vec_numbits(v); i++)
		fputc((vec_testbit(i,v)) ? '1' : '0',stdout);
  }
  fputc('\n',stdout);
#endif
}
