/*_ list.c   Wed Jun  7 1989   Modified by: Walter Bright */
/* Copyright (C) 1986-1991 by Northwest Software	*/
/* All Rights Reserved					*/
/* Written by Walter Bright				*/

#ifndef __STDIO_H
#include	<stdio.h>
#endif
#ifndef __STRING_H
#include	<string.h>
#endif
#ifndef assert
#include	<assert.h>
#endif
#ifndef LIST_H
#include	"list.h"
#endif
#ifndef MEM_H
#include	"mem.h"
#endif

#ifdef MEM_DEBUG
#define fileline	__FILE__,__LINE__
#else
#define fileline
#endif

list_t list_freelist = NULL;	/* list of free list entries		*/
static int nlist;		/* number of list items created		*/
int list_inited = 0;		/* 1 if initialized			*/

/* Free storage allocation	*/
#if __ZTC__ && !MEM_DEBUG
#define list_new()		((list_t) mem_scalloc(sizeof(struct LIST)))
#define list_delete(list)	mem_sfree((list),sizeof(struct LIST))
#else
#if MEM_DEBUG
#define list_new()		((list_t) mem_calloc_debug(sizeof(struct LIST),file,line))
#else
#define list_new()		((list_t) mem_malloc(sizeof(struct LIST)))
#endif
#define list_delete(list)	mem_free(list)
#endif

/**********************/

void list_init()
{
#ifdef DEBUG
	assert(mem_inited);
#endif
	if (list_inited == 0)
	{	nlist = 0;
		list_inited++;
	}
}

/*******************/

void list_term()
{
	if (list_inited)
	{
	    while (list_freelist)
	    {	list_t list;

		list = list_next(list_freelist);
		list_delete(list_freelist);
		list_freelist = list;
		nlist--;
	    }
#if DEBUG
	    if (nlist)
		printf("nlist = %d\n",nlist);
#endif
#if !MEM_DEBUG
	    assert(nlist == 0);
#endif
	    list_inited = 0;
	}
}

/****************************
 * Allocate list item.
 */

static list_t near list_alloc
#ifdef MEM_DEBUG
	(file,line)
	char *file;
	int line;
#else
	()
#endif
{   list_t list;

    if (list_freelist)
    {	list = list_freelist;
	list_freelist = list_next(list);
#ifdef MEM_DEBUG
	mem_setnewfileline(list,file,line);
#endif
    }
    else
    {	nlist++;
	list = list_new();
    }
    return list;
}

/******************************/

void list_free(plist,freeptr)
list_t *plist;
#if DLC || __ZTC__ || M_UNIX
void (*freeptr)(void *);
#else
void (*freeptr)();
#endif
{	register list_t list,listnext;

	list = *plist;
	*plist = 0;		/* block any circular reference bugs	*/
	while (list && --list->count == 0)
	{	listnext = list_next(list);
		if (freeptr)
			(*freeptr)(list_ptr(list));
#if DEBUG
		memset(list,0,sizeof(*list));
#endif
#if 0
		list->next = list_freelist;
		list_freelist = list;
#else
#if __ZTC__ && !MEM_DEBUG
		mem_sfree(list,sizeof(struct LIST));
#else
		mem_free(list);
#endif
		nlist--;
#endif
		list = listnext;
	}
}

/***************************/

void *list_subtract(plist,ptr)
register list_t *plist;
void *ptr;
{	register list_t list;

	while ((list = *plist) != 0)
	{
		if (list_ptr(list) == ptr)
		{
			if (--list->count == 0)
			{	*plist = list_next(list);
				list->next = list_freelist;
				list_freelist = list;
			}
			return ptr;
		}
		else
			plist = &(list_next(list));
	}
	return NULL;		/* it wasn't in the list		*/
}

/*************************/

#ifdef MEM_DEBUG
#undef list_append

list_t list_append(plist,ptr)
list_t *plist;
void *ptr;
{
    return list_append_debug(plist,ptr,__FILE__,__LINE__);
}

list_t list_append_debug(plist,ptr,file,line)
char *file;
int line;
#else
list_t list_append(plist,ptr)
#endif
register list_t *plist;
void *ptr;
{	register list_t list;

	while (*plist)
		plist = &(list_next(*plist));	/* find end of list	*/

#ifdef MEM_DEBUG
	list = list_alloc(file,line);
#else
	list = list_alloc();
#endif
	if (list)
	{	*plist = list;
		list_next(list) = 0;
		list_ptr(list) = ptr;
		list->count = 1;
	}
	return list;
}

/*************************/

list_t list_prepend(plist,ptr)
list_t *plist;
void *ptr;
{	register list_t list;

	list = list_alloc(fileline);
	if (list)
	{	list_next(list) = *plist;
		list_ptr(list) = ptr;
		list->count = 1;
		*plist = list;
	}
	return list;
}

/*************************/

int list_nitems(list)
register list_t list;
{	register int n;

	n = 0;
	while (list)
	{	n++;
		list = list_next(list);
	}
	return n;
}

/*************************/

list_t list_nth(list,n)
register list_t list;
int n;
{	register int i;

	for (i = 0; i < n; i++)
	{	assert(list);
		list = list_next(list);
	}
	return list;
}

/*************************/

list_t list_last(list)
register list_t list;
{
	if (list)
		while (list_next(list))
			list = list_next(list);
	return list;
}

/**************************/

list_t list_prev(start,list)
register list_t start,list;
{
    if (start)
    {	if (start == list)
	    start = NULL;
	else
	    while (list_next(start) != list)
	    {	start = list_next(start);
		assert(start);
	    }
    }
    return start;
}

/****************************/

list_t list_copy(list)
register list_t list;
{   list_t c;

    c = NULL;
    for (; list; list = list_next(list))
	list_append(&c,list_ptr(list));
    return c;
}

/****************************/

int list_equal(list1,list2)
register list_t list1,list2;
{
    while (list1 && list2)
    {
	if (list_ptr(list1) != list_ptr(list2))
	    break;
	list1 = list_next(list1);
	list2 = list_next(list2);
    }
    return list1 == list2;
}

/****************************/

int list_cmp(list1,list2,func)
list_t list1;
list_t list2;
int (*func) P((void *,void *));
{   int result = 0;

    while (1)
    {
	if (!list1)
	{   if (list2)
		result = -1;	/* list1 < list2	*/
	    break;
	}
	if (!list2)
	{   result = 1;		/* list1 > list2	*/
	    break;
	}
	result = (*func)(list_ptr(list1),list_ptr(list2));
	if (result)
	    break;
	list1 = list_next(list1);
	list2 = list_next(list2);
    }
    return result;
}

/*****************************/

list_t list_inlist(list,ptr)
register list_t list;
register void *ptr;
{
    for (; list; list = list_next(list))
	if (list_ptr(list) == ptr)
	    break;
    return list;
}
