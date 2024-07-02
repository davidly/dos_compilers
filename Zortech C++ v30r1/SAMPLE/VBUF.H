/*_ vbuf.h   Mon Aug 17 1987   Modified by: Walter Bright */
/* Copyright (C) 1987-1991 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/
/* Virtual buffered memory				*/

#ifndef VBUF_H
#define VBUF_H	1

#ifndef P
#include	"toolkit.h"
#endif

/* Pointer to a vbuf that is in memory		*/
#ifdef __ZTC__
typedef void _far *vbuf_ptr_t;
#else
typedef void *vbuf_ptr_t;
#endif

/* Type which refers to a virtual buffer	*/
typedef struct VBUF_S *vbuf_handle_t;

/*******************************
 * Type which refers to a virtual buffer.
 */

struct VBUF_S
{
    vbuf_handle_t next;		/* next in list				*/
    vbuf_handle_t prev;		/* previous in list			*/
    unsigned flags;		/* VFxxxxx				*/
    vbuf_ptr_t	memory;		/* pointer to memory buffer		*/
    unsigned long offset;	/* offset to buffer location in file	*/
    int fd;			/* file descriptor for disk buffers	*/
    int count;			/* # of locks on this buffer		*/
    int usage;			/* usage count (when 0, it can be freed) */
};

/* Size of a vbuf	*/
#define VBUF_SIZE	(8*2048)

extern int vbuf_inited;		/* 1 if initialized			*/

/************************* PUBLIC FUNCTIONS ***********************/

/***********************
 * Initialize for virtual buffers.
 */

void vbuf_init P((void));

/***********************
 * Terminate vbuf handler.
 */

void vbuf_term P((void));

/****************************
 * Increment usage count.
 */

#define vbuf_incusage(vb)	(++(vb)->usage)

/****************************
 * Decrement usage count.
 */

#define vbuf_decusage(vb)	(--(vb)->usage)

/****************************
 * Allocate a new vbuf, clear it, and return a pointer to it.
 * Returns 0 if can't allocate one.
 */

vbuf_handle_t vbuf_calloc P((void));

/****************************
 * Allocate a new vbuf and return a pointer to it.
 * Input:
 *	fd		file descriptor of file that this vbuf will refer to
 *	offset		offset in file that the vbuf will be at
 * Returns 0 if can't allocate one.
 */

vbuf_handle_t vbuf_filepage P((int,unsigned long));

/***************************
 * Free up a vbuf.
 */

void vbuf_free P((vbuf_handle_t));

/****************************
 * Mark vbuf as being modified.
 */

void vbuf_dirty P((vbuf_handle_t));

#define VFdirty		4	/* 1 if disk buffer is obsolete	*/
#define vbuf_dirty(vb_h)	((vb_h)->flags |= VFdirty)

/****************************
 * Return a pointer to real memory associated with the handle.
 * The pointer remains valid until the next call to vbuf_xxxx().
 */

#define vbuf_access(v)	(((v)->flags & 1) ? \
		(v)->memory : _vbuf_access(v))
vbuf_ptr_t _pascal _vbuf_access P((vbuf_handle_t));

/****************************
 * Lock and unlock a vbuf in memory.
 */

void vbuf_lock P((vbuf_handle_t));

void vbuf_unlock P((vbuf_handle_t));

/*****************************
 * mem_xxxx() calls this when they run out of memory.
 */

int vbuf_needmemory P((void));

#endif /* VBUF_H */
